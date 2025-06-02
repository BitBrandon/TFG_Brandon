#!/bin/bash

set -e

# Esperar a servicios dependientes
/wait-for-it.sh ldap-server:389 -t 60 -- echo "LDAP disponible" || echo "LDAP no disponible, continuando..."
/wait-for-it.sh api:5000 -t 30 -- echo "API disponible" || echo "API no disponible, continuando..."

# Verificar configuración de Apache
echo ">>> Verificando configuración de Apache..."
if ! apache2ctl configtest; then
    echo ">>> Error en la configuración de Apache. Revisa la salida anterior."
    exit 1
else
    echo ">>> Configuración de Apache válida."
fi

# Iniciar Apache en primer plano
echo ">>> Iniciando Apache en primer plano..."
exec apache2ctl -D FOREGROUND
