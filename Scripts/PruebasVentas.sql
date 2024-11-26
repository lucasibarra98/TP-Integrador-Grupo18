USE Com2900G18
GO


/*

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

-- Crear tabla con los detalles de compra
DECLARE @compras ventas.NuevaVentaType

-- Insertar detalles de compra
INSERT INTO @compras VALUES
	(1, 15),
	(2, 15),
	(5, 130),
	(100, 1155),
	(500, 27)

-- Generar venta y factura
EXEC ventas.generarVentaCompleta @idFactura = 'CODIGO-FACTURA', @idCliente = 2, @idEmpleado = 257021, @idSucursal = 3, @compras = @compras, @IVA = 0.21, @CUIT = '123213', @tipoFactura = 'C'
GO

-- Pagar la factura creada
DECLARE @idFactura INT = IDENT_CURRENT('ventas.Factura')
EXEC ventas.InsertarPago @idFactura = @idFactura, @idMedioPago = 1, @cod = 'CODIGO-PAGO'

-- Mostrar venta generada
SELECT *
FROM ventas.Venta
WHERE id = IDENT_CURRENT('ventas.Venta')

-- Mostrar detalles de venta generados
SELECT *
FROM ventas.DetalleVenta
WHERE idVenta = IDENT_CURRENT('ventas.Venta')

-- Mostrar factura generada
SELECT *
FROM ventas.Factura
WHERE id = IDENT_CURRENT('ventas.Factura')

-- Mostrar venta del reporte para la factura generada
SELECT *
FROM reportes.MostrarReporteVentas
WHERE [ID Factura] = IDENT_CURRENT('ventas.Factura')