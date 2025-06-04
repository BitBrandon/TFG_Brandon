#!/bin/bash
set -e
# Ruta donde tienes los LDIF de overlays/config
LDIF_DIR="/container/service/slapd/assets/config/bootstrap/ldif/custom"

# Aplica ACL (seguridad)
if [ -f "$LDIF_DIR/02-security.ldif" ]; then
  echo "Aplicando 02-security.ldif (ACL)..."
  ldapmodify -Y EXTERNAL -H ldapi:/// -f "$LDIF_DIR/02-security.ldif"
fi

# Aplica overlay memberOf
if [ -f "$LDIF_DIR/03-memberOf.ldif" ]; then
  echo "Aplicando 03-memberOf.ldif (memberOf overlay)..."
  ldapadd -Y EXTERNAL -H ldapi:/// -f "$LDIF_DIR/03-memberOf.ldif"
fi

# Aplica overlay refint
if [ -f "$LDIF_DIR/04-refint.ldif" ]; then
  echo "Aplicando 04-refint.ldif (refint overlay)..."
  ldapadd -Y EXTERNAL -H ldapi:/// -f "$LDIF_DIR/04-refint.ldif"
fi

# Aplica índices
if [ -f "$LDIF_DIR/05-index.ldif" ]; then
  echo "Aplicando 05-index.ldif (índices)..."
  ldapmodify -Y EXTERNAL -H ldapi:/// -f "$LDIF_DIR/05-index.ldif"
fi

echo "¡Aplicación de overlays/configuración finalizada!"