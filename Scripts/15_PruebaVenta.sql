USE Com2900G18
GO


/*
SELECT * FROM ventas.Cliente
SELECT * FROM negocio.Empleado
SELECT * FROM ventas.Factura
SELECT * FROM ventas.Pago
SELECT * FROM ventas.MedioPago
SELECT * FROM ventas.DetalleVenta
SELECT * FROM productos.Producto
SELECT * FROM negocio.Sucursal
SELECT * FROM ventas.TipoFactura
SELECT * FROM ventas.Venta
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
EXEC ventas.generarVentaCompleta @idFactura = 'COD-FACT', @idCliente = 2, @idEmpleado = 257021, @idSucursal = 3, @compras = @compras, @IVA = 0.21, @tipoFactura = 'C'
GO

-- Pagar la factura creada
DECLARE @idFactura INT = IDENT_CURRENT('ventas.Factura')
EXEC ventas.InsertarPago @idFactura = @idFactura, @idMedioPago = 1, @cod = 'CODIGO-PAGO2'

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