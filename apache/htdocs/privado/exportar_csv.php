<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

$user_uid = $_SERVER['REMOTE_USER'] ?? '';
if (!$user_uid) {
    header('Location: /index.html');
    exit();
}

if (!isset($_GET['entidad'])) {
    die("Falta especificar la entidad a exportar.");
}
$entidad = preg_replace('/[^a-z_]/', '', strtolower($_GET['entidad'])); // Sanitiza

// Define la URL de la API Flask para la entidad
$api_url = "http://localhost:5000/$entidad/";

$ch = curl_init($api_url);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, 5);
curl_setopt($ch, CURLOPT_TIMEOUT, 10);
$result = curl_exec($ch);

if ($result === false) {
    die("No se pudo conectar a la API para obtener los datos.");
}
curl_close($ch);

$data = json_decode($result, true);
if (!is_array($data) || count($data) == 0) {
    die("No hay datos para exportar.");
}

header('Content-Type: text/csv; charset=utf-8');
header('Content-Disposition: attachment; filename="' . $entidad . '_' . date('Y-m-d_H-i-s') . '.csv"');

$output = fopen('php://output', 'w');

// Escribe encabezados
fputcsv($output, array_keys($data[0]));

// Escribe cada fila
foreach ($data as $row) {
    fputcsv($output, $row);
}
fclose($output);
exit;
?>