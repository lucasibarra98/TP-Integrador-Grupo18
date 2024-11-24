USE Com2900G18
GO

SELECT f.id as 'ID Factura', 
tf.sigla as 'Tipo de Factura', 
s.ciudad as 'Ciudad', 
c.tipoCliente as 'Tipo de Cliente', 
c.genero as Genero, 
lp.nombre as 'Linea de Producto', 
p.nombre as Producto, 
p.precioUnitario as 'Precio Unitario', 
dv.cantidad as Cantidad, 
v.fecha as Fecha, 
v.hora as Hora, 
mp.reemplazaPor as 'Medio de Pago',
e.id as Empleado, 
s.nombre as Sucursal
FROM ventas.DetalleVenta dv
INNER JOIN ventas.Venta v ON v.id = dv.idVenta
INNER JOIN ventas.Factura f ON v.id = f.idVenta
INNER JOIN ventas.TipoFactura tf ON f.idTipoFactura = tf.id
INNER JOIN negocio.Empleado e ON v.idEmpleado = e.id
INNER JOIN negocio.Sucursal s ON e.idSucursal = s.id
INNER JOIN productos.Producto p ON dv.idProducto = p.id
INNER JOIN productos.LineaProducto lp ON p.idLineaProd = lp.id
INNER JOIN ventas.Cliente c ON v.idCliente = c.id
INNER JOIN ventas.Pago pg ON f.idPago = f.idPago
INNER JOIN ventas.MedioPago mp ON pg.idMedioPago = mp.id 
FOR XML AUTO, ELEMENTS;
GO

/*
SELECT * FROM ventas.TipoFactura
INSERT INTO ventas.TipoFactura VALUES
('A'), ('B'), ('C'),('E')

SELECT * FROM ventas.venta
SELECT * FROM ventas.Cliente
SELECT * FROM negocio.Empleado
SELECT * FROM ventas.Factura
SELECT * FROM ventas.Pago
SELECT * FROM ventas.MedioPago
SELECT * FROM ventas.DetalleVenta
SELECT * FROM productos.Producto


INSERT INTO ventas.Cliente VALUES
('Juan', 'López', 10999333, 'Male', 'Normal')

INSERT INTO ventas.venta VALUES
((SELECT id FROM ventas.Cliente WHERE dni = 10999333), (SELECT id FROM negocio.Empleado WHERE dni = 36383025), (SELECT id FROM negocio.Sucursal WHERE nombre = 'San Justo'), '2024-11-22', '18:02:00', NULL)

INSERT INTO ventas.DetalleVenta VALUES
(1, 1, 10, 50, 50)

INSERT INTO ventas.Pago VALUES
('ASDASDASDDe', 121000, (SELECT id FROM ventas.MedioPago WHERE nombre = 'Cash'))

INSERT INTO ventas.Factura VALUES
((SELECT id FROM ventas.TipoFactura WHERE sigla = 'C'), 1, '30999444', '2024-11-23', '18:02:00', 100000, 0.21, 121000, 5, 'Pendiente')
GO
*/

CREATE OR ALTER FUNCTION reportes.obtenerNombreDia(@dia INT) RETURNS CHAR(10) AS
BEGIN
	RETURN CASE @dia
	WHEN 1 THEN 'Domingo'
	WHEN 2 THEN 'Lunes'
	WHEN 3 THEN 'Martes'
	WHEN 4 THEN 'Miércoles'
	WHEN 5 THEN 'Jueves'
	WHEN 6 THEN 'Viernes'
	WHEN 7 THEN 'Sábado'
	END
END
GO

CREATE OR ALTER FUNCTION reportes.obtenerNombreMes(@mes INT) RETURNS CHAR(10) AS
BEGIN
	RETURN CASE @mes
	WHEN 1 THEN 'Enero'
	WHEN 2 THEN 'Febrero'
	WHEN 3 THEN 'Marzo'
	WHEN 4 THEN 'Abril'
	WHEN 5 THEN 'Mayo'
	WHEN 6 THEN 'Junio'
	WHEN 7 THEN 'Julio'
	WHEN 8 THEN 'Agosto'
	WHEN 9 THEN 'Septiembre'
	WHEN 10 THEN 'Octubre'
	WHEN 11 THEN 'Noviembre'
	WHEN 12 THEN 'Diciembre'
	END
END
GO

CREATE OR ALTER PROCEDURE reportes.reporteMensual @mes INT, @año INT AS
BEGIN
	SELECT reportes.obtenerNombreDia(DATEPART(dw, fecha)) AS Día, SUM(total) AS Total
	FROM ventas.Factura
	WHERE MONTH(fecha) = @mes AND YEAR(fecha) = @año
	GROUP BY DATEPART(dw, fecha)
END
GO

EXEC reportes.reporteMensual @mes = 11, @año = 2024
GO

CREATE OR ALTER PROCEDURE reportes.reporteTrimestral AS
BEGIN
	SELECT reportes.obtenerNombreMes(MONTH(F.fecha)) AS Mes, SUM(F.total) AS Total, E.turno AS Turno
	FROM ventas.Factura AS F INNER JOIN ventas.Venta AS V ON F.idVenta = V.id INNER JOIN negocio.Empleado AS E ON V.idEmpleado = E.id
	GROUP BY MONTH(F.fecha), E.Turno
END
GO

EXEC reportes.reporteTrimestral
GO

CREATE OR ALTER PROCEDURE reportes.reportePorFechas @inicio DATE, @fin DATE AS
BEGIN
	SELECT p.nombre AS Producto, COUNT(idProducto) AS Cantidad
	FROM ventas.DetalleVenta AS dv INNER JOIN ventas.Venta AS v ON dv.idVenta = v.id INNER JOIN productos.Producto AS p ON p.id = dv.idProducto
	WHERE fecha >= @inicio AND fecha <= @fin
	GROUP BY idProducto, p.nombre
	ORDER BY COUNT(idProducto) DESC
END
GO

EXEC reportes.reportePorFechas @inicio = '2023-02-25', @fin = '2024-12-01'
GO

CREATE OR ALTER PROCEDURE reportes.reporteMasVendidos @mes INT AS
BEGIN
	SELECT TOP 5 DATEPART(week, fecha)  AS Semana, p.nombre AS Producto, COUNT(p.nombre) AS Cantidad
	FROM ventas.DetalleVenta AS dv INNER JOIN ventas.Venta AS v ON dv.idVenta = v.id INNER JOIN productos.Producto AS p ON p.id = dv.idProducto
	WHERE MONTH(v.fecha) = @mes
	GROUP BY DATEPART(week, fecha), p.nombre
	ORDER BY COUNT(p.nombre) DESC
END
GO

EXEC reportes.reporteMasVendidos @mes = 11
GO

CREATE OR ALTER PROCEDURE reportes.reporteMenosVendidos @mes INT AS
BEGIN
	SELECT TOP 5 p.nombre AS Producto, COUNT(p.nombre) AS Cantidad
	FROM ventas.DetalleVenta AS dv INNER JOIN ventas.Venta AS v ON dv.idVenta = v.id INNER JOIN productos.Producto AS p ON p.id = dv.idProducto
	WHERE MONTH(v.fecha) = @mes
	GROUP BY p.nombre
	ORDER BY COUNT(p.nombre) ASC
END
GO

EXEC reportes.reporteMenosVendidos @mes = 11
GO

CREATE OR ALTER PROCEDURE reportes.reporteTotalAcumuladoVentas @fecha DATE, @ AS
BEGIN
	SELECT SUM(totalSinIVA) AS 'Total acumulado de ventas'
	FROM ventas.Venta
	WHERE idSucursal = (SELECT id FROM negocio.Sucursal WHERE id = idSucursal)
	AND @fecha = fecha
	GROUP BY id
END
GO

EXEC reportes.reporteTotalAcumuladoVentas @fecha = '2024-11-22'