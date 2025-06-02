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
  <title>Gestión de Ventas</title>
  <link rel="stylesheet" href="../estilos.css" />
</head>
<body>
<div class="panel-container">
  <h2>Ventas</h2>
  <table id="ventas-table" border="1">
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
  <h3>Crear nueva venta</h3>
  <form id="nueva-venta-form">
    <input type="date" name="fecha" required />
    <input type="number" name="id_cliente" placeholder="ID Cliente" required />
    <input type="number" name="total" placeholder="Total" required />
    <button type="submit">Crear</button>
  </form>
</div>
<script>
const API_URL = "http://localhost:5000/ventas/";

async function cargarVentas() {
  const res = await fetch(API_URL);
  const ventas = await res.json();
  const tbody = document.querySelector("#ventas-table tbody");
  tbody.innerHTML = "";
  ventas.forEach(venta => {
    tbody.innerHTML += `
      <tr>
        <td>${venta.id}</td>
        <td>${venta.fecha}</td>
        <td>${venta.id_cliente}</td>
        <td>${venta.total}</td>
        <td>
          <button onclick="eliminarVenta(${venta.id})">Eliminar</button>
          <button onclick="editarVenta(${venta.id}, '${venta.fecha}', ${venta.id_cliente}, ${venta.total})">Editar</button>
        </td>
      </tr>`;
  });
}
cargarVentas();

document.getElementById("nueva-venta-form").onsubmit = async function(e) {
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
  cargarVentas();
};

async function eliminarVenta(id) {
  if (!confirm("¿Seguro?")) return;
  await fetch(API_URL + id, {method: "DELETE"});
  cargarVentas();
}

function editarVenta(id, fecha, id_cliente, total) {
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
    }).then(cargarVentas);
  }
}
</script>
</body>
</html>