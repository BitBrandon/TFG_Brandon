#!/bin/bash
set -e

# --- Colores ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}\n====== Reiniciando entorno LDAP desde cero ======${NC}\n"

# --- Parar y eliminar contenedores y volúmenes ---
echo -e "${GREEN}Apagando y limpiando contenedores...${NC}"
docker-compose down --volumes

# --- Limpiar directorios persistentes ---
echo -e "${GREEN}Eliminando volúmenes locales (data/config)...${NC}"
rm -rf ./ldap/data ./ldap/config
mkdir -p ./ldap/data ./ldap/config

# --- Validar archivos ldif ---
echo -e "${GREEN}Verificando archivos en ./ldap/ldif...${NC}"

LDIF_DIR=./ldap/ldif

if [ ! -d "$LDIF_DIR" ]; then
    echo -e "${RED}ERROR: No existe el directorio $LDIF_DIR.${NC}"
    exit 1
fi

shopt -s nullglob
LDIF_FILES=($LDIF_DIR/*.ldif)

if [ ${#LDIF_FILES[@]} -eq 0 ]; then
    echo -e "${RED}ERROR: No hay archivos .ldif en $LDIF_DIR.${NC}"
    exit 1
fi

for ldif in "${LDIF_FILES[@]}"; do
    if [ ! -s "$ldif" ]; then
        echo -e "${YELLOW}ADVERTENCIA: El archivo $ldif está vacío.${NC}"
    fi
done

# --- Permisos ---
echo -e "${GREEN}Ajustando permisos...${NC}"
if command -v chown &>/dev/null; then
    chown -R 911:911 ./ldap/data ./ldap/config || true
fi
chmod -R 700 ./ldap/data ./ldap/config || true

# --- Reconstruir imágenes ---
echo -e "${GREEN}Reconstruyendo imágenes Docker...${NC}"
docker-compose build --no-cache

# --- Levantar servicios ---
echo -e "${GREEN}Iniciando servicios...${NC}"
docker-compose up -d

# --- Esperar a que los contenedores estén listos ---
sleep 10

# --- Verificar estado de los contenedores ---
if ! docker-compose ps | grep -q "Up"; then
    echo -e "${RED}ERROR: Algunos contenedores no se levantaron correctamente.${NC}"
    docker-compose ps
    exit 1
fi

# --- Esperar disponibilidad de LDAP ---
echo -e "${GREEN}Esperando disponibilidad del servidor LDAP...${NC}"
for i in {1..15}; do
    if docker exec ldap-server ldapsearch -x -b "dc=mayorista,dc=local" >/dev/null 2>&1; then
        echo -e "${GREEN}LDAP disponible.${NC}"
        break
    else
        echo -e "${YELLOW}Esperando LDAP... ($i/15)${NC}"
        sleep 2
    fi

    if [ "$i" -eq 15 ]; then
        echo -e "${RED}ERROR: LDAP no responde tras múltiples intentos.${NC}"
        docker logs ldap-server
        exit 1
    fi
done

# --- Validaciones básicas de estructura LDAP ---
echo -e "${GREEN}\n=== Comprobaciones básicas ===${NC}"
check_and_log() {
    DESC="$1"
    SEARCH_DN="$2"
    EXPECTED="$3"

    echo -en "${DESC}... "
    if docker exec ldap-server ldapsearch -x -b "$SEARCH_DN" | grep -q "$EXPECTED"; then
        echo -e "${GREEN}OK${NC}"
    else
        echo -e "${RED}ERROR${NC}"
        docker exec ldap-server ldapsearch -x -b "$SEARCH_DN"
    fi
}

check_and_log "Dominio mayorista.local" "dc=mayorista,dc=local" "dn: dc=mayorista,dc=local"
check_and_log "OU usuarios" "dc=mayorista,dc=local" "ou=usuarios"
check_and_log "OU grupos" "dc=mayorista,dc=local" "ou=grupos"
check_and_log "Usuario juan" "ou=usuarios,dc=mayorista,dc=local" "uid=juan"

# --- Fin ---
echo -e "${GREEN}\nEl entorno LDAP está listo para usar.${NC}"
read -p "Presiona ENTER para salir..." dummy