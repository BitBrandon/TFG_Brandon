#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}\n====== Reiniciando entorno LDAP desde cero (EFÍMERO) ======${NC}\n"

# --- Parar y eliminar contenedores y volúmenes ---
echo -e "${GREEN}Apagando y limpiando contenedores...${NC}"
docker-compose down --volumes

# --- Limpiar directorios persistentes LDAP ---
echo -e "${GREEN}Eliminando directorios locales (data/config) de LDAP...${NC}"
rm -rf ./ldap/data ./ldap/config

# --- INFO archivos ldif ---
echo -e "${GREEN}Verificando archivos en ./ldap/ldif...${NC}"

LDIF_DIR=./ldap/ldif

if [ ! -d "$LDIF_DIR" ]; then
    echo -e "${YELLOW}ADVERTENCIA: No existe el directorio $LDIF_DIR. Si quieres cargar datos, crea la carpeta y añade LDIFs.${NC}"
fi

shopt -s nullglob
LDIF_FILES=($LDIF_DIR/*.ldif)

if [ ${#LDIF_FILES[@]} -eq 0 ]; then
    echo -e "${YELLOW}AVISO: No hay archivos .ldif en $LDIF_DIR. El LDAP arrancará vacío, perfecto para crear todo desde PHPLDAPAdmin.${NC}"
fi

for ldif in "${LDIF_FILES[@]}"; do
    # Asegura salto de línea al final
    tail -c1 "$ldif" | read -r _ || echo >> "$ldif"
    if [ ! -s "$ldif" ]; then
        echo -e "${YELLOW}ADVERTENCIA: El archivo $ldif está vacío.${NC}"
    fi
done

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

# --- Fin ---
echo -e "${GREEN}\nEl entorno LDAP está listo para usar (vacío, sin datos ni overlays cargados).${NC}"
echo -e "${YELLOW}Puedes crear la base y todo lo necesario desde PHPLDAPAdmin.${NC}"
read -p "Presiona ENTER para salir..." dummy