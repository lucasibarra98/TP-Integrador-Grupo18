USE Com2900G18
GO

IF TYPE_ID(N'ventas.NuevaVentaType') IS NULL
CREATE TYPE ventas.NuevaVentaType AS TABLE(idProducto INT, cantidad INT)
GO

CREATE OR ALTER PROCEDURE ventas.generarVentaCompleta
	@idCliente INT,
	@idEmpleado INT,
	@idSucursal INT,
	@CUIT BIGINT,
	@IVA DECIMAL(3,2),
	@compras NuevaVentaType READONLY,
	@tipoFactura CHAR(1),
	@fecha DATE = NULL,
	@hora TIME = NULL
AS
BEGIN
	EXEC ventas.InsertarVenta @idCliente, @idEmpleado, @idSucursal, @fecha, @hora

	DECLARE @idVenta INT = IDENT_CURRENT('ventas.Venta')
	--EXEC ventas.InsertarDetallesVenta @idVenta, @compras
	INSERT INTO ventas.DetalleVenta 
	SELECT @idVenta, p.id, c.cantidad, p.precioUnitario, c.cantidad * p.precioUnitario FROM @compras c INNER JOIN productos.Producto p ON c.idProducto = p.id
	
	EXEC ventas.ActualizarTotalVenta @idVenta

	DECLARE @idTipoFactura INT = (SELECT id FROM ventas.TipoFactura WHERE sigla = @tipoFactura)

	EXEC ventas.InsertarFactura @idTipoFactura, @idVenta, @CUIT, @IVA
END
GO

CREATE OR ALTER PROCEDURE ventas.VentasMasivas AS
BEGIN
	DECLARE @i INT = 0
	DECLARE @j INT = 0
	DECLARE @compras ventas.NuevaVentaType

	WHILE @i < 1000
	BEGIN
		DECLARE @idProducto INT
		DECLARE @cantidad INT

		WHILE @j < (SELECT FLOOR(RAND() * 10) + 1)
		BEGIN
			SET @idProducto = (SELECT TOP 1 id FROM productos.Producto ORDER BY NEWID());
			SET @cantidad = (SELECT FLOOR(RAND() * 100) + 1)

			INSERT INTO @compras VALUES
				(@idProducto, @cantidad)

			SET @j = @j + 1
		END
		SET @j = 0

		DECLARE @idSucursal VARCHAR(50) = (SELECT TOP 1 id FROM negocio.Sucursal ORDER BY NEWID());
		DECLARE @tipoFactura CHAR(1) = (SELECT TOP 1 sigla FROM ventas.TipoFactura ORDER BY NEWID());
		DECLARE @cod VARCHAR(50) = LEFT(NEWID(), 20);
		DECLARE @idMedioPago INT = (SELECT TOP 1 id FROM ventas.MedioPago ORDER BY NEWID());
		DECLARE @fechaMin DATE = '2023-01-01';
		DECLARE @fechaMax DATE = '2024-10-31';
		DECLARE @horaInicio TIME = '08:00:00';
		DECLARE @horaFin TIME = '18:00:00';
		DECLARE @fecha DATE = (SELECT DATEADD(DAY, FLOOR(RAND() * (DATEDIFF(DAY, @fechaMin, @fechaMax) + 1)), @fechaMin));
		DECLARE @hora TIME = (SELECT CAST(DATEADD(SECOND, FLOOR(RAND() * (DATEDIFF(SECOND, @horaInicio, @horaFin) + 1)), @horaInicio) AS TIME));
		DECLARE @idCliente INT = (SELECT TOP 1 id FROM ventas.Cliente ORDER BY NEWID());
		DECLARE @idEmpleado INT = (SELECT TOP 1 id FROM negocio.Empleado ORDER BY NEWID());

		EXEC ventas.generarVentaCompleta @idCliente = @idCliente, @idEmpleado = @idEmpleado, @idSucursal = @idSucursal, @fecha = @fecha, @hora = @hora, @compras = @compras, @IVA = 0.21, @CUIT = '123213', @tipoFactura = @tipoFactura

		DECLARE @idFactura INT = IDENT_CURRENT('ventas.Factura')

		EXEC ventas.InsertarPago @idFactura = @idFactura, @idMedioPago = @idMedioPago, @cod = @cod

		DELETE FROM @compras

		SET @i = @i + 1
	END
END
GO

-- Ejecuci�n de las pruebas

-- Se insertan los tipos de factura que no vienen en la informaci�n complementaria
INSERT INTO ventas.TipoFactura VALUES
('A'), ('B'), ('C'), ('E'), ('M'), ('T')

-- Se insertan clientes que no vienen en la informaci�n complementaria
EXEC ventas.InsertarCliente @nombre = 'Juan', @apellido = 'L�pez', @dni = 12345678, @genero = 'Male', @tipoCliente = 'Member'
EXEC ventas.InsertarCliente @nombre = 'Ana', @apellido = 'Garc�a', @dni = 22345678, @genero = 'Female', @tipoCliente = 'Normal'
EXEC ventas.InsertarCliente @nombre = 'Diego', @apellido = 'D�az', @dni = 72345678, @genero = 'Male', @tipoCliente = 'Normal'

EXEC ventas.VentasMasivas
GO

DECLARE @rutaReporteVentas VARCHAR(256) = 'C:\TP\TP_integrador_Archivos\Reportes\ReporteVentas.xml'
DECLARE @rutaReporteMensual VARCHAR(256) = 'C:\TP\TP_integrador_Archivos\Reportes\ReporteMensual.xml'
DECLARE @rutaReporteTrimestral VARCHAR(256) = 'C:\TP\TP_integrador_Archivos\Reportes\ReporteTrimestral.xml'
DECLARE @rutaReportePorFechas VARCHAR(256) = 'C:\TP\TP_integrador_Archivos\Reportes\ReportePorFechas.xml'
DECLARE @rutaReporteMasVendidos VARCHAR(256) = 'C:\TP\TP_integrador_Archivos\Reportes\ReporteMasVendidos.xml'
DECLARE @rutaReporteMenosVendidos VARCHAR(256) = 'C:\TP\TP_integrador_Archivos\Reportes\ReporteMenosVendidos.xml'
DECLARE @rutaReporteTotalAcumuladoVentas VARCHAR(256) = 'C:\TP\TP_integrador_Archivos\Reportes\ReporteTotalAcumuladoVentas.xml'

EXEC reportes.ReporteVentas @ruta = @rutaReporteVentas
EXEC reportes.ReporteMensual @ruta = @rutaReporteMensual, @mes = 11, @a�o = 2024
EXEC reportes.ReporteTrimestral @ruta = @rutaReporteTrimestral
EXEC reportes.ReportePorFechas  @ruta = @rutaReportePorFechas, @inicio = '2023-02-25', @fin = '2024-12-01'
EXEC reportes.reporteMasVendidos @ruta = @rutareporteMasVendidos, @mes = 11
EXEC reportes.ReporteMenosVendidos @ruta = @rutaReporteMenosVendidos, @mes = 11
EXEC reportes.ReporteTotalAcumuladoVentas @ruta = @rutaReporteTotalAcumuladoVentas, @fecha = '2024-11-22', @sucursal = 'San Justo'
GO

SELECT * FROM reportes.MostrarReporteVentas