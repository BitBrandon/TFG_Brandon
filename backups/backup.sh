#!/bin/bash

# Fecha actual para el nombre del archivo
DATE=$(date +"%Y-%m-%d_%H-%M")
BACKUP_DIR="/backups"
DB_NAME="mayorista_db"
DB_USER="admin"
DB_PASSWORD="adminpassword"

# Comando de dump
mysqldump -h db -u$DB_USER -p$DB_PASSWORD $DB_NAME > "$BACKUP_DIR/backup_$DATE.sql"

echo "Backup realizado: backup_$DATE.sql"
