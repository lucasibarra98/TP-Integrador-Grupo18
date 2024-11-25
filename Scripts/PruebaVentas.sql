USE Com2900G18
GO


/*

INSERT INTO ventas.Cliente VALUES
('Juan', 'L�pez', 10999333, 'Male', 'Normal')

INSERT INTO ventas.venta VALUES
((SELECT id FROM ventas.Cliente WHERE dni = 10999333), (SELECT id FROM negocio.Empleado WHERE dni = 36383025), (SELECT id FROM negocio.Sucursal WHERE nombre = 'San Justo'), '2024-11-22', '18:02:00', NULL)

INSERT INTO ventas.DetalleVenta VALUES
(1, 1, 10, 50, 50)

INSERT INTO ventas.Pago VALUES
('ASDASDASDDe', 121000, (SELECT id FROM ventas.MedioPago WHERE nombre = 'Cash'))

INSERT INTO ventas.Factura VALUES
((SELECT id FROM ventas.TipoFactura WHERE sigla = 'C'), 1, '30999444', '2024-11-23', '18:02:00', 100000, 0.21, 121000, 5, 'Pendiente')
GO

SELECT FORMAT(CAST(hora AS DATETIME), 'hh:mm') FROM ventas.venta
SELECT * FROM ventas.Cliente
SELECT * FROM negocio.Empleado
SELECT * FROM ventas.Factura
SELECT * FROM ventas.Pago
SELECT * FROM ventas.MedioPago
SELECT * FROM ventas.DetalleVenta
SELECT * FROM productos.Producto
SELECT * FROM negocio.Sucursal
SELECT * FROM ventas.TipoFactura
*/

DECLARE @compras ventas.NuevaVentaType

INSERT INTO @compras VALUES
	(1, 15),
	(2, 15),
	(5, 130),
	(100, 1155),
	(500, 27)

EXEC ventas.generarVentaCompleta @idCliente = 2, @idEmpleado = 257021, @idSucursal = 3, @compras = @compras, @IVA = 0.21, @CUIT = '123213', @tipoFactura = 'C'
GO

DECLARE @idFactura INT = IDENT_CURRENT('ventas.Factura')
EXEC ventas.InsertarPago @idFactura = @idFactura, @idMedioPago = 1, @cod = 'CODIGO-PRUEBA-VENTA3'

SELECT *
FROM ventas.Venta
WHERE id = IDENT_CURRENT('ventas.Venta')

SELECT *
FROM ventas.DetalleVenta
WHERE idVenta = IDENT_CURRENT('ventas.Venta')

SELECT *
FROM ventas.Factura
WHERE id = @idFactura

SELECT *
FROM reportes.MostrarReporteVentas
WHERE [ID Factura] = @idFactura