#!/bin/bash

echo "[INFO] Iniciando cliente DHCP..."

ip addr flush dev eth0
dhclient -v eth0
echo "[INFO] Dirección IP asignada:"
ip a show eth0

hostname=$(hostname)
echo "$hostname" > /etc/hostname
echo "127.0.0.1 $hostname" >> /etc/hosts
hostnamectl set-hostname "$hostname"

# Iniciar servicios necesarios para LDAP y logs
service nslcd start
service rsyslog start

echo "[INFO] Iniciando servicio SSH..."
exec /usr/sbin/sshd -D