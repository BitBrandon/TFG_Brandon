#!/bin/bash
set -e

# Configura estos valores según tu entorno
LDAP_ADMIN_DN="cn=admin,dc=mayorista,dc=local"
LDAP_ADMIN_PASS="adminpassword"  # Debe coincidir con LDAP_ADMIN_PASSWORD en docker-compose.yml

# Aplica los overlays básicos (deben ser idempotentes)
for ldif in /overlays/02-security.ldif /overlays/03-memberOf.ldif /overlays/04-refint.ldif /overlays/05-index.ldif; do
  echo "Aplicando $ldif ..."
  # Intenta primero con EXTERNAL (para overlays/config), si falla prueba con simple bind
  ldapmodify -Y EXTERNAL -H ldapi:/// -f "$ldif" 2>/dev/null || \
    ldapmodify -x -D "$LDAP_ADMIN_DN" -w "$LDAP_ADMIN_PASS" -f "$ldif"
done

# Aplica las ACLs avanzadas, SOLO cuando ya existan los DNs requeridos
echo "Aplicando ACLs avanzadas (99-secure-acls.ldif) ..."
ldapmodify -x -D "$LDAP_ADMIN_DN" -w "$LDAP_ADMIN_PASS" -f /overlays/99-secure-acls.ldif

echo "¡Todos los overlays aplicados!"