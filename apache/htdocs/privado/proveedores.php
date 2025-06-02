<?php
$user_uid = $_SERVER['REMOTE_USER'] ?? '';
if (!$user_uid) {
    header("Location: /index.html");
    exit();
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8" />
  <title>Gestión de Proveedores</title>
  <link rel="stylesheet" href="../estilos.css" />
</head>
<body>
<div class="panel-container">
  <h2>Proveedores</h2>
  <table id="proveedores-table" border="1">
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
  <h3>Crear nuevo proveedor</h3>
  <form id="nuevo-proveedor-form">
    <input type="text" name="nombre" placeholder="Nombre" required />
    <input type="email" name="email" placeholder="Email" required />
    <input type="text" name="telefono" placeholder="Teléfono" required />
    <input type="text" name="direccion" placeholder="Dirección" required />
    <button type="submit">Crear</button>
  </form>
</div>
<script>
const API_URL = "http://localhost:5000/proveedores/";

async function cargarProveedores() {
  const res = await fetch(API_URL);
  const proveedores = await res.json();
  const tbody = document.querySelector("#proveedores-table tbody");
  tbody.innerHTML = "";
  proveedores.forEach(proveedor => {
    tbody.innerHTML += `
      <tr>
        <td>${proveedor.id}</td>
        <td>${proveedor.nombre}</td>
        <td>${proveedor.email}</td>
        <td>${proveedor.telefono}</td>
        <td>${proveedor.direccion}</td>
        <td>
          <button onclick="eliminarProveedor(${proveedor.id})">Eliminar</button>
          <button onclick="editarProveedor(${proveedor.id}, '${proveedor.nombre}', '${proveedor.email}', '${proveedor.telefono}', '${proveedor.direccion}')">Editar</button>
        </td>
      </tr>`;
  });
}
cargarProveedores();

document.getElementById("nuevo-proveedor-form").onsubmit = async function(e) {
  e.preventDefault();
  const data = Object.fromEntries(new FormData(this));
  await fetch(API_URL, {
    method: "POST",
    headers: {"Content-Type": "application/json"},
    body: JSON.stringify(data)
  });
  this.reset();
  cargarProveedores();
};

async function eliminarProveedor(id) {
  if (!confirm("¿Seguro?")) return;
  await fetch(API_URL + id, {method: "DELETE"});
  cargarProveedores();
}

function editarProveedor(id, nombre, email, telefono, direccion) {
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
    }).then(cargarProveedores);
  }
}
</script>
</body>
</html>