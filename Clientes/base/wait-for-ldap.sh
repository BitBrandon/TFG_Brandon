#!/bin/bash
set -x

# Espera a que el LDAP esté accesible
for i in {1..15}; do
  if ldapsearch -x -D "cn=admin,dc=mayorista,dc=local" -w adminpassword -H ldap://ldap-server/ -b "" -s base > /dev/null 2>&1; then
    echo "[DEBUG] LDAP disponible en intento $i."
    break
  else
    echo "[DEBUG] Intento $i de conexión a LDAP fallido, reintentando..."
    sleep 2
  fi
  if [ "$i" -eq 15 ]; then
    echo "[ERROR] LDAP no responde tras 15 intentos, abortando."
    exit 1
  fi
done

# DHCP para obtener IP y mostrarla
echo "[DEBUG] Liberando posibles IPs previas en eth0..."
ip addr flush dev eth0 || true
echo "[DEBUG] Solicitando IP por DHCP..."
dhclient -v eth0 || true
echo "[DEBUG] IP después de dhclient:"
ip a show eth0

echo "[DEBUG] Hostname actual: $(hostname)"

echo "[DEBUG] Arrancando servicio nslcd..."
service nslcd start

echo "[DEBUG] Arrancando servicio rsyslog..."
service rsyslog start

echo "[DEBUG] Estado de servicios tras arranque:"
service nslcd status
service rsyslog status

echo "[DEBUG] Arrancando servicio SSH (sshd)..."
exec /usr/sbin/sshd -D