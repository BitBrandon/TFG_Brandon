# 🚀 TFG: Arquitectura de Servicios Dockerizados y Centralización de Identidades

¡Bienvenido/a! Este repositorio contiene el Trabajo de Fin de Grado de BitBrandon, donde aprenderás a desplegar y gestionar una arquitectura completa de servicios utilizando Docker, integrando autenticación centralizada mediante LDAP, scripts de automatización y pruebas para un entorno empresarial realista y seguro.

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

Este proyecto muestra cómo diseñar, desplegar y gestionar una infraestructura moderna basada en contenedores Docker. El objetivo es simular un entorno empresarial donde todos los servicios (bases de datos, frontend, backend, autenticación, etc.) se integran y administran de forma centralizada, eficiente y segura. Es ideal tanto para aprender como para replicar en entornos reales o académicos.

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

### 🖥️ Acceso a clientes simulados por SSH

Cada cliente está accesible vía SSH en el puerto correspondiente al host. Ejemplo:

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
*(Sustituye juan por cualquier usuario LDAP válido)*

### 🔍 Pruebas de usuarios y grupos LDAP

Desde cualquier cliente:
- Verifica usuario:
  ```bash
  getent passwd juan
  ```
- Verifica grupo:
  ```bash
  getent group trabajadores
  ```
- Comprueba acceso SSH y creación automática de home:
  ```bash
  ssh juan@localhost -p 2221
  ```

Para ver todos los usuarios LDAP con home:
```bash
getent passwd | grep /home
```

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

---

## 🏁 Conclusión Final

A lo largo de este proyecto se ha logrado desplegar y validar una infraestructura dockerizada robusta y segura, con centralización de identidades mediante LDAP y automatización de tareas administrativas. El sistema es escalable, reproducible y adaptable tanto a entornos reales como académicos, demostrando las ventajas de la virtualización ligera y la gestión centralizada de servicios y usuarios.

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
6. nss-pam-ldapd – https://arthurdejong.org/nss-pam-ldapd/
7. PHP LDAP Manual – https://www.php.net/manual/en/book.ldap.php
8. Docker Compose Documentation – https://docs.docker.com/compose/
9. LDAP System Administration, Gerald Carter, O’Reilly Media, 2003.
10. SSH Security Best Practices – https://www.ssh.com/academy/ssh/security-best-practices

---

*¿Tienes dudas o quieres contribuir? ¡Abre un issue o contacta!*