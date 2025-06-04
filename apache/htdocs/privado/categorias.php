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
  <title>Gestión de Categorías</title>
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
  <h2>Categorías</h2>
  <table id="categorias-table">
    <thead>
      <tr>
        <th>ID</th>
        <th>Nombre</th>
        <th>Acciones</th>
      </tr>
    </thead>
    <tbody></tbody>
  </table>
  <h3>Crear nueva categoría</h3>
  <form id="nueva-categoria-form" autocomplete="off">
    <input type="text" name="nombre" placeholder="Nombre" required />
    <button type="submit" class="boton-accion">Crear</button>
  </form>
</div>
<script>
const API_URL = "http://localhost:5000/categorias/";

async function cargarCategorias() {
  try {
    const res = await fetch(API_URL);
    const categorias = await res.json();
    const tbody = document.querySelector("#categorias-table tbody");
    tbody.innerHTML = "";
    categorias.forEach(categoria => {
      tbody.innerHTML += `
        <tr>
          <td>${categoria.id ?? ''}</td>
          <td>${categoria.nombre ?? ''}</td>
          <td>
            <button class="boton-accion" onclick="eliminarCategoria(${categoria.id})">Eliminar</button>
            <button class="boton-accion" onclick="editarCategoria(${categoria.id}, '${categoria.nombre}')">Editar</button>
          </td>
        </tr>`;
    });
  } catch (err) {
    alert("No se pudo cargar la lista de categorías.");
  }
}
cargarCategorias();

document.getElementById("nueva-categoria-form").onsubmit = async function(e) {
  e.preventDefault();
  const data = Object.fromEntries(new FormData(this));
  await fetch(API_URL, {
    method: "POST",
    headers: {"Content-Type": "application/json"},
    body: JSON.stringify(data)
  });
  this.reset();
  cargarCategorias();
};

async function eliminarCategoria(id) {
  if (!confirm("¿Seguro?")) return;
  await fetch(API_URL + id, {method: "DELETE"});
  cargarCategorias();
}

function editarCategoria(id, nombre) {
  const newNombre = prompt("Nuevo nombre:", nombre);
  if (newNombre) {
    fetch(API_URL + id, {
      method: "PUT",
      headers: {"Content-Type": "application/json"},
      body: JSON.stringify({nombre: newNombre})
    }).then(cargarCategorias);
  }
}
</script>
</body>
</html>