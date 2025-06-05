# Entorno Mayorista - Guía completa de despliegue y pruebas

## Introducción

Este proyecto proporciona un entorno completo de gestión mayorista con autenticación LDAP, gestión visual vía Apache/PHP, API REST (Flask), base de datos persistente (MariaDB) y utilidades de administración, todo orquestado con Docker.  
**Sigue esta guía para arrancar, validar y probar que todo funciona correctamente, desde la red hasta la gestión visual y los backups.**

---

## 📦 Estructura y scripts principales

- **`arrancar.sh`**  
  Arranca todos los servicios Docker y valida que LDAP, MariaDB, Apache y la API estén funcionando.
- **`apagar.sh`**  
  Realiza backups automáticos de los servicios críticos y apaga los contenedores de forma segura.
- **`backups/`**  
  Carpeta donde se almacenan los backups de LDAP, MariaDB, Apache y la API.
- **`docker-compose.yml`**  
  Orquestación de todos los servicios y clientes.
- **`apache/htdocs/privado/`**  
  Panel de gestión web protegida por LDAP (usuarios, productos, ventas, etc).
- **`api/`**  
  Código de la API Flask para operaciones CRUD.

---

## 🚀 Arranque y comprobación inicial

1. **Ubícate en la raíz del proyecto:**
   ```bash
   cd /ruta/a/TFG_Brandon
   ```

2. **Arranca todos los servicios:**
   ```bash
   ./arrancar.sh
   ```
   - El script limpia, reconstruye imágenes, arranca todos los contenedores y valida que todo está disponible.
   - Verás mensajes de colores según el estado de cada servicio.

3. **Verifica los contenedores activos:**
   ```bash
   docker ps
   ```
   Deben aparecer: `ldap-server`, `phpldapadmin`, `mariadb`, `api_mayorista`, `apache_server`, los clientes, `dns-server`, `dhcp-server`.

---

## 🌐 Pruebas de red y clientes

1. **Verifica IPs de los clientes (DHCP):**
   ```bash
   docker exec cliente-trabajador1 ip -4 a show eth0
   docker exec cliente-jefe ip -4 a show eth0
   ```

2. **Comprueba la resolución DNS desde un cliente:**
   ```bash
   docker exec cliente-trabajador1 ping -c 2 www.mayorista.local
   ```

3. **Comprueba integración LDAP en los clientes:**
   ```bash
   docker exec cliente-trabajador1 getent passwd juan
   docker exec cliente-trabajador1 getent group trabajadores
   ```

---

## 🗂️ Gestión LDAP (PHPLDAPAdmin)

1. **Accede a PHPLDAPAdmin:**  
   [http://localhost:8080](http://localhost:8080)

2. **Login:**  
   - Usuario: `cn=admin,dc=mayorista,dc=local`
   - Contraseña: `adminpassword` (o la que configures)

3. **Prueba:**  
   - Crea, edita y borra usuarios y grupos.
   - Comprueba que los cambios se reflejan en los clientes (puedes hacer `getent passwd` o `id <usuario>` en un cliente).

---

## 🖥️ Pruebas visuales de Apache y panel PHP

1. **Abre la web principal:**  
   [http://localhost](http://localhost)

2. **Accede a la zona privada:**  
   - Haz clic en “Acceder”.
   - Apache te pedirá credenciales LDAP.

3. **Panel privado:**  
   - Comprueba acceso a todas las secciones: usuarios, clientes, productos, ventas, facturas, categorías, proveedores, gastos y logs.
   - Realiza operaciones CRUD en cada sección: crear, editar, eliminar, consultar.

4. **Zona de administración:**  
   - Accede a “Zona de Administración” (solo usuarios administradores).
   - Prueba la descarga de backups y exportación de CSV.

---

## 🔗 Pruebas de la API Flask (REST)

1. **Comprueba que la API está activa:**
   ```bash
   curl http://localhost:5000/
   ```

2. **Prueba un endpoint, por ejemplo clientes:**
   ```bash
   curl http://localhost:5000/clientes/
   ```

3. **Prueba creación, edición y borrado usando POST/PUT/DELETE (con curl o Postman).**

---

## 🛢️ Pruebas directas en MariaDB

1. **Entra al contenedor de MariaDB:**
   ```bash
   docker exec -it mariadb bash
   mysql -uadmin -padminpassword mayorista_db
   ```

2. **Haz una consulta sencilla:**
   ```sql
   SHOW TABLES;
   SELECT * FROM usuarios;
   ```

---

## 💾 Comprobación de backups y apagado

1. **Apaga todo y haz backup:**
   ```bash
   ./apagar.sh
   ```

2. **Verifica la carpeta `backups/`**  
   - Deben aparecer archivos .tar.gz y .sql del día.
   - Consulta los logs generados si hay errores.

---

## 🔄 Restauración (opcional)

1. **Para restaurar un backup:**
   - Detén el entorno con `./apagar.sh`.
   - Descomprime el backup sobre la carpeta correspondiente (por ejemplo, para LDAP o MariaDB).
   - Arranca de nuevo con `./arrancar.sh`.
   - Comprueba que los datos y la configuración se han restaurado correctamente.

---

## 📋 Consejos y troubleshooting

- **Ver logs de servicios:**
  ```bash
  docker logs apache_server
  docker logs api_mayorista
  docker logs ldap-server
  docker logs mariadb
  ```

- **Exporta CSV desde la zona admin y comprueba el contenido.**

- **Comprueba bloqueo de acceso:**  
  Intenta entrar en `/privado/zona_admin.php` con un usuario NO admin y verifica que se deniega el acceso.

---

## ✅ Resumen de ciclo seguro

1. **Arranca:** `./arrancar.sh`
2. **Valida servicios, red y clientes.**
3. **Haz pruebas de gestión visual y API REST.**
4. **Apaga y haz backup:** `./apagar.sh`
5. **(Opcional) Restaura backups y verifica persistencia.**

---

¡Ya tienes una guía práctica y completa para validar tu TFG de principio a fin!  
