/*
Entrega 4
	Se proveen maestros de XXX.
	Ver archivo �Datasets para importar� en Miel.

	Se requiere que importe toda la informaci�n antes mencionada a la base de datos:
	� Genere los objetos necesarios (store procedures, funciones, etc.) para importar los
	archivos antes mencionados. Tenga en cuenta que cada mes se recibir�n archivos de
	novedades con la misma estructura, pero datos nuevos para agregar a cada maestro.
	� Considere este comportamiento al generar el c�digo. Debe admitir la importaci�n de
	novedades peri�dicamente.
	� Cada maestro debe importarse con un SP distinto. No se aceptar�n scripts que
	realicen tareas por fuera de un SP.
	� La estructura/esquema de las tablas a generar ser� decisi�n suya. Puede que deba
	realizar procesos de transformaci�n sobre los maestros recibidos para adaptarlos a la
	estructura requerida.
	Trabajo Pr�ctico Integrador
	P�g. 9 de 10
	� Los archivos CSV/JSON no deben modificarse. En caso de que haya datos mal
	cargados, incompletos, err�neos, etc., deber� contemplarlo y realizar las correcciones
	en el fuente SQL. (Ser�a una excepci�n si el archivo est� malformado y no es posible
	interpretarlo como JSON o CSV). 
*/

USE Com2900G18;
GO

-- Creaci�n de Store Procedures para importar xlsx y csv de forma gen�rica

CREATE OR ALTER PROCEDURE importacion.ImportarXlsx @ruta VARCHAR(256), @hoja VARCHAR(31), @tabla VARCHAR(256) AS
BEGIN
	DECLARE @sql NVARCHAR(1024);

	EXEC sp_configure 'show advanced options', 1;
	RECONFIGURE WITH OVERRIDE;
	EXEC sp_configure 'ad hoc distributed queries', 1;
	RECONFIGURE WITH OVERRIDE;

	SET @sql = N'
		INSERT INTO '+ @tabla +'
			SELECT *
			FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'', ''Excel 12.0; Database=' + @ruta + ';HDR=YES;IMEX=1'', ''SELECT * FROM [' + @hoja + '$]'')
	';

	EXEC sp_executesql @sql;

	EXEC sp_configure 'ad hoc distributed queries', 0;
	RECONFIGURE WITH OVERRIDE;
	EXEC sp_configure 'show advanced options', 0;
	RECONFIGURE WITH OVERRIDE;
END
GO

CREATE OR ALTER PROCEDURE importacion.ImportarCsv @ruta VARCHAR(256), @tabla VARCHAR(256) AS
BEGIN
	DECLARE @sql NVARCHAR(1024);

	SET @sql = N'
		BULK INSERT ' + @tabla + '
		FROM ''' + @ruta + '''
		WITH
		(
			ROWTERMINATOR = ''0x0A'',
			FIRSTROW = 2,
			FORMAT = ''CSV'',
			CODEPAGE = ''65001''
		)
	';

	EXEC sp_executesql @sql;
END
GO

/*
	Creaci�n de Store Procedure para importar tabla de clasificaci�n de productos en tabla temporal
	y cargar tablas de l�nea de producto y categor�a
*/

CREATE OR ALTER PROCEDURE importacion.ImportarClasificacionProducto @ruta VARCHAR(256) AS
BEGIN
	DROP TABLE IF EXISTS #ClasificacionProducto;
	CREATE TABLE #ClasificacionProducto([L�nea de producto] VARCHAR(40), Producto VARCHAR(50));

	EXEC importacion.ImportarXlsx @ruta=@ruta, @hoja='Clasificacion productos', @tabla = '#ClasificacionProducto';
	
	INSERT INTO productos.LineaProducto (nombre) -- Ver si insertar usando los SP de inserci�n
		SELECT DISTINCT [L�nea de producto]
		FROM #ClasificacionProducto;

	INSERT INTO productos.Categoria -- Ver si insertar usando los SP de inserci�n
		SELECT [Producto], lp.id
		FROM #ClasificacionProducto AS cp INNER JOIN productos.LineaProducto AS lp ON cp.[L�nea de producto] = lp.nombre;
END;
GO

CREATE OR ALTER PROCEDURE importacion.CargarLineasDeProducto @ruta VARCHAR(256) AS
BEGIN
	EXEC importacion.ImportarClasificacionProducto @ruta=@ruta;

	EXEC productos.InsertarLineaProducto @nombre = 'Electr�nica';
	EXEC productos.InsertarLineaProducto @nombre = 'Importados';
END;
GO

CREATE OR ALTER PROCEDURE importacion.ImportarEmpleados @ruta VARCHAR(256) AS
BEGIN
	DROP TABLE IF EXISTS #Empleado;
	CREATE TABLE #Empleado(id CHAR(6), nombre VARCHAR(200), apellido VARCHAR(200), dni DECIMAL(30,10), direccion VARCHAR(100), emailPersonal VARCHAR(200), emailEmpresa VARCHAR(200), cuil CHAR(11), cargo VARCHAR(30), sucursal VARCHAR(50), turno VARCHAR(20));

	DECLARE @tabla VARCHAR(256);
	DECLARE @hoja VARCHAR(31);
	SET @tabla = '#Empleado';
	SET @hoja = 'Empleados';

	DECLARE @sql NVARCHAR(1024);

	EXEC sp_configure 'show advanced options', 1;
	RECONFIGURE WITH OVERRIDE;
	EXEC sp_configure 'ad hoc distributed queries', 1;
	RECONFIGURE WITH OVERRIDE;

	SET @sql = N'
		INSERT INTO '+ @tabla +'
			SELECT 
				CAST([Legajo/ID] AS VARCHAR(6)),
				CAST(Nombre AS VARCHAR(200)),
				CAST(Apellido AS VARCHAR(200)),
				CAST(DNI AS DECIMAL(30,10)),
				CAST(Direccion AS VARCHAR(100)),
				CAST([email personal] AS VARCHAR(200)),
				CAST([email empresa] AS VARCHAR(200)),
				CAST(CUIL AS CHAR(11)),
				CAST(Cargo AS VARCHAR(30)),
				CAST(Sucursal AS VARCHAR(50)),
				CAST(Turno AS VARCHAR(20))
			FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'', ''Excel 12.0; Database=' + @ruta + ';HDR=YES'', ''SELECT * FROM [' + @hoja + '$]'')
	';

	EXEC sp_executesql @sql;

	EXEC sp_configure 'ad hoc distributed queries', 0;
	RECONFIGURE WITH OVERRIDE;
	EXEC sp_configure 'show advanced options', 0;
	RECONFIGURE WITH OVERRIDE;

	-- Cargos
	INSERT INTO negocio.Cargo (nombre)
	SELECT DISTINCT cargo 
	FROM #Empleado WHERE cargo IS NOT NULL
	
	-- Empleados
	INSERT INTO negocio.Empleado
	SELECT
		LOWER(REPLACE(nombre, CHAR(9), ' ')),
		LOWER(REPLACE(apellido, CHAR(9), ' ')),
		CAST(dni AS INT), 
		direccion,
		LOWER(REPLACE(emailPersonal, CHAR(9), '')),
		LOWER(REPLACE(emailEmpresa, CHAR(9) , '')),
		CASE
			WHEN cuil IS NULL THEN (SELECT cuilGenerico FROM negocio.Configuracion)
			ELSE CAST(cuil AS BIGINT)
		END,
		(SELECT id FROM negocio.Cargo WHERE nombre=cargo),
		(SELECT id FROM negocio.Sucursal WHERE nombre = sucursal),
		turno
	FROM #Empleado AS e
	WHERE nombre IS NOT NULL;
END
GO

CREATE OR ALTER PROCEDURE importacion.ImportarMediosDePago @ruta VARCHAR(256) AS
BEGIN
	DROP TABLE IF EXISTS #MedioDePago;
	CREATE TABLE #MedioDePago(nombre VARCHAR(50), reemplazarPor VARCHAR(50));
	
	DECLARE @tabla VARCHAR(256);
	DECLARE @hoja VARCHAR(31);
	SET @tabla = '#MedioDePago';
	SET @hoja = 'medios de pago';

	DECLARE @sql NVARCHAR(1024);

	EXEC sp_configure 'show advanced options', 1;
	RECONFIGURE WITH OVERRIDE;
	EXEC sp_configure 'ad hoc distributed queries', 1;
	RECONFIGURE WITH OVERRIDE;

	SET @sql = N'
		INSERT INTO '+ @tabla +'
			SELECT *
			FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'', ''Excel 12.0; Database=' + @ruta + ';HDR=NO'', ''SELECT * FROM [' + @hoja + '$B3:C5]'')
	';

	EXEC sp_executesql @sql;

	EXEC sp_configure 'ad hoc distributed queries', 0;
	RECONFIGURE WITH OVERRIDE;
	EXEC sp_configure 'show advanced options', 0;
	RECONFIGURE WITH OVERRIDE;

	-- Insertar Medios de Pago
	INSERT INTO ventas.MedioPago
	SELECT * FROM #MedioDePago;
END
GO

CREATE OR ALTER PROCEDURE importacion.ImportarSucursal @ruta VARCHAR(256) AS
BEGIN
	DROP TABLE IF EXISTS #Sucursal;
	CREATE TABLE #Sucursal(ciudad VARCHAR(50), reemplazarPor VARCHAR(50), direccion VARCHAR(100), horario VARCHAR(100), telefono CHAR(9));
	
	DECLARE @tabla VARCHAR(256);
	DECLARE @hoja VARCHAR(31);
	SET @tabla = '#Sucursal';
	SET @hoja = 'sucursal';

	DECLARE @sql NVARCHAR(1024);

	EXEC importacion.ImportarXlsx @tabla=@tabla, @hoja=@hoja, @ruta=@ruta

	INSERT INTO negocio.Sucursal (nombre, direccion, horario, telefono, ciudad)
	SELECT reemplazarPor, direccion, horario, telefono, ciudad
	FROM #Sucursal WHERE direccion IS NOT NULL
END
GO

-- SP para cargar toda la informaci�n del archivo de informaci�n complementaria
CREATE OR ALTER PROCEDURE importacion.ImportarInformacionComplementaria @ruta VARCHAR(256) AS
BEGIN
	EXEC importacion.CargarLineasDeProducto @ruta=@ruta
	EXEC importacion.ImportarMediosDePago @ruta=@ruta
	EXEC importacion.ImportarSucursal @ruta=@ruta
	EXEC importacion.ImportarEmpleados @ruta=@ruta
END
GO

-- Creaci�n de Store Procedures para importar cat�logos

CREATE OR ALTER PROCEDURE importacion.ImportarCatalogoCsv @ruta VARCHAR(256) AS
BEGIN
	DROP TABLE IF EXISTS #CatalogoCsv;
	CREATE TABLE #CatalogoCsv (id VARCHAR(30) primary key, category VARCHAR(50), name VARCHAR(100), price VARCHAR(30), reference_price VARCHAR(30), reference_unit VARCHAR(30), date VARCHAR(30));

	DECLARE @catalogo CHAR(3);
	SET @catalogo = 'CSV';

	EXEC importacion.ImportarCsv @ruta=@ruta, @tabla='#CatalogoCsv';
	
	-- Reemplazar caracter ? por �
	UPDATE #CatalogoCsv
	SET name=REPLACE(name, '?', '�');

	-- Obtener duplicados
	WITH CatalogoConCantidad AS(
		SELECT name, COUNT(name) AS cantidad
		FROM #CatalogoCsv
		GROUP BY name
	),
	Duplicado AS(
		SELECT * FROM CatalogoConCantidad
		WHERE cantidad > 1
	)
	
	-- Insertar en tabla de errores
	INSERT INTO importacion.ErroresCatalogoCsv
	SELECT id, category, cc.name, price, reference_price, reference_unit, date, GETDATE()
	FROM #CatalogoCsv AS cc INNER JOIN Duplicado AS d ON cc.name = d.name;

	-- Eliminar duplicados
	DELETE FROM #CatalogoCsv
	WHERE name IN (
		SELECT name
		FROM importacion.ErroresCatalogoCsv
	);

	-- Borrado l�gico para los productos que no est�n inclu�dos en el cat�logo actualizado
	UPDATE productos.Producto
	SET estado='I'
	WHERE nombre NOT IN (SELECT name FROM #CatalogoCsv) AND catalogo = @catalogo;

	-- Actualizar existentes
	UPDATE productos.Producto
	SET nombre = c.name, precioUnitario = c.price, idLineaProd = (SELECT lp.id FROM productos.LineaProducto AS lp INNER JOIN productos.Categoria AS cat ON cat.idLineaProd = lp.id WHERE cat.nombre = c.category), estado='A'
	FROM productos.Producto AS p, #CatalogoCsv AS c
	WHERE p.nombre = c.name;

	-- Insertar los que no existen actualmente
	INSERT INTO productos.Producto (nombre, precioUnitario, idLineaProd, catalogo)
		SELECT cc.name, CAST(cc.price AS DECIMAL(10, 2)) AS precioUnitario, CAST(lp.idLineaProd AS INT) AS idLineaProd, @catalogo
		FROM #CatalogoCsv AS cc INNER JOIN productos.Categoria AS lp ON cc.category = lp.nombre
		WHERE NOT EXISTS (SELECT 1 FROM productos.Producto WHERE nombre = cc.name);
END
GO

-- Creaci�n de Store Procedures para importar las ventas

CREATE OR ALTER PROCEDURE importacion.ImportarVentas @ruta VARCHAR(256) AS
BEGIN
	DROP TABLE IF EXISTS #Venta;
	CREATE TABLE #Venta (idFactura CHAR(11), tipoFactura CHAR(1), ciudad VARCHAR(50), tipoCliente VARCHAR(20), genero VARCHAR(20), producto VARCHAR(100), precioUnitario VARCHAR(10), cantidad VARCHAR(10), fecha VARCHAR(10), hora VARCHAR(10), medioDePago VARCHAR(50), empleado VARCHAR(10), idPago VARCHAR(50));

	DECLARE @sql NVARCHAR(256) = N'
		BULK INSERT ' + '#Venta' + '
		FROM ''' + @ruta + '''
		WITH
		(
			ROWTERMINATOR = ''\n'',
			FIRSTROW = 2,
			FORMAT = ''CSV'',
			CODEPAGE = ''65001'',
			FIELDTERMINATOR = '';''
		)';
	EXEC sp_executesql @sql;

	ALTER TABLE #Venta
	ADD numeroFila INT;

	WITH cte AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY idFactura) AS numeroFilaCTE,
		*
    FROM #Venta
	)
	UPDATE #Venta
	SET numeroFila = c.numeroFilaCTE
	FROM #Venta v
	INNER JOIN cte c ON v.idFactura = c.idFactura;

	UPDATE #Venta
	SET producto = REPLACE(producto, 'Ãº', '�')
	WHERE producto LIKE '%Ãº%';

	UPDATE #Venta
	SET producto = REPLACE(producto, 'é', '�')
	WHERE producto LIKE '%é%';

	UPDATE #Venta
	SET producto = REPLACE(producto, 'ñ', '�')
	WHERE producto LIKE '%ñ%';

	UPDATE #Venta
	SET producto = REPLACE(producto, 'á', '�')
	WHERE producto LIKE '%á%';

	UPDATE #Venta
	SET producto = REPLACE(producto, 'ó', '�')
	WHERE producto LIKE '%ó%';

	UPDATE #Venta
	SET producto = REPLACE(producto, 'í', '�')
	WHERE producto LIKE '%í%';

	UPDATE #Venta
	SET producto = REPLACE(producto, 'ú', '�')
	WHERE producto LIKE '%ú%';

	UPDATE #Venta
	SET producto = REPLACE(producto, 'º', '�')
	WHERE producto LIKE '%º%';

	UPDATE #Venta
	SET producto = REPLACE(producto, 'Á', '�')
	WHERE producto LIKE '%Á%';

	UPDATE #Venta
	SET producto = REPLACE(producto, 'Ñ�', '�')
	WHERE producto LIKE '%Ñ�%';

	DECLARE @numeroFila INT = 1;
	WHILE EXISTS (SELECT 1 FROM #Venta WHERE numeroFila = @numeroFila)
	BEGIN
		DECLARE @compras ventas.NuevaVentaType

		-- Insertar detalles de compra
		INSERT INTO @compras VALUES
			((SELECT id FROM productos.Producto WHERE nombre = (SELECT producto FROM #Venta WHERE numeroFila = @numeroFila)), (SELECT cantidad FROM #Venta WHERE numeroFila = @numeroFila))
			
		-- Generar venta y factura
		DECLARE @idFactura CHAR(11) = (SELECT idFactura FROM #Venta WHERE numeroFila = @numeroFila)
		DECLARE @idEmpleado INT = CAST((SELECT empleado FROM #Venta WHERE numeroFila = @numeroFila) AS INT)
		DECLARE @idSucursal INT = (SELECT id FROM #Venta v INNER JOIN negocio.Sucursal s ON s.ciudad = v.ciudad WHERE v.numeroFila = @numeroFila)
		DECLARE @tipoFactura CHAR(1) = (SELECT tipoFactura FROM #Venta WHERE numeroFila = @numeroFila)
		DECLARE @fecha DATE = (SELECT CAST(fecha AS DATE) FROM #Venta WHERE numeroFila = @numeroFila)
		DECLARE @hora TIME = (SELECT CAST(hora AS TIME) FROM #Venta WHERE numeroFila = @numeroFila)
		DECLARE @genero VARCHAR(10) = (SELECT genero FROM #Venta WHERE numeroFila = @numeroFila)
		DECLARE @tipoCliente VARCHAR(20) = (SELECT tipoCliente FROM #Venta WHERE numeroFila = @numeroFila)

		EXEC ventas.InsertarCliente @genero = @genero, @tipoCliente = @tipoCliente
		DECLARE @idCliente INT = IDENT_CURRENT('ventas.Cliente')

		EXEC ventas.generarVentaCompleta @idFactura = @idFactura, @idCliente = @idCliente, @idEmpleado = @idEmpleado, @idSucursal = @idSucursal, @compras = @compras, @IVA = 0.21, @tipoFactura = @tipoFactura, @fecha = @fecha, @hora = @hora

		DECLARE @idFacturaInsertada INT = IDENT_CURRENT('ventas.Factura')
		DECLARE @idMedioPago INT = (SELECT id FROM #Venta v INNER JOIN ventas.MedioPago m ON v.medioDePago = m.nombre WHERE numeroFila = @numeroFila)
		DECLARE @cod CHAR(50) = (SELECT idPago FROM #Venta WHERE numeroFila = @numeroFila)

		IF @cod NOT LIKE '--%'
			EXEC ventas.InsertarPago @idFactura = @idFacturaInsertada, @idMedioPago = 1, @cod = @cod
		
		DELETE @compras
		SET @numeroFila = @numeroFila + 1
	END
END
GO

CREATE OR ALTER PROCEDURE importacion.ImportarAccesoriosElectronicos @ruta VARCHAR(256) AS
BEGIN
	DROP TABLE IF EXISTS #CatalogoAccesoriosElectronicos;
	CREATE TABLE #CatalogoAccesoriosElectronicos(Product VARCHAR(30), PrecioUnitarioEnDolares VARCHAR(50));

	DECLARE @catalogo CHAR(3);
	SET @catalogo = 'ELE';

	EXEC importacion.ImportarXlsx @ruta=@ruta, @hoja='Sheet1', @tabla='#CatalogoAccesoriosElectronicos';

	DECLARE @idLineaProdElectronica INT;
	SET @idLineaProdElectronica = (SELECT id FROM productos.LineaProducto WHERE nombre = 'Electr�nica');

	-- Obtener duplicados
	WITH CatalogoConCantidad AS(
		SELECT Product, COUNT(Product) AS cantidad
		FROM #CatalogoAccesoriosElectronicos
		GROUP BY Product
	),
	Duplicado AS(
		SELECT * FROM CatalogoConCantidad
		WHERE cantidad > 1
	)
	
	-- Insertar en tabla de errores
	INSERT INTO importacion.ErroresCatalogoAccesoriosElectronicos
	SELECT cae.Product, PrecioUnitarioEnDolares, GETDATE()
	FROM #CatalogoAccesoriosElectronicos AS cae INNER JOIN Duplicado AS d ON cae.Product = d.Product;

	-- Eliminar duplicados
	DELETE FROM #CatalogoAccesoriosElectronicos
	WHERE Product IN (
		SELECT Product
		FROM importacion.ErroresCatalogoAccesoriosElectronicos
	);

	-- Borrado l�gico para los productos que no est�n inclu�dos en el cat�logo actualizado
	UPDATE productos.Producto
	SET estado='I'
	WHERE nombre NOT IN (SELECT Product FROM #CatalogoAccesoriosElectronicos) AND catalogo = @catalogo;

	-- Actualizar existentes
	UPDATE productos.Producto
	SET nombre = c.Product, precioUnitario = c.PrecioUnitarioEnDolares, idLineaProd = @idLineaProdElectronica, estado='A'
	FROM productos.Producto AS p, #CatalogoAccesoriosElectronicos AS c
	WHERE p.nombre = c.Product;

	-- Insertar los que no existen actualmente
	INSERT INTO productos.Producto (nombre, precioUnitario, idLineaProd, catalogo)
		SELECT Product, CAST(PrecioUnitarioEnDolares AS DECIMAL(10, 2)), idLineaProd = @idLineaProdElectronica, @catalogo
		FROM #CatalogoAccesoriosElectronicos AS cae
		WHERE NOT EXISTS (SELECT 1 FROM productos.Producto WHERE nombre = cae.Product);
END;
GO

CREATE OR ALTER PROCEDURE importacion.ImportarProductosImportados @ruta VARCHAR(256) AS
BEGIN
	DROP TABLE IF EXISTS #CatalogoProductosImportados;
	CREATE TABLE #CatalogoProductosImportados(IdProducto VARCHAR(30), NombreProducto VARCHAR(50), Proveedor VARCHAR(50), Categor�a VARCHAR(30), CantidadPorUnidad VARCHAR(30), PrecioUnidad VARCHAR(30));

	DECLARE @catalogo CHAR(3);
	SET @catalogo = 'IMP';

	EXEC importacion.ImportarXlsx @ruta=@ruta, @hoja='Listado de Productos', @tabla='#CatalogoProductosImportados';

	DECLARE @idLineaProdImportados INT;
	SET @idLineaProdImportados = (SELECT id FROM productos.LineaProducto WHERE nombre = 'Importados');

	-- Obtener duplicados
	WITH CatalogoConCantidad AS(
		SELECT NombreProducto, COUNT(NombreProducto) AS cantidad
		FROM #CatalogoProductosImportados
		GROUP BY NombreProducto
	),
	Duplicado AS(
		SELECT * FROM CatalogoConCantidad
		WHERE cantidad > 1
	)
	
	-- Insertar en tabla de errores
	INSERT INTO importacion.ErroresCatalogoProductosImportados
	SELECT IdProducto, cpi.NombreProducto, Proveedor, Categor�a, CantidadPorUnidad, PrecioUnidad, GETDATE()
	FROM #CatalogoProductosImportados AS cpi INNER JOIN Duplicado AS d ON cpi.NombreProducto = d.NombreProducto;

	-- Eliminar duplicados
	DELETE FROM #CatalogoProductosImportados
	WHERE NombreProducto IN (
		SELECT NombreProducto
		FROM importacion.ErroresCatalogoProductosImportados
	);

	-- Borrado l�gico para los productos que no est�n inclu�dos en el cat�logo actualizado
	UPDATE productos.Producto
	SET estado='I'
	WHERE nombre NOT IN (SELECT NombreProducto FROM #CatalogoProductosImportados) AND catalogo = @catalogo;

	-- Actualizar existentes
	UPDATE productos.Producto
	SET nombre = cpi.NombreProducto, precioUnitario = cpi.PrecioUnidad, idLineaProd = @idLineaProdImportados, idProveedor = (SELECT id FROM productos.Proveedor WHERE nombre = cpi.Proveedor), estado='A'
	FROM productos.Producto AS p, #CatalogoProductosImportados AS cpi
	WHERE p.nombre = cpi.NombreProducto;

	-- Eliminar existentes de inserci�n
	DELETE FROM #CatalogoProductosImportados
	WHERE NombreProducto IN (
		SELECT nombre
		FROM productos.Producto
	);

	-- Insertar proveedores
	INSERT INTO productos.Proveedor
	SELECT DISTINCT Proveedor
	FROM #CatalogoProductosImportados
	WHERE NOT EXISTS(SELECT 1 FROM productos.Proveedor WHERE nombre = Proveedor)
	
	-- Insertar los que no tienen duplicados
	INSERT INTO productos.Producto (nombre, precioUnitario, cantidadPorUnidad, idLineaProd, idProveedor, catalogo)
		SELECT NombreProducto, CAST(PrecioUnidad AS DECIMAL(10, 2)), CantidadPorUnidad, @idLineaProdImportados, (SELECT id FROM productos.Proveedor WHERE nombre = cpi.Proveedor), @catalogo
		FROM #CatalogoProductosImportados AS cpi
		WHERE NOT EXISTS (SELECT 1 FROM productos.Producto WHERE nombre = cpi.NombreProducto);
END
GO

CREATE OR ALTER PROCEDURE importacion.InsertarDatosFaltantes AS
BEGIN
	-- Se insertan los tipos de factura que no vienen en la informaci�n complementaria
	INSERT INTO ventas.TipoFactura VALUES
	('A'), ('B'), ('C'), ('E'), ('M'), ('T')

	-- Se insertan clientes que no vienen en la informaci�n complementaria
	EXEC ventas.InsertarCliente @nombre = 'Juan', @apellido = 'L�pez', @dni = 12345678, @genero = 'Male', @tipoCliente = 'Member'
	EXEC ventas.InsertarCliente @nombre = 'Ana', @apellido = 'Garc�a', @dni = 22345678, @genero = 'Female', @tipoCliente = 'Normal'
	EXEC ventas.InsertarCliente @nombre = 'Diego', @apellido = 'D�az', @dni = 72345678, @genero = 'Male', @tipoCliente = 'Normal'

	EXEC negocio.InsertarConfiguracion @cuit = NULL, @cuitGenerico = 20222222223, @cuilGenerico = 00000000000
END