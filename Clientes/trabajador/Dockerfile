FROM debian:bullseye

# Actualizamos e instalamos herramientas necesarias
RUN apt-get update && apt-get install -y \
    ssh \
    curl \
    dnsutils \
    net-tools \
    iputils-ping \
    vim \
    ldap-utils \
    python3 \
    python3-pip \
    && apt-get clean

# Creamos un usuario simulado para acceso dentro del contenedor
RUN useradd -m trabajador

# Puerto SSH (opcional si quieres acceder con MobaXterm)
EXPOSE 22

CMD ["/bin/bash"]
