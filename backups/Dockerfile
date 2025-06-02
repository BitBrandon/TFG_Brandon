FROM debian:bullseye

RUN apt-get update && \
    apt-get install -y cron mariadb-client && \
    apt-get clean

# Copiar scripts
COPY backup.sh /backup.sh
COPY crontab.txt /etc/cron.d/db-cron

# Permisos
RUN chmod +x /backup.sh && chmod 0644 /etc/cron.d/db-cron

# Aplicar cron job
RUN crontab /etc/cron.d/db-cron

# Crear directorio de logs
RUN mkdir /var/log/cron

VOLUME ["/backups"]

CMD ["cron", "-f"]
