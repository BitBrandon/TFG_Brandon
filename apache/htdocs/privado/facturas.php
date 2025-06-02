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
  <title>Gestión de Facturas</title>
  <link rel="stylesheet" href="../estilos.css" />
</head>
<body>
<div class="panel-container">
  <h2>Facturas</h2>
  <table id="facturas-table" border="1">
    <thead>
      <tr>
        <th>ID</th>
        <th>Fecha</th>
        <th>ID Cliente</th>
        <th>Total</th>
        <th>Acciones</th>
      </tr>
    </thead>
    <tbody></tbody>
  </table>
  <h3>Crear nueva factura</h3>
  <form id="nueva-factura-form">
    <input type="date" name="fecha" required />
    <input type="number" name="id_cliente" placeholder="ID Cliente" required />
    <input type="number" name="total" placeholder="Total" required />
    <button type="submit">Crear</button>
  </form>
</div>
<script>
const API_URL = "http://localhost:5000/facturas/";

async function cargarFacturas() {
  const res = await fetch(API_URL);
  const facturas = await res.json();
  const tbody = document.querySelector("#facturas-table tbody");
  tbody.innerHTML = "";
  facturas.forEach(factura => {
    tbody.innerHTML += `
      <tr>
        <td>${factura.id}</td>
        <td>${factura.fecha}</td>
        <td>${factura.id_cliente}</td>
        <td>${factura.total}</td>
        <td>
          <button onclick="eliminarFactura(${factura.id})">Eliminar</button>
          <button onclick="editarFactura(${factura.id}, '${factura.fecha}', ${factura.id_cliente}, ${factura.total})">Editar</button>
        </td>
      </tr>`;
  });
}
cargarFacturas();

document.getElementById("nueva-factura-form").onsubmit = async function(e) {
  e.preventDefault();
  const data = Object.fromEntries(new FormData(this));
  data.id_cliente = parseInt(data.id_cliente);
  data.total = parseFloat(data.total);
  await fetch(API_URL, {
    method: "POST",
    headers: {"Content-Type": "application/json"},
    body: JSON.stringify(data)
  });
  this.reset();
  cargarFacturas();
};

async function eliminarFactura(id) {
  if (!confirm("¿Seguro?")) return;
  await fetch(API_URL + id, {method: "DELETE"});
  cargarFacturas();
}

function editarFactura(id, fecha, id_cliente, total) {
  const newFecha = prompt("Nueva fecha (YYYY-MM-DD):", fecha);
  const newCliente = prompt("Nuevo ID Cliente:", id_cliente);
  const newTotal = prompt("Nuevo total:", total);
  if (newFecha && newCliente && newTotal) {
    fetch(API_URL + id, {
      method: "PUT",
      headers: {"Content-Type": "application/json"},
      body: JSON.stringify({
        fecha: newFecha,
        id_cliente: parseInt(newCliente),
        total: parseFloat(newTotal)
      })
    }).then(cargarFacturas);
  }
}
</script>
</body>
</html>