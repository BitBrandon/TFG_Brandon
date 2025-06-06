FROM ubuntu:20.04

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y isc-dhcp-server && \
    apt-get clean

COPY dhcpd.conf /etc/dhcp/dhcpd.conf

ENV INTERFACES="eth0"

CMD ["dhcpd", "-f", "-d", "-cf", "/etc/dhcp/dhcpd.conf"]
