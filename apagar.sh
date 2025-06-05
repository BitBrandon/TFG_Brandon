#!/bin/bash
set -e

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

BACKUPDIR="./backups"
DATE=$(date +"%Y-%m-%d_%H-%M-%S")

mkdir -p "$BACKUPDIR"

echo -e "${YELLOW}Realizando backups de los servicios críticos...${NC}"

# ---- LDAP ----
if [ -d ldap/data ] && [ -d ldap/config ]; then
  tar czf "$BACKUPDIR/ldap-backup-$DATE.tar.gz" ldap/data ldap/config
  echo -e "${GREEN}Backup LDAP OK${NC}"
else
  echo -e "${RED}LDAP data/config no existen, no se hace backup.${NC}"
fi

# ---- MariaDB ----
echo -e "${YELLOW}Backup de MariaDB...${NC}"
docker exec mariadb mysqldump -uadmin -padminpassword mayorista_db > "$BACKUPDIR/mariadb-backup-$DATE.sql" && \
echo -e "${GREEN}Backup MariaDB OK${NC}" || \
echo -e "${RED}Backup MariaDB FALLÓ${NC}"

# ---- Apache ----
if [ -d apache/htdocs ] && [ -d apache/conf ]; then
  tar czf "$BACKUPDIR/apache-backup-$DATE.tar.gz" apache/htdocs apache/conf
  echo -e "${GREEN}Backup Apache OK${NC}"
else
  echo -e "${RED}Apache htdocs/conf no existen, no se hace backup.${NC}"
fi

# ---- API ----
if [ -d api ]; then
  tar czf "$BACKUPDIR/api-backup-$DATE.tar.gz" api
  echo -e "${GREEN}Backup API OK${NC}"
else
  echo -e "${RED}Directorio api no existe, no se hace backup.${NC}"
fi

# ---- Mantener solo los 5 últimos backups por servicio ----
echo -e "${YELLOW}Limpiando backups antiguos...${NC}"
for tipo in ldap-backup mariadb-backup apache-backup api-backup; do
  ls -1t "$BACKUPDIR"/$tipo-* 2>/dev/null | tail -n +6 | xargs -r rm --
done

echo -e "${GREEN}Todos los backups realizados. Parando servicios...${NC}"
docker-compose down

echo -e "${GREEN}Entorno mayorista apagado correctamente.${NC}"