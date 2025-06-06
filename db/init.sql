-- Crear la base de datos
CREATE DATABASE IF NOT EXISTS mayorista_db;
USE mayorista_db;

-- Tabla de Clientes
CREATE TABLE IF NOT EXISTS clientes (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100),
    email VARCHAR(100),
    telefono VARCHAR(20),
    direccion TEXT
);

-- Tabla de Productos
CREATE TABLE IF NOT EXISTS productos (
    id_producto INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100),
    precio DECIMAL(10,2),
    stock INT,
    id_categoria INT,
    id_proveedor INT
);

-- Tabla de Ventas
CREATE TABLE IF NOT EXISTS ventas (
    id_venta INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT,
    id_producto INT,
    cantidad INT,
    fecha DATE,
    FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente),
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
);

-- Tabla de Facturas
CREATE TABLE IF NOT EXISTS facturas (
    id_factura INT AUTO_INCREMENT PRIMARY KEY,
    id_venta INT,
    total DECIMAL(10,2),
    fecha_factura DATE,
    FOREIGN KEY (id_venta) REFERENCES ventas(id_venta)
);

-- Tabla de Categorías de Productos
CREATE TABLE IF NOT EXISTS categorias (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100)
);

-- Tabla de Proveedores
CREATE TABLE IF NOT EXISTS proveedores (
    id_proveedor INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100),
    telefono VARCHAR(20),
    email VARCHAR(100)
);

-- Tabla de Usuarios (opcional si no usas solo LDAP)
CREATE TABLE IF NOT EXISTS usuarios (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100),
    email VARCHAR(100),
    rol ENUM('trabajador', 'jefe', 'admin_informatica') NOT NULL,
    activo BOOLEAN DEFAULT TRUE
);

-- Tabla de Gastos
CREATE TABLE IF NOT EXISTS gastos (
    id_gasto INT AUTO_INCREMENT PRIMARY KEY,
    descripcion TEXT,
    monto DECIMAL(10,2),
    fecha DATE
);

-- Tabla de Logs o Registro de Actividades
CREATE TABLE IF NOT EXISTS logs (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    usuario VARCHAR(100),
    accion TEXT,
    fecha DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Datos de ejemplo para Clientes
INSERT INTO clientes (nombre, email, telefono, direccion) VALUES
('Juan Pérez', 'juan@example.com', '666111222', 'Calle Mayor, 1'),
('Ana García', 'ana@gmail.com', '666333444', 'Calle Menor, 2');

-- Datos de ejemplo para Categorías
INSERT INTO categorias (nombre) VALUES
('Bebidas'),
('Comida');

-- Datos de ejemplo para Proveedores
INSERT INTO proveedores (nombre, telefono, email) VALUES
('Proveedor 1', '600123456', 'prov1@correo.com'),
('Proveedor 2', '600654321', 'prov2@correo.com');

-- Datos de ejemplo para Productos
INSERT INTO productos (nombre, precio, stock, id_categoria, id_proveedor) VALUES
('Agua', 1.50, 100, 1, 1),
('Pan', 0.80, 200, 2, 2);

-- Datos de ejemplo para Usuarios
INSERT INTO usuarios (nombre, email, rol, activo) VALUES
('Carla Admin', 'admin@mayorista.com', 'admin_informatica', TRUE),
('Juan Jefe', 'jefe@mayorista.com', 'jefe', TRUE);

-- Datos de ejemplo para Ventas
INSERT INTO ventas (id_cliente, id_producto, cantidad, fecha) VALUES
(1, 1, 10, '2025-06-01'),
(2, 2, 5, '2025-06-02');

-- Datos de ejemplo para Facturas
INSERT INTO facturas (id_venta, total, fecha_factura) VALUES
(1, 15.00, '2025-06-01'),
(2, 4.00, '2025-06-02');

-- Datos de ejemplo para Gastos
INSERT INTO gastos (descripcion, monto, fecha) VALUES
('Luz junio', 120.50, '2025-06-01'),
('Internet', 50.00, '2025-06-02');

-- Datos de ejemplo para Logs
INSERT INTO logs (usuario, accion) VALUES
('Carla Admin', 'Inicio de sesión'),
('Juan Jefe', 'Creación de factura');