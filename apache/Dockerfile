FROM debian:bullseye

ENV DEBIAN_FRONTEND=noninteractive

# Instalación de Apache y módulos necesarios
RUN apt-get update && \
    apt-get install -y apache2 apache2-utils libapache2-mod-ldap-userdir ldap-utils curl && \
    rm -rf /var/lib/apt/lists/*

# Copiar configuración personalizada ANTES de activarla
COPY conf/myhttpd.conf /etc/apache2/conf-available/myhttpd.conf

# Habilitar módulos y configuración
RUN a2enmod ldap authnz_ldap rewrite proxy proxy_http && \
    a2enconf myhttpd

# Copiar contenido web
COPY htdocs/ /var/www/html/

# Copiar scripts
COPY entrypoint.sh /entrypoint.sh
COPY wait-for-it.sh /wait-for-it.sh
RUN chmod +x /entrypoint.sh /wait-for-it.sh

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
