#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}Arrancando entorno Mayorista...${NC}"
docker-compose up -d

sleep 7

echo -e "${YELLOW}Validando servicios críticos...${NC}"

# --- Función auxiliar para comprobar contenedor ---
check_container() {
  local name="$1"
  local test_cmd="$2"
  local ok_msg="$3"
  local fail_msg="$4"
  if docker exec "$name" bash -c "$test_cmd" >/dev/null 2>&1; then
    echo -e "${GREEN}$ok_msg${NC}"
  else
    echo -e "${RED}$fail_msg${NC}"
    exit 1
  fi
}

# --- LDAP ---
check_container "ldap-server" "ldapsearch -x -b 'dc=mayorista,dc=local'" \
  "LDAP OK" "LDAP FALLÓ, revisa docker logs ldap-server"

# --- MariaDB ---
check_container "mariadb" "mysqladmin ping -uadmin -padminpassword" \
  "MariaDB OK" "MariaDB FALLÓ, revisa docker logs mariadb"

# --- API ---
check_container "api_mayorista" "curl -s http://localhost:5000/ | grep -i mayorista" \
  "API OK" "API FALLÓ, revisa docker logs api_mayorista"

# --- Apache ---
check_container "apache_server" "curl -s http://localhost/ | grep -iq mayorista" \
  "Apache OK" "Apache FALLÓ, revisa docker logs apache_server"

echo -e "${GREEN}Todos los servicios críticos están UP y validados.${NC}"
docker-compose ps