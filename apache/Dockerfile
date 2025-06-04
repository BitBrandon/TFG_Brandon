FROM debian:bullseye

ENV DEBIAN_FRONTEND=noninteractive

# Añadir repo Buster para PHP 7.4
RUN echo "deb http://deb.debian.org/debian buster main" >> /etc/apt/sources.list

# Instalación de Apache, PHP 7.4 y módulos necesarios
RUN apt-get update && \
    apt-get install -y apache2 apache2-utils \
    libapache2-mod-php7.4 php7.4 php7.4-ldap php7.4-cli php7.4-common php7.4-json php7.4-opcache php7.4-readline \
    ldap-utils curl && \
    rm -rf /var/lib/apt/lists/*

# Copiar configuración personalizada ANTES de activarla
COPY conf/myhttpd.conf /etc/apache2/conf-available/myhttpd.conf

# Habilitar módulos y configuración (usa php7.4, no php genérico)
RUN a2enmod ldap authnz_ldap rewrite proxy proxy_http php7.4 && \
    a2enconf myhttpd

# Copiar contenido web
COPY htdocs/ /var/www/html/

# Copiar scripts
COPY entrypoint.sh /entrypoint.sh
COPY wait-for-it.sh /wait-for-it.sh
RUN chmod +x /entrypoint.sh /wait-for-it.sh

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]