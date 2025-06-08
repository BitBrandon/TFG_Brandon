# 🚀 TFG: Arquitectura de Servicios Dockerizados y Centralización de Identidades

¡Bienvenido/a! Este repositorio contiene mi Trabajo de Fin de Grado, donde aprenderás a desplegar y gestionar una arquitectura completa de servicios utilizando Docker, integrando autenticación centralizada mediante OpenLDAP y simulando un entorno realista de empresa.

👨‍💻 Autor: BitBrandon

---

## 🗂️ Tabla de Contenidos

1. [Introducción](#introducción)
2. [Arquitectura del Sistema](#arquitectura-del-sistema)
   - [Diagrama de Contexto](#diagrama-de-contexto)
   - [Diagrama de Contenedores (C4)](#diagrama-de-contenedores-c4)
3. [Tecnologías Utilizadas](#tecnologías-utilizadas)
4. [Estructura del Proyecto](#estructura-del-proyecto)
5. [Instalación y Despliegue](#instalación-y-despliegue)
6. [Acceso a Clientes y Pruebas LDAP](#acceso-a-clientes-y-pruebas-ldap)
7. [Scripts de Gestión y Automatización](#scripts-de-gestión-y-automatización)
8. [Uso y Ejemplos Prácticos](#uso-y-ejemplos-prácticos)
9. [Pruebas y Validación](#pruebas-y-validación)
10. [Resolución de Problemas](#resolución-de-problemas)
11. [Conclusión Final](#conclusión-final)
12. [Agradecimientos](#agradecimientos)
13. [Roadmap y Futuras Mejoras](#roadmap-y-futuras-mejoras)
14. [Referencias](#referencias)

---

## 👋 Introducción

Este proyecto muestra cómo diseñar, desplegar y gestionar una infraestructura moderna basada en contenedores Docker. El objetivo es simular un entorno empresarial donde todos los servicios (bases de datos, LDAP, front/back, clientes, etc.) están aislados y orquestados, centralizando la autenticación y la gestión de usuarios mediante LDAP y NSS/PAM.

---

## 🏗️ Arquitectura del Sistema

### 🌐 Diagrama de Contexto

```
+------------------+       HTTP/Web      +--------------------------+
|                  |-------------------> |                          |
|   👤 Usuario     |                     |  Sistema de Servicios    |
|                  |<------------------- |  Docker (TFG_Brandon)    |
+------------------+      Web UI         +--------------------------+
```

### 📦 Diagrama de Contenedores (C4)

```
+------------------+    HTTP   +---------------------+    +-------------------+
|                  | --------> |  Frontend (PHP/JS)  |    |                   |
|   👤 Usuario     |           +---------------------+    |                   |
+------------------+                 |                   |                   |
                                     | REST API (HTTP)   |                   |
                                     v                   |                   |
                              +-------------------+      |                   |
                              | Backend (Flask)   |------+                   |
                              | Python            |   SQL (3306)            |
                              +-------------------+      |                   |
                                     |                   v                   |
                              +-------------------+  +-------------------+   |
                              |   MySQL/MariaDB   |  |  Scripts Bash     |   |
                              +-------------------+  +-------------------+   |
```

---

## 🛠️ Tecnologías Utilizadas

- **Lenguajes:** PHP, Python (Flask), Shell Script, HTML, CSS
- **Contenedores:** Docker, Docker Compose
- **Base de datos:** MySQL 8.0/MariaDB
- **Autenticación centralizada:** OpenLDAP, NSS/PAM LDAP
- **Frontend:** PHP/HTML/CSS/JS
- **Backend:** Python (Flask)
- **Scripts:** Bash para gestión y automatización

---

## 🗃️ Estructura del Proyecto

```
TFG_Brandon/
├── backend/              # Backend Python/Flask
│   ├── app.py
│   └── requirements.txt
├── frontend/             # Frontend PHP/HTML/CSS
│   ├── index.html
│   ├── styles.css
│   └── main.js
├── db/                   # Scripts de base de datos
│   └── init.sql
├── ldap/                 # Configuración y volúmenes de LDAP
│   ├── config/
│   └── data/
├── scripts/              # Scripts de gestión
│   ├── arrancar.sh
│   ├── reinicio.sh
│   └── apagar.sh
├── docker-compose.yml
├── Dockerfile
├── README.md
├── .env
└── ...
```

---

## ⚡ Instalación y Despliegue

### Requisitos previos

- Docker y Docker Compose instalados
- Git

### Pasos rápidos

1. **Clona el repositorio**
   ```bash
   git clone https://github.com/BitBrandon/TFG_Brandon.git
   cd TFG_Brandon
   ```

2. **Configura tu entorno**
   ```bash
   cp .env.example .env
   # Edita .env según lo que necesites (puertos, claves, etc.)
   ```

3. **Arranca los servicios**
   ```bash
   docker-compose up --build -d
   # O usa el script
   ./scripts/arrancar.sh
   ```

4. **¡Listo!**
   - Frontend: [http://localhost:8080](http://localhost:8080)
   - API: [http://localhost:5000/api](http://localhost:5000/api)
   - MySQL: puerto 3306

---

## 📡 Acceso a Clientes y Pruebas LDAP

### 🖥️ Acceso a clientes simulados por SSH (desde el host)

Cada cliente está accesible vía SSH desde tu máquina anfitriona (host) usando los siguientes puertos mapeados:

| Contenedor           | Puerto SSH | Hostname interno               |
|----------------------|------------|-------------------------------|
| cliente-trabajador1  | 2221       | trabajador1.mayorista.local   |
| cliente-trabajador2  | 2222       | trabajador2.mayorista.local   |
| cliente-jefeit       | 2223       | jefeit.mayorista.local        |
| cliente-jefe         | 2224       | jefe.mayorista.local          |

Conéctate así desde tu host:
```bash
ssh juan@localhost -p 2221
```
*(Sustituye `juan` por cualquier usuario LDAP válido)*

---

### 🔄 Acceso SSH entre clientes (por red Docker interna)

Los contenedores pueden conectarse entre sí usando la red interna de Docker, sin necesidad de puertos mapeados.  
Esto es ideal para simular un entorno real de empresa, donde los equipos se comunican por nombre o IP interna.

#### **Ejemplo: acceso desde un trabajador a otro**

1. **Entra en el contenedor origen** (por ejemplo, trabajador1):
   ```bash
   docker exec -it cliente-trabajador1 bash
   ```
2. **Cambia a otro usuario si quieres (opcional):**
   ```bash
   su ana
   ```
3. **Haz SSH al otro trabajador usando la IP interna:**
   ```bash
   ssh juan@192.168.0.51
   ```
   *(o usa el nombre del contenedor si tienes bien definida la red en docker-compose: `ssh juan@cliente-trabajador2`)*

4. **Pon la contraseña LDAP. Si la autenticación es correcta, el sistema creará el home automáticamente (si usas pam_mkhomedir).**

> **Nota:**  
> Puedes ver la IP interna de un contenedor ejecutando:
> ```bash
> docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' cliente-trabajador2
> ```
> Para que los nombres de contenedor funcionen como DNS, asegúrate de que todos los servicios están en la misma red definida en `docker-compose.yml`.

---

### 🔍 Pruebas y comprobaciones útiles

- Verifica usuario LDAP:
  ```bash
  getent passwd juan
  ```
- Verifica grupo LDAP:
  ```bash
  getent group trabajadores
  ```
- Comprueba acceso SSH y creación automática de home:
  ```bash
  ssh juan@localhost -p 2221
  ```
  o (desde otro contenedor):
  ```bash
  ssh juan@cliente-trabajador2
  ```

Para ver todos los usuarios LDAP con home:
```bash
getent passwd | grep /home
```

---

### ⚠️ Ten en cuenta

- El mapeo de puertos (ej: 2221:22) **solo es necesario para acceder desde fuera de Docker** (tu PC/host).  
  Para conexión entre contenedores, usa el puerto 22 y la IP/nombre interno.
- Si ves errores como `No route to host` al conectar entre contenedores, asegúrate de que todos están en la misma red de Docker (revisa tu `docker-compose.yml`).
- Si ves errores de “Connection closed” o “Permission denied”, revisa que los usuarios tengan shell válido, home, y que la configuración LDAP/PAM sea correcta.

---

**¡Ya puedes simular un entorno de oficina realista con identidades centralizadas y acceso seguro por SSH entre todos los clientes!**

---

## ⚙️ Scripts de Gestión y Automatización

- `arrancar.sh`: Arranca todos los servicios, limpia estados antiguos y verifica salud.
- `reinicio.sh`: Reinicia el entorno desde cero, asegurando limpieza y persistencia.
- `apagar.sh`: Detiene los servicios y realiza backups automáticos.

Recomendación: ejecuta siempre los scripts desde la raíz del proyecto y revisa los mensajes de consola.

---

## 🧑‍💻 Uso y Ejemplos Prácticos

- Probar la API:
  ```bash
  curl -v http://localhost:5000/api/endpoint
  ```
- Comprobar el frontend:
  ```bash
  nc -zv localhost 8080
  ```
- Entrar a la base de datos:
  ```bash
  docker exec -it <db_container> mysql -u root -p
  ```

---

## ✅ Pruebas y Validación

- Acceso web, API y base de datos desde host y contenedores
- Pruebas de autenticación con usuarios LDAP en clientes
- Verificación de persistencia de datos tras reinicios
- Logs y comandos de troubleshooting incluidos

---

## 🛟 Resolución de Problemas

| Problema                    | Motivo típico                   | Solución                          |
|-----------------------------|---------------------------------|-----------------------------------|
| Puerto ocupado              | Otro servicio usando el puerto  | Cambia el puerto o libera el otro |
| Permisos en volúmenes       | Usuario del host incorrecto     | Ajusta permisos con `chmod/chown` |
| Servicio no arranca         | Falta config o dependencias     | Mira los logs y .env              |
| Servicios no se ven         | Red Docker mal configurada      | Revisa `docker-compose.yml`       |
| LDAP sin datos              | Falta inicialización del DN     | Añade LDIF o reinicia volúmenes   |
| SSH rechaza usuarios LDAP   | Shell inválido o sin home       | Ajusta shell y pam_mkhomedir      |
| No route to host (SSH entre contenedores) | Los contenedores no comparten red Docker interna | Añade todos los servicios a la misma red en `docker-compose.yml` |

---

## 🏁 Conclusión Final

A lo largo de este proyecto se ha logrado desplegar y validar una infraestructura dockerizada robusta y segura, con centralización de identidades mediante LDAP y automatización de tareas administrativas. La arquitectura permite simular un entorno empresarial realista, facilitando la gestión y el aprendizaje sobre integración de servicios, seguridad y administración de sistemas.

---

## 🙏 Agradecimientos

Gracias a profesores/as, compañeros/as, la comunidad open source y a mi entorno personal por el apoyo durante el desarrollo de este proyecto.

---

## 🚧 Roadmap y Futuras Mejoras

- [ ] Añadir tests automáticos
- [ ] Mejorar los scripts de gestión
- [ ] Añadir más ejemplos prácticos y documentación avanzada
- [ ] Automatizar despliegue CI/CD
- [ ] Integrar monitorización y alertas

---

## 📚 Referencias

1. Docker Documentation – https://docs.docker.com/
2. OpenLDAP Administrator's Guide – https://www.openldap.org/doc/admin24/
3. MariaDB Knowledge Base – https://mariadb.com/kb/en/
4. Apache HTTP Server Documentation – https://httpd.apache.org/docs/
5. Linux PAM – https://linux-pam.org/
6. PHP LDAP Manual – https://www.php.net/manual/en/book.ldap.php
7. Docker Compose Documentation – https://docs.docker.com/compose/
8. LDAP System Administration, Gerald Carter, O’Reilly Media, 2003.
9. SSH Security Best Practices – https://www.ssh.com/academy/ssh/security-best-practices

---

*¿Tienes dudas o quieres contribuir? ¡Abre un issue o contacta!*