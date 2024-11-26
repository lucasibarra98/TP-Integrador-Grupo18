USE Com2900G18
GO

/*
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
		DECLARE @idFactura CHAR(11) = LEFT(NEWID(), 11);

		EXEC ventas.generarVentaCompleta @idFactura = @idFactura, @idCliente = @idCliente, @idEmpleado = @idEmpleado, @idSucursal = @idSucursal, @fecha = @fecha, @hora = @hora, @compras = @compras, @IVA = 0.21, @tipoFactura = @tipoFactura

		DECLARE @idFacturaVenta INT = IDENT_CURRENT('ventas.Factura')

		EXEC ventas.InsertarPago @idFactura = @idFacturaVenta, @idMedioPago = @idMedioPago, @cod = @cod

		DELETE FROM @compras

		SET @i = @i + 1
	END
END
GO
*/
-- Ejecución de las pruebas

--EXEC ventas.VentasMasivas
--GO

DECLARE @rutaReporteVentas VARCHAR(256) = 'C:\TP\TP_integrador_Archivos\Reportes\ReporteVentas.xml'
DECLARE @rutaReporteMensual VARCHAR(256) = 'C:\TP\TP_integrador_Archivos\Reportes\ReporteMensual.xml'
DECLARE @rutaReporteTrimestral VARCHAR(256) = 'C:\TP\TP_integrador_Archivos\Reportes\ReporteTrimestral.xml'
DECLARE @rutaReportePorFechas VARCHAR(256) = 'C:\TP\TP_integrador_Archivos\Reportes\ReportePorFechas.xml'
DECLARE @rutaReporteMasVendidos VARCHAR(256) = 'C:\TP\TP_integrador_Archivos\Reportes\ReporteMasVendidos.xml'
DECLARE @rutaReporteMenosVendidos VARCHAR(256) = 'C:\TP\TP_integrador_Archivos\Reportes\ReporteMenosVendidos.xml'
DECLARE @rutaReporteTotalAcumuladoVentas VARCHAR(256) = 'C:\TP\TP_integrador_Archivos\Reportes\ReporteTotalAcumuladoVentas.xml'

EXEC reportes.ReporteVentas @ruta = @rutaReporteVentas
EXEC reportes.ReporteMensual @ruta = @rutaReporteMensual, @mes = 11, @año = 2024
EXEC reportes.ReporteTrimestral @ruta = @rutaReporteTrimestral
EXEC reportes.ReportePorFechas  @ruta = @rutaReportePorFechas, @inicio = '2018-01-01', @fin = '2024-12-31'
EXEC reportes.reporteMasVendidos @ruta = @rutareporteMasVendidos, @mes = 11
EXEC reportes.ReporteMenosVendidos @ruta = @rutaReporteMenosVendidos, @mes = 11
EXEC reportes.ReporteTotalAcumuladoVentas @ruta = @rutaReporteTotalAcumuladoVentas, @fecha = '2019-1-7', @sucursal = 'San Justo'
GO

SELECT * FROM reportes.MostrarReporteVentas