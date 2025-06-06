FROM debian:bullseye

ENV DEBIAN_FRONTEND=noninteractive

# Actualizar, instalar todo y limpiar caché
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
    nslcd \
    nscd \
    libpam-modules \
    libpam-mkhomedir \
    rsyslog \
    wget \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

RUN wget http://ftp.de.debian.org/debian/pool/main/n/nss-pam-ldapd/libnss-ldapd_0.9.11-1_amd64.deb && \
    dpkg -i libnss-ldapd_0.9.11-1_amd64.deb && \
    rm libnss-ldapd_0.9.11-1_amd64.deb

# Configuración NSS y PAM LDAP
COPY nsswitch.conf /etc/nsswitch.conf
COPY ldap.conf /etc/ldap/ldap.conf
COPY nslcd.conf /etc/nslcd.conf
RUN chmod 600 /etc/nslcd.conf

# Habilitar módulo mkhomedir en PAM (para crear home al login LDAP)
RUN echo "session required pam_mkhomedir.so skel=/etc/skel umask=0022" >> /etc/pam.d/common-session

# SSH config: habilitar PAM
RUN mkdir /var/run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/UsePAM no/UsePAM yes/' /etc/ssh/sshd_config

# Copiar entrypoint y script de espera
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

COPY wait-for-ldap.sh /wait-for-ldap.sh
RUN chmod +x /wait-for-ldap.sh

EXPOSE 22

ENTRYPOINT ["/wait-for-ldap.sh"]