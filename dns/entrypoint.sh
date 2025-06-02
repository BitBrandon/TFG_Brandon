#!/bin/bash
set -e

# Quitar posible PID anterior para evitar errores
rm -f /var/run/dnsmasq.pid

# Ejecutar dnsmasq en primer plano
exec dnsmasq --no-daemon
