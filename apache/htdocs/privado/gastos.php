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
  <title>Gestión de Gastos</title>
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
  <h2>Gastos</h2>
  <table id="gastos-table">
    <thead>
      <tr>
        <th>ID</th>
        <th>Descripción</th>
        <th>Monto</th>
        <th>Fecha</th>
        <th>Acciones</th>
      </tr>
    </thead>
    <tbody></tbody>
  </table>
  <h3>Crear nuevo gasto</h3>
  <form id="nuevo-gasto-form" autocomplete="off">
    <input type="text" name="descripcion" placeholder="Descripción" required />
    <input type="number" name="monto" placeholder="Monto" required />
    <input type="date" name="fecha" required />
    <button type="submit" class="boton-accion">Crear</button>
  </form>
</div>
<script>
const API_URL = "http://localhost:5000/gastos/";

async function cargarGastos() {
  try {
    const res = await fetch(API_URL);
    const gastos = await res.json();
    const tbody = document.querySelector("#gastos-table tbody");
    tbody.innerHTML = "";
    gastos.forEach(gasto => {
      tbody.innerHTML += `
        <tr>
          <td>${gasto.id ?? ''}</td>
          <td>${gasto.descripcion ?? ''}</td>
          <td>${gasto.monto ?? ''}</td>
          <td>${gasto.fecha ?? ''}</td>
          <td>
            <button class="boton-accion" onclick="eliminarGasto(${gasto.id})">Eliminar</button>
            <button class="boton-accion" onclick="editarGasto(${gasto.id}, '${gasto.descripcion}', ${gasto.monto}, '${gasto.fecha}')">Editar</button>
          </td>
        </tr>`;
    });
  } catch (err) {
    alert("No se pudo cargar la lista de gastos.");
  }
}
cargarGastos();

document.getElementById("nuevo-gasto-form").onsubmit = async function(e) {
  e.preventDefault();
  const data = Object.fromEntries(new FormData(this));
  data.monto = parseFloat(data.monto);
  await fetch(API_URL, {
    method: "POST",
    headers: {"Content-Type": "application/json"},
    body: JSON.stringify(data)
  });
  this.reset();
  cargarGastos();
};

async function eliminarGasto(id) {
  if (!confirm("¿Seguro?")) return;
  await fetch(API_URL + id, {method: "DELETE"});
  cargarGastos();
}

function editarGasto(id, descripcion, monto, fecha) {
  const newDescripcion = prompt("Nueva descripción:", descripcion);
  const newMonto = prompt("Nuevo monto:", monto);
  const newFecha = prompt("Nueva fecha (YYYY-MM-DD):", fecha);
  if (newDescripcion && newMonto && newFecha) {
    fetch(API_URL + id, {
      method: "PUT",
      headers: {"Content-Type": "application/json"},
      body: JSON.stringify({
        descripcion: newDescripcion,
        monto: parseFloat(newMonto),
        fecha: newFecha
      })
    }).then(cargarGastos);
  }
}
</script>
</body>
</html>