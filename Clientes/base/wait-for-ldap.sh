#!/bin/bash
set -x

until ldapsearch -x -D "cn=admin,dc=mayorista,dc=local" -w adminpassword -H ldap://ldap-server/ -b "" -s base > /dev/null 2>&1; do
  echo "Esperando a que LDAP acepte conexiones como admin..."
  sleep 2
done

echo "LDAP disponible. Arrancando nslcd y sshd..."
service nslcd start
service ssh start

# Llama al entrypoint principal y reemplaza el proceso actual
exec /entrypoint.sh