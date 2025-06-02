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
  <title>Gestión de Logs</title>
  <link rel="stylesheet" href="../estilos.css" />
</head>
<body>
<div class="panel-container">
  <h2>Logs</h2>
  <table id="logs-table" border="1">
    <thead>
      <tr>
        <th>ID</th>
        <th>Usuario</th>
        <th>Acción</th>
        <th>Fecha</th>
        <th>Acciones</th>
      </tr>
    </thead>
    <tbody></tbody>
  </table>
  <h3>Crear nuevo log</h3>
  <form id="nuevo-log-form">
    <input type="text" name="usuario" placeholder="Usuario" required />
    <input type="text" name="accion" placeholder="Acción" required />
    <input type="datetime-local" name="fecha" required />
    <button type="submit">Crear</button>
  </form>
</div>
<script>
const API_URL = "http://localhost:5000/logs/";

async function cargarLogs() {
  const res = await fetch(API_URL);
  const logs = await res.json();
  const tbody = document.querySelector("#logs-table tbody");
  tbody.innerHTML = "";
  logs.forEach(log => {
    tbody.innerHTML += `
      <tr>
        <td>${log.id}</td>
        <td>${log.usuario}</td>
        <td>${log.accion}</td>
        <td>${log.fecha}</td>
        <td>
          <button onclick="eliminarLog(${log.id})">Eliminar</button>
          <button onclick="editarLog(${log.id}, '${log.usuario}', '${log.accion}', '${log.fecha}')">Editar</button>
        </td>
      </tr>`;
  });
}
cargarLogs();

document.getElementById("nuevo-log-form").onsubmit = async function(e) {
  e.preventDefault();
  const data = Object.fromEntries(new FormData(this));
  // Convierte fecha a formato "YYYY-MM-DD HH:MM:SS"
  data.fecha = data.fecha.replace("T", " ");
  await fetch(API_URL, {
    method: "POST",
    headers: {"Content-Type": "application/json"},
    body: JSON.stringify(data)
  });
  this.reset();
  cargarLogs();
};

async function eliminarLog(id) {
  if (!confirm("¿Seguro?")) return;
  await fetch(API_URL + id, {method: "DELETE"});
  cargarLogs();
}

function editarLog(id, usuario, accion, fecha) {
  const newUsuario = prompt("Nuevo usuario:", usuario);
  const newAccion = prompt("Nueva acción:", accion);
  const newFecha = prompt("Nueva fecha (YYYY-MM-DD HH:MM:SS):", fecha);
  if (newUsuario && newAccion && newFecha) {
    fetch(API_URL + id, {
      method: "PUT",
      headers: {"Content-Type": "application/json"},
      body: JSON.stringify({
        usuario: newUsuario,
        accion: newAccion,
        fecha: newFecha
      })
    }).then(cargarLogs);
  }
}
</script>
</body>
</html>