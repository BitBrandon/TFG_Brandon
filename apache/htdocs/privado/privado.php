<?php
$user_uid = $_SERVER['REMOTE_USER'] ?? '';

// Conecta a LDAP
$ldap = ldap_connect('ldap://ldap');
ldap_set_option($ldap, LDAP_OPT_PROTOCOL_VERSION, 3);
// Puedes usar también el bind de servicio si lo tienes
ldap_bind($ldap, "cn=admin,dc=mayorista,dc=local", "adminpassword");

// Busca si el usuario está en administradores
$base_dn = "ou=grupos,dc=mayorista,dc=local";
$filter = "(&(objectClass=posixGroup)(cn=administradores)(memberUid=$user_uid))";$entries = ldap_get_entries($ldap, $result);
$is_admin = ($entries['count'] > 0);
?>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8" />
  <title>Panel Privado</title>
  <link rel="stylesheet" href="../estilos.css" />
</head>
<body>
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
  <div class="login-container">
    <h2>Panel de Gestión</h2>
    <p>Bienvenido al área privada, <b><?= htmlspecialchars($user_uid) ?></b></p>
  <div class="botones">
    <button onclick="location.href='usuarios.php'">Usuarios</button>
    <button onclick="location.href='clientes.php'">Clientes</button>
    <button onclick="location.href='productos.php'">Productos</button>
    <button onclick="location.href='ventas.php'">Ventas</button>
    <button onclick="location.href='facturas.php'">Facturas</button>
    <button onclick="location.href='categorias.php'">Categorías</button>
    <button onclick="location.href='proveedores.php'">Proveedores</button>
    <button onclick="location.href='gastos.php'">Gastos</button>
    <button onclick="location.href='logs.php'">Logs</button>
    <?php if($is_admin): ?>
      <button onclick="location.href='zona_admin.php'">Zona de Administración</button>
    <?php endif; ?>
  </div>

    <?php if(!$is_admin): ?>
      <p style="color: #c00; margin-top:2em;">No tienes acceso a la zona de administración.</p>
    <?php endif; ?>
  </div>
</body>
</html>