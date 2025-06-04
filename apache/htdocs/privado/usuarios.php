<?php
// Comprueba si el usuario está autenticado por Apache (LDAP)
$user_uid = $_SERVER['REMOTE_USER'] ?? '';
if (!$user_uid) {
    // Si no está autenticado, redirige al login
    header("Location: /index.html");
    exit();
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8" />
  <title>Gestión de Usuarios</title>
  <link rel="stylesheet" href="../estilos.css" />
</head>
<body>
<!-- Partículas decorativas -->
<div class="particle particle1"></div>
<div class="particle particle2"></div>
<div class="particle particle3"></div>
<div class="particle particle4"></div>
<div class="particle particle5"></div>
<div class="particle particle6"></div>
<div class="particle particle7"></div>
<div class="particle particle8"></div>
<div class="particle particle9"></div>
<div class="particle particle10"></div>
<div class="particle particle11"></div>

<div class="panel-container">
  <h2>Usuarios</h2>
  <table id="usuarios-table">
    <thead>
      <tr>
        <th>ID</th>
        <th>Nombre</th>
        <th>Email</th>
        <th>Teléfono</th>
        <th>Dirección</th>
        <th>Acciones</th>
      </tr>
    </thead>
    <tbody></tbody>
  </table>
  <h3>Crear nuevo usuario</h3>
  <form id="nuevo-usuario-form" autocomplete="off">
    <input type="text" name="nombre" placeholder="Nombre" required />
    <input type="email" name="email" placeholder="Email" required />
    <input type="text" name="telefono" placeholder="Teléfono" required />
    <input type="text" name="direccion" placeholder="Dirección" required />
    <button type="submit" class="boton-accion">Crear</button>
  </form>
</div>
<script>
const API_URL = "http://localhost:5000/usuarios/";

async function cargarUsuarios() {
  try {
    const res = await fetch(API_URL);
    const usuarios = await res.json();
    const tbody = document.querySelector("#usuarios-table tbody");
    tbody.innerHTML = "";
    usuarios.forEach(user => {
      tbody.innerHTML += `
        <tr>
          <td>${user.id ?? ''}</td>
          <td>${user.nombre ?? ''}</td>
          <td>${user.email ?? ''}</td>
          <td>${user.telefono ?? ''}</td>
          <td>${user.direccion ?? ''}</td>
          <td>
            <button class="boton-accion" onclick="eliminarUsuario(${user.id})">Eliminar</button>
            <button class="boton-accion" onclick="editarUsuario(${user.id}, '${user.nombre}', '${user.email}', '${user.telefono}', '${user.direccion}')">Editar</button>
          </td>
        </tr>`;
    });
  } catch (err) {
    alert("No se pudo cargar la lista de usuarios.");
  }
}
cargarUsuarios();

document.getElementById("nuevo-usuario-form").onsubmit = async function(e) {
  e.preventDefault();
  const data = Object.fromEntries(new FormData(this));
  await fetch(API_URL, {
    method: "POST",
    headers: {"Content-Type": "application/json"},
    body: JSON.stringify(data)
  });
  this.reset();
  cargarUsuarios();
};

async function eliminarUsuario(id) {
  if (!confirm("¿Seguro?")) return;
  await fetch(API_URL + id, {method: "DELETE"});
  cargarUsuarios();
}

function editarUsuario(id, nombre, email, telefono, direccion) {
  const newNombre = prompt("Nuevo nombre:", nombre);
  const newEmail = prompt("Nuevo email:", email);
  const newTelefono = prompt("Nuevo teléfono:", telefono);
  const newDireccion = prompt("Nueva dirección:", direccion);
  if (newNombre && newEmail && newTelefono && newDireccion) {
    fetch(API_URL + id, {
      method: "PUT",
      headers: {"Content-Type": "application/json"},
      body: JSON.stringify({
        nombre: newNombre,
        email: newEmail,
        telefono: newTelefono,
        direccion: newDireccion
      })
    }).then(cargarUsuarios);
  }
}
</script>
</body>
</html>