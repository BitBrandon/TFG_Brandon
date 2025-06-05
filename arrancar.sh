#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}\n====== Arrancando entorno LDAP/PHP/MariaDB/Apache ======${NC}\n"

# Levantamos todos los servicios
echo -e "${GREEN}Arrancando docker-compose up...${NC}"
docker-compose up -d

# Esperar a que los contenedores estén listos
sleep 10

# Comprobamos que LDAP responde con usuario admin
echo -e "${GREEN}Verificando disponibilidad de LDAP...${NC}"
for i in {1..15}; do
    if docker exec ldap-server ldapsearch -x -D "cn=admin,dc=mayorista,dc=local" -w adminpassword -b "dc=mayorista,dc=local" >/dev/null 2>&1; then
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

# Resumen de estado de clientes
echo -e "${GREEN}\nResumen de estado de los clientes:${NC}"
clientes=(cliente-trabajador1 cliente-trabajador2 cliente-jefe cliente-jefeit)

for cliente in "${clientes[@]}"; do
    echo -e "\n${YELLOW}--- Estado de $cliente ---${NC}"
    docker exec "$cliente" bash -c '
        echo "Hostname: $(hostname)"
        echo -n "IPs: "; ip -4 a show eth0 | grep inet | awk "{print \$2}" | xargs echo
        echo -n "LDAP usuario juan: "; getent passwd juan >/dev/null && echo "OK" || echo "NO"
        echo -n "LDAP grupo trabajadores: "; getent group trabajadores >/dev/null && echo "OK" || echo "NO"
    '
done

echo -e "${GREEN}\nTodos los servicios están listos.${NC}"
echo -e "${YELLOW}Pulsa ENTER para cerrar...${NC}"
read