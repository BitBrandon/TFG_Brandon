#!/bin/bash
echo "===> Solicitando IP al servidor DHCP..."
dhclient eth0
echo "===> IP obtenida:"
ip a show eth0
exec /bin/bash
