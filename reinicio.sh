#!/bin/bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # sin color

echo -e "\n${GREEN}====== Reiniciando entorno LDAP desde cero ======${NC}\n"

# 0. Limpieza automática: elimina archivos LDIF vacíos
echo -e "${GREEN}Eliminando archivos LDIF vacíos en ldap/bootstrap...${NC}"
find ./ldap/bootstrap -type f -empty -delete

# 1. Parar y eliminar contenedores y red
echo -e "${GREEN}Parando y eliminando todos los contenedores y la red...${NC}"
docker-compose down -v || true

# 2. Borrar volúmenes de datos y config LDAP por completo
echo -e "${GREEN}Borrando volúmenes de datos y configuración LDAP...${NC}"
rm -rf ./ldap/data
rm -rf ./ldap/config

# 3. Verificar presencia de los LDIF críticos
if [ ! -f ./ldap/bootstrap/50-bootstrap.ldif ]; then
    echo -e "${RED}ERROR: Falta 50-bootstrap.ldif en ldap/bootstrap. Abortando.${NC}"
    exit 1
fi

echo -e "${GREEN}LDIFs de bootstrap detectados.${NC}"

#4. Reconstruir imágenes 
echo -e "${GREEN}Reconstruyendo todas las imágenes locales (build forzado)...${NC}"
docker-compose build --no-cache

# 5. Levantar servicios
echo -e "${GREEN}Levantando todos los servicios...${NC}"
docker-compose up -d

# 6. Esperar a que el contenedor LDAP esté disponible
echo -e "${GREEN}Esperando a que el servidor LDAP esté disponible...${NC}"
sleep 5
for i in {1..15}; do
    if docker exec ldap-server ldapsearch -x -b "dc=mayorista,dc=local" >/dev/null 2>&1; then
        echo -e "${GREEN}LDAP accesible.${NC}"
        break
    else
        echo -e "Esperando LDAP... ($i/15)"
        sleep 2
    fi
    if [ $i -eq 15 ]; then
        echo -e "${RED}LDAP NO está accesible tras esperar. Revisa los logs.${NC}"
        docker logs ldap-server
        exit 1
    fi
done

# 7. Comprobaciones automáticas
echo -e "${GREEN}\n=== Comprobaciones automáticas ===${NC}"
echo -en "Dominio mayorista.local... "
if docker exec ldap-server ldapsearch -x -b "dc=mayorista,dc=local" | grep -q "dn: dc=mayorista,dc=local"; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}ERROR${NC}"
fi

echo -en "OU usuarios... "
if docker exec ldap-server ldapsearch -x -b "ou=usuarios,dc=mayorista,dc=local" | grep -q "dn: ou=usuarios,dc=mayorista,dc=local"; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}ERROR${NC}"
fi

echo -en "OU grupos... "
if docker exec ldap-server ldapsearch -x -b "ou=grupos,dc=mayorista,dc=local" | grep -q "dn: ou=grupos,dc=mayorista,dc=local"; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}ERROR${NC}"
fi

echo -en "Usuario juan... "
if docker exec ldap-server ldapsearch -x -b "uid=juan,ou=usuarios,dc=mayorista,dc=local" | grep -q "dn: uid=juan,ou=usuarios,dc=mayorista,dc=local"; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}ERROR${NC}"
fi

echo -e "${GREEN}\n=== Fin de comprobaciones automáticas ===${NC}"
echo -e "Puedes revisar los resultados arriba."
read -p "Presiona ENTER para terminar."