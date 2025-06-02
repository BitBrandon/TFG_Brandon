FROM debian:stable-slim

ENV DEBIAN_FRONTEND=noninteractive

# Instalar dnsmasq
RUN apt-get update && apt-get install -y dnsmasq && \
    mkdir -p /var/log && touch /var/log/dnsmasq.log && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Copiar configuración
COPY dnsmasq.conf /etc/dnsmasq.conf
COPY dnsmasq.hosts /etc/dnsmasq.hosts
COPY entrypoint.sh /entrypoint.sh

# Permisos
RUN chmod +x /entrypoint.sh

# Exponer puerto DNS
EXPOSE 53/udp

# Entrypoint
ENTRYPOINT ["/entrypoint.sh"]
