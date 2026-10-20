CREATE TABLE anulaciones (
    id INT IDENTITY,
    venta_id INT,
    fecha_anulacion DATETIME,
    usuario VARCHAR(50),
    monto FLOAT
);
