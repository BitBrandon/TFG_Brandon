#!/bin/bash
set -e

# --- Colores para mensajes ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # Sin color

echo -e "\n${GREEN}====== Reiniciando entorno LDAP Docker desde cero ======${NC}\n"

# --- Parar y borrar contenedores y volúmenes ---
echo -e "${GREEN}Parando y eliminando todos los contenedores y volúmenes...${NC}"
docker-compose down -v || true

# --- Borrar directorios de datos y configuración ---
echo -e "${GREEN}Borrando volúmenes de datos y configuración LDAP...${NC}"
rm -rf ./ldap/data ./ldap/config

# --- Crear directorios requeridos (si no existen) ---
mkdir -p ./ldap/data ./ldap/config

# --- Verificar archivos requeridos para el Dockerfile ---
echo -e "${GREEN}Verificando archivos requeridos...${NC}"

if [ ! -f ./ldap/bootstrap/01-bootstrap.ldif ]; then
    echo -e "${RED}ERROR: Falta 01-bootstrap.ldif en ldap/bootstrap/. Abortando.${NC}"
    exit 1
fi

if [ ! -d ./ldap/overlays ]; then
    echo -e "${RED}ERROR: Falta el directorio ldap/overlays. Abortando.${NC}"
    exit 1
fi

if [ ! -f ./ldap/overlays/bootstrap-overlays.sh ]; then
    echo -e "${YELLOW}ADVERTENCIA: No se encontró el script de overlays avanzados (./ldap/overlays/bootstrap-overlays.sh).${NC}"
else
    echo -e "${GREEN}Script de overlays detectado.${NC}"
fi

for ldif in ./ldap/overlays/*.ldif; do
    if [ ! -s "$ldif" ]; then
        echo -e "${YELLOW}ADVERTENCIA: El archivo $ldif está vacío.${NC}"
    fi
done

echo -e "${GREEN}Archivos de bootstrap y overlays detectados.${NC}"

# --- Permisos (opcional en Windows, comentar si da error) ---
echo -e "${GREEN}Asignando permisos correctos a los volúmenes...${NC}"
if command -v chown &>/dev/null; then
     chown -R 911:911 ./ldap/data ./ldap/config
else
    chown -R 911:911 ./ldap/data ./ldap/config || true
fi
chmod -R 700 ./ldap/data ./ldap/config || true

# --- Reconstruir imágenes locales si es necesario ---
echo -e "${GREEN}Reconstruyendo todas las imágenes locales (build forzado)...${NC}"
docker-compose build --no-cache

# --- Levantar servicios ---
echo -e "${GREEN}Levantando todos los servicios...${NC}"
docker-compose up -d

# --- Esperar a que el servidor LDAP esté disponible ---
echo -e "${GREEN}Esperando a que el servidor LDAP esté disponible...${NC}"
for i in {1..15}; do
    if docker exec ldap-server ldapsearch -x -b "dc=mayorista,dc=local" >/dev/null 2>&1; then
        echo -e "${GREEN}LDAP accesible.${NC}"
        break
    else
        echo -e "${YELLOW}Esperando LDAP... ($i/15)${NC}"
        sleep 2
    fi
    if [ $i -eq 15 ]; then
        echo -e "${RED}LDAP NO está accesible tras esperar. Revisa los logs.${NC}"
        docker logs ldap-server
        exit 1
    fi
done

# --- Comprobaciones automáticas de estructura LDAP ---
echo -e "${GREEN}\n=== Comprobaciones automáticas de estructura LDAP ===${NC}"

check_and_log() {
    DESC="$1"
    SEARCH_DN="$2"
    GREP_DN="$3"
    echo -en "$DESC... "
    if docker exec ldap-server ldapsearch -x -b "$SEARCH_DN" | grep -q "$GREP_DN"; then
        echo -e "${GREEN}OK${NC}"
    else
        echo -e "${RED}ERROR${NC}"
        echo -e "${RED}Mostrando logs recientes de ldap-server:${NC}"
        docker logs ldap-server | tail -n 40
    fi
}

check_and_log "Dominio mayorista.local" "dc=mayorista,dc=local" "dn: dc=mayorista,dc=local"
check_and_log "OU usuarios" "dc=mayorista,dc=local" "dn: ou=usuarios,dc=mayorista,dc=local"
check_and_log "OU grupos" "dc=mayorista,dc=local" "dn: ou=grupos,dc=mayorista,dc=local"
check_and_log "Usuario juan" "dc=mayorista,dc=local" "dn: uid=juan,ou=usuarios,dc=mayorista,dc=local"

echo -e "${GREEN}\n=== Fin de comprobaciones automáticas ===${NC}"

# --- Aplicar overlays avanzados (ACLs) si existe el script ---
if docker exec ldap-server test -f /overlays/bootstrap-overlays.sh; then
    echo -e "${GREEN}Aplicando overlays avanzados (incluyendo ACLs)...${NC}"
    docker exec ldap-server chmod +x /overlays/bootstrap-overlays.sh
    docker exec -i ldap-server bash /overlays/bootstrap-overlays.sh
else
    echo -e "${YELLOW}No se encontró el script de overlays avanzados dentro del contenedor.${NC}"
fi

echo -e "${GREEN}\nEl entorno LDAP está listo para usar.${NC}"
read -p "Presiona ENTER para terminar."