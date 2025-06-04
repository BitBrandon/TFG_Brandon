#!/bin/bash
set -e

# Espera a que el LDAP esté disponible (puedes ajustar el host si es necesario)
until ldapsearch -x -H ldap://ldap-server/ -b "dc=mayorista,dc=local" > /dev/null 2>&1; do
  echo "Esperando a que LDAP esté listo..."
  sleep 2
done

echo "LDAP disponible. Arrancando nslcd y sshd..."
service nslcd start
service ssh start

# Llama al entrypoint original (por si quieres tareas extra)
exec /entrypoint.sh

# Mantén el contenedor vivo
tail -f /dev/null