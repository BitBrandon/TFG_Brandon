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
  <title>Gestión de Clientes</title>
  <link rel="stylesheet" href="../estilos.css" />
</head>
<body>
<div class="panel-container">
  <h2>Clientes</h2>
  <table id="clientes-table" border="1">
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
  <h3>Crear nuevo cliente</h3>
  <form id="nuevo-cliente-form">
    <input type="text" name="nombre" placeholder="Nombre" required />
    <input type="email" name="email" placeholder="Email" required />
    <input type="text" name="telefono" placeholder="Teléfono" required />
    <input type="text" name="direccion" placeholder="Dirección" required />
    <button type="submit">Crear</button>
  </form>
</div>
<script>
const API_URL = "http://localhost:5000/clientes/";

async function cargarClientes() {
  const res = await fetch(API_URL);
  const clientes = await res.json();
  const tbody = document.querySelector("#clientes-table tbody");
  tbody.innerHTML = "";
  clientes.forEach(cliente => {
    tbody.innerHTML += `
      <tr>
        <td>${cliente.id}</td>
        <td>${cliente.nombre}</td>
        <td>${cliente.email}</td>
        <td>${cliente.telefono}</td>
        <td>${cliente.direccion}</td>
        <td>
          <button onclick="eliminarCliente(${cliente.id})">Eliminar</button>
          <button onclick="editarCliente(${cliente.id}, '${cliente.nombre}', '${cliente.email}', '${cliente.telefono}', '${cliente.direccion}')">Editar</button>
        </td>
      </tr>`;
  });
}
cargarClientes();

document.getElementById("nuevo-cliente-form").onsubmit = async function(e) {
  e.preventDefault();
  const data = Object.fromEntries(new FormData(this));
  await fetch(API_URL, {
    method: "POST",
    headers: {"Content-Type": "application/json"},
    body: JSON.stringify(data)
  });
  this.reset();
  cargarClientes();
};

async function eliminarCliente(id) {
  if (!confirm("¿Seguro?")) return;
  await fetch(API_URL + id, {method: "DELETE"});
  cargarClientes();
}

function editarCliente(id, nombre, email, telefono, direccion) {
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
    }).then(cargarClientes);
  }
}
</script>
</body>
</html>