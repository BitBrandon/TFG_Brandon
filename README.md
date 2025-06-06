# 🚀 TFG: Servicios Docker y Configuración

¡Bienvenido/a! Este es el repositorio de mi Trabajo de Fin de Grado, donde verás cómo montar una arquitectura de servicios web usando Docker, con scripts para facilitarte la vida y muchas pruebas para que nada falle.  
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
6. [Scripts de Gestión y Automatización](#scripts-de-gestión-y-automatización)
7. [Uso y Ejemplos Prácticos](#uso-y-ejemplos-prácticos)
8. [Pruebas y Validación](#pruebas-y-validación)
9. [Resolución de Problemas](#resolución-de-problemas)
10. [Agradecimientos](#agradecimientos)
11. [Roadmap y Futuras Mejoras](#roadmap-y-futuras-mejoras)

---

## 👋 Introducción

Este proyecto es un ejemplo de cómo montar una aplicación web moderna usando contenedores Docker y buenas prácticas de automatización.  
Incluye frontend (PHP), backend (Python/Flask), base de datos (MySQL) y scripts para arrancar, reiniciar y apagar todo fácil y seguro.  
¡Ideal para aprender y replicar en tus propios proyectos!

---

## 🏗️ Arquitectura del Sistema

Aquí tienes cómo se relacionan los componentes principales del proyecto.

### 🌐 Diagrama de Contexto

```
+------------------+       HTTP/Web       +--------------------------+
|                  |--------------------->|                          |
|   👤 Usuario     |                      |  Sistema de Servicios    |
|                  |<---------------------|  Docker (TFG_Brandon)    |
+------------------+         Web UI       +--------------------------+
```

### 📦 Diagrama de Contenedores (C4)

```
+------------------+          +---------------------+         +-------------------+
|                  |  HTTP    |  Frontend           |         |                   |
|   👤 Usuario     +--------->|  (PHP/HTML/CSS)     |         |                   |
|  (Navegador)     |          +---------------------+         |                   |
+------------------+                |                         |                   |
                                    | REST API (HTTP)         |                   |
                                    v                         |                   |
                              +-------------------+           |                   |
                              | Backend (Flask)   |-----------+                   |
                              | Python            |   SQL (3306)                 |
                              +-------------------+           |                   |
                                    |                         v                   |
                              +-------------------+   +-------------------+       |
                              |     MySQL         |<--+   Scripts Bash    |       |
                              +-------------------+   +-------------------+       |
```
> Nota: Los scripts de bash (`arrancar.sh`, `reinicio.sh`, `apagar.sh`) gestionan la vida de los contenedores de manera segura y ayudan a mantener los datos tras reinicios.  

---

## 🛠️ Tecnologías Utilizadas

- **Lenguajes:** PHP, Python (Flask), Shell Script, HTML, CSS
- **Contenedores:** Docker, Docker Compose
- **Base de Datos:** MySQL 8.0
- **Imágenes base recomendadas:**  
  - `php:8.x-apache`  
  - `python:3.10-slim`  
  - `mysql:8.0`
- **Scripts:**  
  - `arrancar.sh` (Inicia todo)
  - `reinicio.sh` (Reinicia de forma segura)
  - `apagar.sh` (Apaga todo)
- **Otros:**  
  - Volúmenes Docker para persistencia de datos

---

## 🗃️ Estructura del Proyecto

```
TFG_Brandon/
├── backend/              # Backend Python/Flask
│   ├── app.py
│   └── requirements.txt
├── frontend/             # Front PHP/HTML/CSS
│   ├── index.html
│   ├── styles.css
│   └── main.js
├── db/                   # Scripts de base de datos
│   └── init.sql
├── scripts/              # Utilidades de gestión
│   ├── arrancar.sh
│   ├── reinicio.sh
│   └── apagar.sh
├── docker-compose.yml
├── Dockerfile            # (En cada servicio)
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

1. **Clona el repo**
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

## ⚙️ Scripts de Gestión y Automatización

Este proyecto incluye una serie de scripts Bash diseñados para facilitar la gestión completa del entorno Dockerizado. Estos scripts permiten arrancar, reiniciar y apagar todos los servicios de forma segura, asegurando la persistencia de los datos y la consistencia del sistema.

### 📋 Resumen de Scripts

| Script           | Propósito principal                                                    |
|------------------|-----------------------------------------------------------------------|
| `arrancar.sh`    | Arranca todos los servicios, limpia estados antiguos y verifica salud |
| `reinicio.sh`    | Reinicia el entorno desde cero, asegurando limpieza y persistencia    |
| `apagar.sh`      | Apaga los servicios y realiza copias de seguridad (backups)           |

---

### 🚦 arrancar.sh

- **Función:**  
  Prepara el entorno eliminando posibles restos de sesiones anteriores (por ejemplo, leases de DHCP), reconstruye las imágenes sin usar caché, levanta los servicios con Docker Compose y realiza comprobaciones automáticas de estado, especialmente para LDAP y los clientes definidos.
- **Uso:**
  ```bash
  ./scripts/arrancar.sh
  ```
- **Qué hace por dentro:**  
  - Limpia archivos temporales y antiguos.
  - Fuerza la reconstrucción de imágenes Docker.
  - Espera a que los servicios estén listos y verifica que LDAP responde.
  - Muestra un resumen del estado de los clientes y sus conexiones LDAP.

---

### ♻️ reinicio.sh

- **Función:**  
  Realiza un reinicio completo del entorno, eliminando contenedores y volúmenes, limpiando directorios de datos locales (especialmente para LDAP), verifica los archivos de configuración, reconstruye imágenes y vuelve a levantar los servicios.
- **Uso:**
  ```bash
  ./scripts/reinicio.sh
  ```
- **Qué hace por dentro:**  
  - Detiene y elimina contenedores/volúmenes.
  - Borra datos locales de LDAP para arrancar “en limpio”.
  - Comprueba la existencia y el contenido de archivos LDIF.
  - Reconstruye imágenes Docker desde cero.
  - Espera que todo el entorno esté listo y LDAP responda.
- **Cuándo usarlo:**  
  Cuando necesites reiniciar todo el entorno desde cero (por ejemplo, para pruebas limpias o tras cambios importantes).

---

### 📴 apagar.sh

- **Función:**  
  Detiene todos los servicios del entorno y realiza backups automáticos de los datos críticos: LDAP, MariaDB, Apache y la API.
- **Uso:**
  ```bash
  ./scripts/apagar.sh
  ```
- **Qué hace por dentro:**  
  - Crea copias de seguridad (tar.gz o SQL) de los datos y configuraciones clave.
  - Mantiene solo los 5 backups más recientes para ahorrar espacio.
  - Detiene todos los servicios con Docker Compose.
- **Cuándo usarlo:**  
  Antes de apagar el sistema o hacer cambios mayores, para garantizar la seguridad e integridad de los datos.

---

> ⚠️ **Sugerencias:**  
> - Todos los scripts pueden requerir permisos de ejecución (`chmod +x scripts/*.sh`).
> - Es recomendable ejecutarlos desde la raíz del proyecto.
> - Revisa siempre los mensajes de color en consola: verde = OK, amarillo = advertencia, rojo = error.

---

### Ejemplo de ciclo de vida recomendado

```bash
# Arrancar el entorno
./scripts/arrancar.sh

# ...trabaja, haz pruebas, etc...

# Reiniciar (si necesitas resetear todo)
./scripts/reinicio.sh

# Apagar y respaldar
./scripts/apagar.sh
```

---

## 🧑‍💻 Uso y Ejemplos Prácticos

- **Probar la API**
  ```bash
  curl -v http://localhost:5000/api/endpoint
  ```

- **Comprobar el frontend**
  ```bash
  nc -zv localhost 8080
  ```

- **Entrar a la base de datos**
  ```bash
  docker exec -it <db_container> mysql -u root -p
  ```

- **Reiniciar todo sin perder datos**
  ```bash
  ./scripts/reinicio.sh
  ```

---

## ✅ Pruebas y Validación

- **¿Funciona el front?**
  ```bash
  curl -v http://localhost:8080
  nc -zv localhost 8080
  ```

- **¿Funciona la API?**
  ```bash
  curl -v http://localhost:5000/api/endpoint
  ```

- **¿La base de datos responde?**
  ```bash
  nc -zv localhost 3306
  docker exec -it <db_container> mysql -u root -p
  ```

- **¿Red entre servicios?**
  ```bash
  docker exec -it frontend_container ping -c 3 backend_container
  ```

- **¿Persisten los datos?**
  1. Crea algo vía API o base de datos.
  2. Reinicia: `./scripts/reinicio.sh`
  3. Comprueba que sigue ahí.

- **¿Logs bien?**
  ```bash
  docker logs <nombre_contenedor>
  ```

---

## 🛟 Resolución de Problemas

| Problema                    | Motivo típico                   | Solución                          |
|-----------------------------|---------------------------------|-----------------------------------|
| Puerto ocupado              | Otro servicio usando el puerto  | Cambia el puerto o libera el otro |
| Permisos en volúmenes       | Usuario de host incorrecto      | Ajusta permisos con `chmod/chown` |
| Servicio no arranca         | Falta config o dependencias     | Mira los logs y .env              |
| Servicios no se ven         | Red Docker mal configurada      | Revisa `docker-compose.yml`       |

---

## 🙏 Agradecimientos

Gracias a profes, compis, comunidad open source y sobre todo a mi novia!.  
Y a ti por pasarte por aquí 😊

---

## 🚧 Roadmap y Futuras Mejoras

- [ ] Añadir tests automáticos
- [ ] Mejorar los scripts de gestión
- [ ] Añadir más ejemplos prácticos
- [ ] Automatizar despliegue CI/CD

---

*Si tienes dudas o quieres contribuir, ¡abre un issue o contacta!*