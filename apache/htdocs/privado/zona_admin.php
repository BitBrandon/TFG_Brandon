<?php
$user_uid = $_SERVER['REMOTE_USER'] ?? '';

// Conecta a LDAP
$ldap = ldap_connect('ldap://ldap');
ldap_set_option($ldap, LDAP_OPT_PROTOCOL_VERSION, 3);
ldap_bind($ldap, "cn=admin,dc=mayorista,dc=local", "adminpassword");

// Comprueba si el usuario es admin
$base_dn = "ou=grupos,dc=mayorista,dc=local";
$filter = "(&(objectClass=groupOfNames)(cn=administradores)(member=uid=$user_uid,ou=usuarios,dc=mayorista,dc=local))";
$result = ldap_search($ldap, $base_dn, $filter);
$entries = ldap_get_entries($ldap, $result);
$is_admin = ($entries['count'] > 0);

if (!$is_admin) {
    echo "<h2>No tienes acceso a la zona de administración.</h2>";
    exit;
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8" />
  <title>Zona de Administración</title>
  <link rel="stylesheet" href="../estilos.css" />
  <style>
    .admin-panel {
      max-width: 600px;
      margin: 2em auto;
      padding: 2em;
      background: #fffbe7;
      border-radius: 12px;
      box-shadow: 0 0 10px #ccc;
    }
    .admin-panel h2 {
      margin-bottom: 1.5em;
      color: #e37e00;
    }
    .admin-buttons {
      display: flex;
      flex-direction: column;
      gap: 1em;
    }
    .admin-buttons button, .admin-buttons a {
      padding: 1em;
      border: none;
      border-radius: 6px;
      background: #e37e00;
      color: #fff;
      font-size: 1.1em;
      cursor: pointer;
      text-decoration: none;
      text-align: center;
      transition: background 0.2s;
    }
    .admin-buttons button:hover, .admin-buttons a:hover {
      background: #c76600;
    }
  </style>
</head>
<body>
  <div class="admin-panel">
    <h2>Zona de Administración</h2>
    <p>Bienvenido, <b><?= htmlspecialchars($user_uid) ?></b>.<br>
    Aquí puedes acceder a las herramientas de administración:</p>
    <div class="admin-buttons">
      <!-- Cambia los href según tus rutas reales -->
      <a href="http://localhost:8081" target="_blank">Abrir PHPLDAPADMIN</a>
      <a href="http://localhost:8082" target="_blank">Abrir phpMyAdmin</a>
      <a href="/admin/mysql-shell" target="_blank">Abrir shell MySQL (web)</a>
      <!-- Añade más enlaces o botones aquí -->
    </div>
    <br>
    <a href="privado.php">&larr; Volver al panel privado</a>
  </div>
</body>
</html>