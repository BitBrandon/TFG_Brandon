FROM osixia/openldap:1.5.0

# Copia el bootstrap LDIF
COPY bootstrap/01-bootstrap.ldif /container/service/slapd/assets/config/bootstrap/ldif/custom/01-bootstrap.ldif

# Copia los overlays (incluye bootstrap-overlays.sh)
COPY overlays/ /overlays/