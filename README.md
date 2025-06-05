# Entorno Mayorista - Gestión Persistente con PHPLDAPAdmin

## Introducción

Este entorno está diseñado para que LDAP, usuarios, grupos y toda la gestión de seguridad se hagan manualmente a través de PHPLDAPAdmin. NO se usan LDIFs de arranque ni borrado automático: ¡los datos y la configuración persisten siempre salvo que tú los borres!

Todos los scripts (`arrancar.sh`, `apagar.sh`) están preparados para trabajar de forma segura, con backups automáticos y validaciones en el arranque.

---

## 📦 Estructura y scripts principales

- **`arrancar.sh`**  
  Arranca todos los servicios Docker y valida que LDAP, MariaDB, Apache y la API están funcionando. Si algún servicio falla, lo muestra en rojo y PARA el proceso.
- **`apagar.sh`**  
  Realiza backups de los servicios críticos (LDAP, MariaDB, Apache, API), elimina los backups más antiguos (manteniendo solo los 5 últimos por servicio) y apaga los servicios.
- **`backups/`**  
  Aquí se almacenan los backups automáticos. Cada servicio tiene sus propios archivos independientes.

---

## 🚀 Arrancar el entorno

```bash
./arrancar.sh
```

- Se levantan todos los contenedores.
- Se valida que los servicios críticos estén **UP** (LDAP, MariaDB, Apache, API).
- Si alguno falla, se muestra en rojo y se detiene el script.
- Si todo está OK, puedes entrar a PHPLDAPAdmin para crear usuarios, grupos y estructura LDAP como quieras.

---

## 🛑 Apagar el entorno y hacer backup

```bash
./apagar.sh
```

- Realiza backups comprimidos de:
  - **LDAP** (`ldap/data` y `ldap/config`)
  - **MariaDB** (dump SQL)
  - **Apache** (`apache/htdocs` y `apache/conf`)
  - **API** (`api/`)
- Se almacenan en `./backups/` y solo se conservan los 5 más recientes por servicio.
- Cuando termina, apaga todos los contenedores de forma segura.

---

## 🛠️ Gestión del LDAP (manual)

- Accede a PHPLDAPAdmin: [http://localhost:8080](http://localhost:8080)
- Login:  
  - Usuario: `cn=admin,dc=mayorista,dc=local`
  - Contraseña: `adminpassword` (o la que definas en tu `docker-compose.yml`)
- Crea la estructura LDAP a mano: dominios, OUs, usuarios, grupos, etc.
- Todo lo que hagas se guarda en los volúmenes persistentes (`ldap/data` y `ldap/config`).  
  **Nunca se borra salvo que tú lo borres a mano.**

---

## 🔁 Restaurar backups (manual)

Para restaurar un backup de cualquier servicio:
1. Detén el entorno si está en marcha (`./apagar.sh`).
2. Descomprime el backup deseado sobre la carpeta correspondiente (`ldap/data`, `apache/htdocs`, etc).
3. Arranca el entorno (`./arrancar.sh`).

---

## 📑 Logs y utilidades

- Consulta logs de cualquier servicio:
  ```bash
  docker logs <nombre-del-contenedor>
  ```
- Ejemplo:
  ```bash
  docker logs ldap-server
  docker logs mariadb
  docker logs api_mayorista
  docker logs apache_server
  ```

---

## Resumen: Ciclo seguro

1. **Arranca:** `./arrancar.sh`
2. **Gestiona LDAP y servicios vía PHPLDAPAdmin y las webs**
3. **Apaga y haz backup:** `./apagar.sh`
4. **Restaura backups si lo necesitas, siempre manualmente**

---

## NOTA

- Este flujo es persistente y seguro: **no hay reinicio destructivo ni borrado automático**.
- Si necesitas un "reseteo total", borra los volúmenes/carpeta manualmente o restaura un backup anterior.

---

¡Disfruta de tu entorno Mayorista con máxima seguridad y control manual vía PHPLDAPAdmin!