-- Crear la base de datos
CREATE DATABASE IF NOT EXISTS MiBaseDeDatos;

-- Seleccionar la base de datos
USE MiBaseDeDatos;

-- Crear una tabla llamada "usuarios"
CREATE TABLE IF NOT EXISTS usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    fecha_registro DATE NOT NULL
);

-- Insertar algunos datos en la tabla "usuarios"
INSERT INTO usuarios (nombre, email, fecha_registro)
VALUES ('Juan Perez', 'juan.perez@example.com', '2024-01-15');

INSERT INTO usuarios (nombre, email, fecha_registro)
VALUES ('Ana Lopez', 'ana.lopez@example.com', '2024-02-20');

INSERT INTO usuarios (nombre, email, fecha_registro)
VALUES ('Carlos Ramirez', 'carlos.ramirez@example.com', '2024-03-05');

-- Seleccionar todos los usuarios
SELECT * FROM usuarios;

-- Actualizar el nombre de un usuario
UPDATE usuarios
SET nombre = 'Juan García'
WHERE id = 1;

-- Eliminar un usuario por su id
DELETE FROM usuarios WHERE id = 3;

-- Mostrar la tabla después de las operaciones
SELECT * FROM usuarios;

SELECT nombre FROM usuarios;