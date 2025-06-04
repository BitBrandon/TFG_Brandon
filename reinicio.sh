#!/bin/bash
set -e

###########################
# 1. APAGAR Y ELIMINAR TODO
###########################
echo "Apagando y eliminando contenedores y volúmenes..."
docker compose down -v

###########################
# 2. BORRAR DIRECTORIOS DE DATOS Y CONFIG (NO RECREARLOS)
###########################
echo "Borrando por completo los volúmenes LDAP locales..."
rm -rf ./ldap/data
rm -rf ./ldap/config

###########################
# 3. COMPROBAR LDIFs CRÍTICOS
###########################
if [ ! -f ./ldap/bootstrap/50-bootstrap.ldif ]; then 
    echo "¡ATENCIÓN! Falta el archivo 50-.ldif en ./ldap/bootstrap/" 
    exit 1 
fi

if [ ! -f ./ldap/bootstrap/00-base.ldif ]; then
    echo "¡ATENCIÓN! Falta el archivo LDIF de dominio inicial en ./ldap/bootstrap/"
    exit 1
fi

###########################
# 4. RECONSTRUIR IMÁGENES
###########################
echo "Reconstruyendo imágenes sin caché..."
docker compose build --no-cache

###########################
# 5. LEVANTAR CONTENEDORES
###########################
echo "Levantando contenedores en segundo plano..."
docker compose up -d

###########################
# 6. ESPERAR A QUE LDAP RESPONDA
###########################
echo "Esperando a que LDAP esté disponible..."
MAX_RETRIES=30
RETRIES=0
until docker exec ldap-server ldapsearch -x -H ldap://localhost -b "dc=mayorista,dc=local" -D "cn=admin,dc=mayorista,dc=local" -w adminpassword -s base > /dev/null 2>&1; do
    RETRIES=$((RETRIES+1))
    if [ $RETRIES -ge $MAX_RETRIES ]; then
        echo "Error: El contenedor LDAP no respondió a tiempo."
        exit 1
    fi
    sleep 2
done

##########################
# 7. OVERLAYS Y CONFIG EXTRA
###########################
echo "LDAP está listo. Esperando unos segundos extra antes de overlays..."
sleep 5

export MSYS_NO_PATHCONV=1
docker exec ldap-server ls -l /overlays/
docker exec ldap-server head -n 10 /overlays/bootstrap-overlays.sh

if docker exec ldap-server /bin/sh -c 'chmod +x /overlays/bootstrap-overlays.sh && /overlays/bootstrap-overlays.sh'; then
    echo "¡Overlays aplicados correctamente!"
else
    echo "¡ATENCIÓN! /overlays/bootstrap-overlays.sh falló, no existe o no es ejecutable en el contenedor."
fi
unset MSYS_NO_PATHCONV

###########################
# 8. COMPROBACIONES DOCKER
###########################
echo
echo "=== Comprobaciones de estado Docker ==="
echo "- Estado de los contenedores:"
docker compose ps

echo
echo "- Proceso nslcd en el cliente (trabajador1):"
docker exec cliente-trabajador1 pgrep -a nslcd && echo "OK: nslcd está corriendo." || echo "ERROR: nslcd NO está corriendo."

echo
echo "- Prueba ldapsearch desde el cliente:"
docker exec cliente-trabajador1 ldapsearch -x -H ldap://ldap-server/ -b "dc=mayorista,dc=local" -D "cn=admin,dc=mayorista,dc=local" -w adminpassword -s base | grep -q "dn:" \
    && echo "OK: ldapsearch responde desde el cliente." \
    || echo "ERROR: ldapsearch NO responde desde el cliente."

echo
echo "- Prueba getent passwd (usuarios LDAP) en el cliente:"
docker exec cliente-trabajador1 getent passwd | grep mayorista || echo "ADVERTENCIA: No se ven usuarios LDAP en getent passwd."

echo
echo "- Prueba getent group (grupos LDAP) en el cliente:"
docker exec cliente-trabajador1 getent group | grep mayorista || echo "ADVERTENCIA: No se ven grupos LDAP en getent group."

###########################
# 9. COMPROBACIONES LDAP
###########################
echo
echo "=== Comprobaciones de carga de LDIFs en LDAP ==="

# Dominio base
echo "- ¿Dominio mayorista.local presente (00-base.ldif)?"
if docker exec ldap-server ldapsearch -x -b "dc=mayorista,dc=local" | grep -q "dn: dc=mayorista,dc=local"; then
    echo "   OK: Dominio mayorista.local cargado."
else
    echo "   ERROR: No se encontró el dominio mayorista.local."
fi

# OU usuarios
echo "- ¿OU=usuarios presente?"
if docker exec ldap-server ldapsearch -x -b "ou=usuarios,dc=mayorista,dc=local" "(objectClass=organizationalUnit)" | grep -q "dn: ou=usuarios,dc=mayorista,dc=local"; then
    echo "   OK: OU=usuarios cargada."
else
    echo "   ERROR: No se encontró ou=usuarios."
fi

# OU grupos
echo "- ¿OU=grupos presente?"
if docker exec ldap-server ldapsearch -x -b "ou=grupos,dc=mayorista,dc=local" "(objectClass=organizationalUnit)" | grep -q "dn: ou=grupos,dc=mayorista,dc=local"; then
    echo "   OK: OU=grupos cargada."
else
    echo "   ERROR: No se encontró ou=grupos."
fi

# Grupos POSIX + groupOfNames
echo "- ¿Grupos POSIX (y groupOfNames) cargados?"
if docker exec ldap-server ldapsearch -x -b "ou=grupos,dc=mayorista,dc=local" "(objectClass=posixGroup)" | grep -q "objectClass: posixGroup"; then
    echo "   OK: Grupos POSIX encontrados."
else
    echo "   ERROR: No se encontraron grupos POSIX."
fi
if docker exec ldap-server ldapsearch -x -b "ou=grupos,dc=mayorista,dc=local" "(objectClass=groupOfNames)" | grep -q "objectClass: groupOfNames"; then
    echo "   OK: Grupos groupOfNames encontrados."
else
    echo "   ERROR: No se encontraron grupos groupOfNames."
fi

# Usuarios POSIX + inetOrgPerson
echo "- ¿Usuarios POSIX (y inetOrgPerson) cargados?"
if docker exec ldap-server ldapsearch -x -b "ou=usuarios,dc=mayorista,dc=local" "(objectClass=posixAccount)" | grep -q "objectClass: posixAccount"; then
    echo "   OK: Usuarios POSIX encontrados."
else
    echo "   ERROR: No se encontraron usuarios POSIX."
fi
if docker exec ldap-server ldapsearch -x -b "ou=usuarios,dc=mayorista,dc=local" "(objectClass=inetOrgPerson)" | grep -q "objectClass: inetOrgPerson"; then
    echo "   OK: Usuarios inetOrgPerson encontrados."
else
    echo "   ERROR: No se encontraron usuarios inetOrgPerson."
fi

# Atributos clave usuarios
echo "- ¿Atributos POSIX en usuarios?"
if docker exec ldap-server ldapsearch -x -b "ou=usuarios,dc=mayorista,dc=local" "(objectClass=posixAccount)" uidNumber gidNumber homeDirectory loginShell | grep -q "uidNumber:"; then
    echo "   OK: Usuarios tienen atributos POSIX."
else
    echo "   ERROR: Faltan atributos POSIX en usuarios."
fi

# Atributos clave grupos
echo "- ¿Atributos POSIX en grupos?"
if docker exec ldap-server ldapsearch -x -b "ou=grupos,dc=mayorista,dc=local" "(objectClass=posixGroup)" cn gidNumber memberUid | grep -q "gidNumber:"; then
    echo "   OK: Grupos tienen atributos POSIX."
else
    echo "   ERROR: Faltan atributos POSIX en grupos."
fi

# Overlays
echo "- ¿Overlays aplicados?"
if docker exec ldap-server ldapsearch -Y EXTERNAL -H ldapi:/// -b "cn=config" "(objectClass=olcOverlayConfig)" dn | grep -q "dn:"; then
    echo "   OK: Overlays aplicados (cn=config)."
else
    echo "   ADVERTENCIA: No se detectaron overlays en cn=config (esto puede ser normal si no usas overlays)."
fi

# Bind admin
echo "- ¿Bind de admin funciona?"
if docker exec ldap-server ldapwhoami -x -D "cn=admin,dc=mayorista,dc=local" -w adminpassword | grep -q "dn:cn=admin,dc=mayorista,dc=local"; then
    echo "   OK: Bind admin correcto."
else
    echo "   ERROR: Bind admin fallido."
fi

###########################
# 10. PAUSA PARA REVISIÓN MANUAL
###########################
echo
echo "=== Fin de comprobaciones automáticas ==="
echo
echo "Puedes revisar los resultados arriba."
echo "Presiona ENTER para terminar."
read