#!/bin/bash

echo "[INFO] Iniciando cliente DHCP..."

# 🔄 Limpiar cualquier IP asignada automáticamente por Docker
ip addr flush dev eth0

# 📡 Solicitar IP por DHCP
dhclient -v eth0

# 🖥️ Mostrar IP asignada
echo "[INFO] Dirección IP asignada:"
ip a show eth0

# 🏷️ Establecer hostname
hostname=$(hostname)
echo "$hostname" > /etc/hostname
echo "127.0.0.1 $hostname" >> /etc/hosts
hostnamectl set-hostname "$hostname"

# 🔐 Iniciar servicio SSH
echo "[INFO] Iniciando servicio SSH..."
exec /usr/sbin/sshd -D
