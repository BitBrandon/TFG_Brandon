# Instrucciones para iniciar el entorno LDAP desde cero en la presentación

## Paso 1: Abre una terminal en la carpeta del proyecto

Asegúrate de estar en la raíz donde está el archivo `docker-compose.yml` y tu script (por ejemplo, `reinicia_ldap.sh`).

---

## Paso 2: Ejecuta el script de reinicio **(SIEMPRE desde la raíz del proyecto)**

```bash
./reinicia_ldap.sh
```

- El script hará todo automáticamente:  
  - Parará y eliminará todos los contenedores y volúmenes.
  - Borrará completamente los directorios `./ldap/data` y `./ldap/config`.
  - Comprobará los LDIFs críticos.
  - Reconstruirá las imágenes si es necesario.
  - Levantará todos los contenedores desde cero.
  - Esperará a que el servidor LDAP esté disponible.
  - Aplicará overlays y configuraciones extra.
  - Hará comprobaciones automáticas y te mostrará el estado de todo.

---

## Paso 3: Espera a que termine el script

- Cuando veas el mensaje:
  ```
  === Fin de comprobaciones automáticas ===
  Puedes revisar los resultados arriba.
  Presiona ENTER para terminar.
  ```
- Revisa que todas las comprobaciones son "OK".  
  Si ves algún "ERROR", lee el mensaje para saber qué ha fallado (normalmente será algún LDIF faltante, problema de overlays, etc.).

---

## Paso 4: Presiona ENTER para finalizar

- El entorno ya está listo para hacer pruebas, acceder a PHPLDAPAdmin, conectarte por SSH a los clientes, demostrar autenticación, etc.

---

## ¿Qué hago si quiero reiniciar TODO de nuevo durante la presentación?

- **Solo tienes que ejecutar otra vez:**
  ```bash
  ./reinicia_ldap.sh
  ```
- ¡Y tendrás de nuevo todo desde cero, igual que la primera vez!

---

## Consejos para la presentación

- Ten abierta una segunda terminal por si necesitas consultar los logs:
  ```bash
  docker logs ldap-server
  ```
- Si necesitas comprobar usuarios/grupos desde los clientes:
  ```bash
  docker exec cliente-trabajador1 getent passwd | grep mayorista
  docker exec cliente-trabajador1 getent group | grep mayorista
  ```
- Si quieres entrar a PHPLDAPAdmin, accede a [http://localhost:8080](http://localhost:8080) (o el puerto que uses).

---

## Resumen

1. **Ejecuta**: `./reinicia_ldap.sh`
2. **Espera los OK** y pulsa ENTER.
3. ¡Demuestra lo que necesites!
4. ¿Quieres repetir? Ejecuta de nuevo el script.

---

¡Así tendrás la máxima garantía de que tu demo LDAP empieza siempre desde cero y sin sorpresas!
