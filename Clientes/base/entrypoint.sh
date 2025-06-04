#!/bin/bash

set -e

echo "[INFO] Iniciando cliente DHCP..."

ip addr flush dev eth0
dhclient -v eth0 || true
echo "[INFO] Dirección IP asignada:"
ip a show eth0

hostname=$(hostname)
echo "$hostname" > /etc/hostname
echo "127.0.0.1 $hostname" >> /etc/hosts
# hostnamectl set-hostname "$hostname" || true

# Iniciar servicios necesarios para LDAP y logs
service nslcd start || true
service rsyslog start || true

echo "[INFO] Iniciando servicio SSH..."
exec /usr/sbin/sshd -D