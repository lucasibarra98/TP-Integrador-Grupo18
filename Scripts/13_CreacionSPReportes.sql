USE Com2900G18
GO

CREATE OR ALTER PROCEDURE reportes.GuardarXML @ruta NVARCHAR(255), @xml XML
AS
BEGIN
        DECLARE @Object INT;
        DECLARE @FileID INT;

		EXEC sp_configure 'show advanced options', 1;
		RECONFIGURE WITH OVERRIDE;
		EXEC sp_configure 'Ole Automation Procedures', 1;
		RECONFIGURE WITH OVERRIDE;

        -- Crear el archivo y escribir el XML
        EXEC sp_OACreate 'Scripting.FileSystemObject', @Object OUT; -- Crear el objeto FileSystemObject
        EXEC sp_OAMethod @Object, 'CreateTextFile', @FileID OUT, @ruta, 2, TRUE; -- Crear el archivo XML
        EXEC sp_OAMethod @FileID, 'Write', NULL, @xml; -- Escribir en el archivo XML

        -- Liberar los objetos OLE
        EXEC sp_OADestroy @Object;
        EXEC sp_OADestroy @FileID;

		EXEC sp_configure 'Ole Automation Procedures', 0;
		RECONFIGURE WITH OVERRIDE;
		EXEC sp_configure 'show advanced options', 0;
		RECONFIGURE WITH OVERRIDE;
END
GO

CREATE OR ALTER VIEW reportes.MostrarReporteVentas AS
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
		mp.nombre as 'Medio de Pago',
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
		INNER JOIN ventas.Pago pg ON f.idPago = pg.id
		INNER JOIN ventas.MedioPago mp ON pg.idMedioPago = mp.id
GO

CREATE OR ALTER PROCEDURE reportes.ReporteVentas @ruta VARCHAR(256) AS
BEGIN
	DECLARE @xml XML = (
		SELECT *
		FROM reportes.MostrarReporteVentas
		ORDER BY [ID Factura]
		FOR XML AUTO, ROOT('ReporteVentas')
	)
	EXEC reportes.GuardarXML @ruta, @xml
END
GO

CREATE OR ALTER FUNCTION reportes.ObtenerNombreDia(@dia INT) RETURNS VARCHAR(10) AS
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

CREATE OR ALTER FUNCTION reportes.ObtenerNombreMes(@mes INT) RETURNS VARCHAR(10) AS
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

CREATE OR ALTER PROCEDURE reportes.ReporteMensual @ruta VARCHAR(256), @mes INT, @año INT AS
BEGIN
	DECLARE @xml XML = (
		SELECT reportes.ObtenerNombreDia(DATEPART(dw, fecha)) AS Día, SUM(total) AS Total
		FROM ventas.Factura
		WHERE MONTH(fecha) = @mes AND YEAR(fecha) = @año
		GROUP BY DATEPART(dw, fecha)
		FOR XML AUTO, ROOT('ReporteMensual')
	)

	EXEC reportes.GuardarXML @ruta, @xml
END
GO

CREATE OR ALTER PROCEDURE reportes.ReporteTrimestral @ruta VARCHAR(256) AS
BEGIN
	DECLARE @xml XML = (
		SELECT reportes.ObtenerNombreMes(MONTH(F.fecha)) AS Mes, SUM(F.total) AS Total, E.turno AS Turno
		FROM ventas.Factura AS F INNER JOIN ventas.Venta AS V ON F.idVenta = V.id INNER JOIN negocio.Empleado AS E ON V.idEmpleado = E.id
		GROUP BY MONTH(F.fecha), E.Turno
		FOR XML AUTO, ROOT('ReporteTrimestral')
	)

	EXEC reportes.GuardarXML @ruta, @xml
END
GO

CREATE OR ALTER PROCEDURE reportes.ReportePorFechas @ruta VARCHAR(256), @inicio DATE, @fin DATE AS
BEGIN
	DECLARE @xml XML = (
		SELECT p.nombre AS Producto, COUNT(idProducto) AS Cantidad
		FROM ventas.DetalleVenta AS dv INNER JOIN ventas.Venta AS v ON dv.idVenta = v.id INNER JOIN productos.Producto AS p ON p.id = dv.idProducto
		WHERE fecha >= @inicio AND fecha <= @fin
		GROUP BY idProducto, p.nombre
		ORDER BY COUNT(idProducto) DESC
		FOR XML AUTO, ROOT('ReportePorFechas')
	)

	EXEC reportes.GuardarXML @ruta, @xml
END
GO

CREATE OR ALTER PROCEDURE reportes.ReporteMasVendidos @ruta VARCHAR(256), @mes INT AS
BEGIN
	DECLARE @xml XML = (
		SELECT TOP 5 DATEPART(week, fecha)  AS Semana, p.nombre AS Producto, SUM(dv.cantidad) AS Cantidad
		FROM ventas.DetalleVenta AS dv INNER JOIN ventas.Venta AS v ON dv.idVenta = v.id INNER JOIN productos.Producto AS p ON p.id = dv.idProducto
		WHERE MONTH(v.fecha) = @mes
		GROUP BY DATEPART(week, fecha), p.nombre
		ORDER BY SUM(dv.cantidad) DESC
		FOR XML AUTO, ROOT('ReporteMasVendidos')
	)

	EXEC reportes.GuardarXML @ruta, @xml
END
GO

CREATE OR ALTER PROCEDURE reportes.ReporteMenosVendidos @ruta VARCHAR(256), @mes INT AS
BEGIN
	DECLARE @xml XML = (
		SELECT TOP 5 p.nombre AS Producto, SUM(dv.cantidad) AS Cantidad
		FROM ventas.DetalleVenta AS dv INNER JOIN ventas.Venta AS v ON dv.idVenta = v.id INNER JOIN productos.Producto AS p ON p.id = dv.idProducto
		WHERE MONTH(v.fecha) = @mes
		GROUP BY p.nombre
		ORDER BY SUM(dv.cantidad) ASC
		FOR XML AUTO, ROOT('ReporteMenosVendidos')
	)

	EXEC reportes.GuardarXML @ruta, @xml
END
GO

CREATE OR ALTER PROCEDURE reportes.ReporteTotalAcumuladoVentas @ruta VARCHAR(256), @fecha DATE, @sucursal VARCHAR(50) AS
BEGIN
	DECLARE @xml XML = (
		SELECT SUM(totalSinIVA) AS 'Total acumulado de ventas'
		FROM ventas.Venta
		WHERE idSucursal = (SELECT id FROM negocio.Sucursal WHERE nombre = @sucursal)
		AND @fecha = fecha
		GROUP BY id
		FOR XML AUTO, ROOT('ReporteTotalAcumuladoVentas')
	)

	EXEC reportes.GuardarXML @ruta, @xml
END
GO