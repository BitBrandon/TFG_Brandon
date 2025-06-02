FROM debian:bullseye

ENV DEBIAN_FRONTEND=noninteractive

# Actualizar e instalar herramientas básicas, SSH, DHCP y utilidades
RUN apt-get update && apt-get install -y \
    openssh-server \
    sudo \
    vim \
    nano \
    curl \
    telnet \
    iputils-ping \
    net-tools \
    dnsutils \
    isc-dhcp-client \
    httpie \
    iproute2 \
    systemd \
    ldap-utils \
    && rm -rf /var/lib/apt/lists/*
RUN apt-get update && apt-get install -y \
    libnss-ldap \
    libpam-ldap \
    ldap-utils \
    nscd \
    && rm -rf /var/lib/apt/lists/*

# Crear usuario con permisos sudo
RUN useradd -ms /bin/bash cliente && echo "cliente:cliente" | chpasswd && adduser cliente sudo

# SSH config
RUN mkdir /var/run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/UsePAM yes/UsePAM no/' /etc/ssh/sshd_config

# Copiar entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 22

CMD ["/entrypoint.sh"]
