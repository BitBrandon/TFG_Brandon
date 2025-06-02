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
  <title>Gestión de Productos</title>
  <link rel="stylesheet" href="../estilos.css" />
</head>
<body>
<div class="panel-container">
  <h2>Productos</h2>
  <table id="productos-table" border="1">
    <thead>
      <tr>
        <th>ID</th>
        <th>Nombre</th>
        <th>Precio</th>
        <th>Stock</th>
        <th>ID Categoría</th>
        <th>ID Proveedor</th>
        <th>Acciones</th>
      </tr>
    </thead>
    <tbody></tbody>
  </table>
  <h3>Crear nuevo producto</h3>
  <form id="nuevo-producto-form">
    <input type="text" name="nombre" placeholder="Nombre" required />
    <input type="number" name="precio" placeholder="Precio" required />
    <input type="number" name="stock" placeholder="Stock" required />
    <input type="number" name="id_categoria" placeholder="ID Categoría" />
    <input type="number" name="id_proveedor" placeholder="ID Proveedor" />
    <button type="submit">Crear</button>
  </form>
</div>
<script>
const API_URL = "http://localhost:5000/productos/";

async function cargarProductos() {
  const res = await fetch(API_URL);
  const productos = await res.json();
  const tbody = document.querySelector("#productos-table tbody");
  tbody.innerHTML = "";
  productos.forEach(producto => {
    tbody.innerHTML += `
      <tr>
        <td>${producto.id}</td>
        <td>${producto.nombre}</td>
        <td>${producto.precio}</td>
        <td>${producto.stock}</td>
        <td>${producto.id_categoria ?? ''}</td>
        <td>${producto.id_proveedor ?? ''}</td>
        <td>
          <button onclick="eliminarProducto(${producto.id})">Eliminar</button>
          <button onclick="editarProducto(${producto.id}, '${producto.nombre}', ${producto.precio}, ${producto.stock}, ${producto.id_categoria ?? 'null'}, ${producto.id_proveedor ?? 'null'})">Editar</button>
        </td>
      </tr>`;
  });
}
cargarProductos();

document.getElementById("nuevo-producto-form").onsubmit = async function(e) {
  e.preventDefault();
  const data = Object.fromEntries(new FormData(this));
  data.precio = parseFloat(data.precio);
  data.stock = parseInt(data.stock);
  if (data.id_categoria) data.id_categoria = parseInt(data.id_categoria);
  if (data.id_proveedor) data.id_proveedor = parseInt(data.id_proveedor);
  await fetch(API_URL, {
    method: "POST",
    headers: {"Content-Type": "application/json"},
    body: JSON.stringify(data)
  });
  this.reset();
  cargarProductos();
};

async function eliminarProducto(id) {
  if (!confirm("¿Seguro?")) return;
  await fetch(API_URL + id, {method: "DELETE"});
  cargarProductos();
}

function editarProducto(id, nombre, precio, stock, id_categoria, id_proveedor) {
  const newNombre = prompt("Nuevo nombre:", nombre);
  const newPrecio = prompt("Nuevo precio:", precio);
  const newStock = prompt("Nuevo stock:", stock);
  const newCat = prompt("Nuevo ID Categoría:", id_categoria ?? '');
  const newProv = prompt("Nuevo ID Proveedor:", id_proveedor ?? '');
  if (newNombre && newPrecio && newStock) {
    fetch(API_URL + id, {
      method: "PUT",
      headers: {"Content-Type": "application/json"},
      body: JSON.stringify({
        nombre: newNombre,
        precio: parseFloat(newPrecio),
        stock: parseInt(newStock),
        id_categoria: newCat ? parseInt(newCat) : null,
        id_proveedor: newProv ? parseInt(newProv) : null
      })
    }).then(cargarProductos);
  }
}
</script>
</body>
</html>