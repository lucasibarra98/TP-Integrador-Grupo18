/*
Entrega 4
	Se proveen maestros de XXX.
	Ver archivo “Datasets para importar” en Miel.

	Se requiere que importe toda la información antes mencionada a la base de datos:
	• Genere los objetos necesarios (store procedures, funciones, etc.) para importar los
	archivos antes mencionados. Tenga en cuenta que cada mes se recibirán archivos de
	novedades con la misma estructura, pero datos nuevos para agregar a cada maestro.
	• Considere este comportamiento al generar el código. Debe admitir la importación de
	novedades periódicamente.
	• Cada maestro debe importarse con un SP distinto. No se aceptarán scripts que
	realicen tareas por fuera de un SP.
	• La estructura/esquema de las tablas a generar será decisión suya. Puede que deba
	realizar procesos de transformación sobre los maestros recibidos para adaptarlos a la
	estructura requerida.
	Trabajo Práctico Integrador
	Pág. 9 de 10
	• Los archivos CSV/JSON no deben modificarse. En caso de que haya datos mal
	cargados, incompletos, erróneos, etc., deberá contemplarlo y realizar las correcciones
	en el fuente SQL. (Sería una excepción si el archivo está malformado y no es posible
	interpretarlo como JSON o CSV). 
*/

USE Com2900G18;
GO

-- Creación de Store Procedures para importar xlsx y csv de forma genérica

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
	Creación de Store Procedure para importar tabla de clasificación de productos en tabla temporal
	y cargar tablas de línea de producto y categoría
*/

CREATE OR ALTER PROCEDURE importacion.ImportarClasificacionProducto @ruta VARCHAR(256) AS
BEGIN
	DROP TABLE IF EXISTS #ClasificacionProducto;
	CREATE TABLE #ClasificacionProducto([Línea de producto] VARCHAR(40), Producto VARCHAR(50));

	EXEC importacion.ImportarXlsx @ruta=@ruta, @hoja='Clasificacion productos', @tabla = '#ClasificacionProducto';
	
	INSERT INTO productos.LineaProducto (nombre) -- Ver si insertar usando los SP de inserción
		SELECT DISTINCT [Línea de producto]
		FROM #ClasificacionProducto;

	INSERT INTO productos.Categoria -- Ver si insertar usando los SP de inserción
		SELECT [Producto], lp.id
		FROM #ClasificacionProducto AS cp INNER JOIN productos.LineaProducto AS lp ON cp.[Línea de producto] = lp.nombre;
END;
GO

CREATE OR ALTER PROCEDURE importacion.CargarLineasDeProducto @ruta VARCHAR(256) AS
BEGIN
	EXEC importacion.ImportarClasificacionProducto @ruta=@ruta;

	EXEC productos.InsertarLineaProducto @nombre = 'Electrónica';
	EXEC productos.InsertarLineaProducto @nombre = 'Importados';
END;
GO

CREATE OR ALTER PROCEDURE importacion.ImportarEmpleados @ruta VARCHAR(256) AS
BEGIN
	DROP TABLE IF EXISTS #Empleado;
	CREATE TABLE #Empleado(id CHAR(6), nombre VARCHAR(200), apellido VARCHAR(200), dni DECIMAL(30,10), direccion VARCHAR(100), emailPersonal VARCHAR(200), emailEmpresa VARCHAR(200), cuil CHAR(11), cargo VARCHAR(30), ciudad VARCHAR(50), turno VARCHAR(20));

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
		REPLACE(nombre, CHAR(9), ' '),
		REPLACE(apellido, CHAR(9), ' '),
		CAST(dni AS INT), 
		(SELECT id FROM negocio.Domicilio 
			WHERE calle = LEFT(TRIM(LEFT(direccion, PATINDEX('%,%', direccion) - 1)), LEN(TRIM(LEFT(direccion, PATINDEX('%,%', direccion) - 1))) - PATINDEX('% %', REVERSE(TRIM(LEFT(direccion, PATINDEX('%,%', direccion) - 1)))))
			AND numero = LEFT(RIGHT(TRIM(LEFT(direccion, PATINDEX('%,%', direccion))), PATINDEX('% %', REVERSE(direccion))), LEN(RIGHT(TRIM(LEFT(direccion, PATINDEX('%,%', direccion))), PATINDEX('% %', REVERSE(direccion)))) - 2)
		),
		LOWER(REPLACE(emailPersonal, CHAR(9), '')),
		LOWER(REPLACE(emailEmpresa, CHAR(9) , '')),
		CAST(cuil AS BIGINT),
		(SELECT id FROM negocio.Cargo WHERE nombre=cargo),
		(SELECT id FROM negocio.Sucursal WHERE idDomicilio = (SELECT TOP 1 id FROM negocio.Domicilio WHERE idCiudad = (SELECT id FROM negocio.Ciudad WHERE nombre COLLATE Modern_Spanish_CI_AI = ciudad))),
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

	-- Cargar ciudades para reemplazarPor
	UPDATE negocio.Ciudad
	SET reemplazaPor = S.ciudad FROM negocio.Ciudad C INNER JOIN #Sucursal S ON S.reemplazarPor COLLATE Modern_Spanish_CI_AI = C.nombre

	-- Sucursales
	INSERT INTO negocio.Sucursal (idDomicilio, horario, telefono)
	SELECT (SELECT id
		FROM negocio.Domicilio 
		WHERE calle = REPLACE(LEFT(direccion, PATINDEX('%[1-9]%', direccion) - 1), CHAR(160), '')
		AND numero = SUBSTRING(direccion, PATINDEX('%[1-9]%', direccion), PATINDEX('%,%', direccion) - PATINDEX('%[1-9]%', direccion))),
		horario,
		telefono
	FROM #Sucursal WHERE direccion IS NOT NULL
END
GO

-- SP para cargar toda la información del archivo de información complementaria
CREATE OR ALTER PROCEDURE importacion.ImportarInformacionComplementaria @ruta VARCHAR(256) AS
BEGIN
	-- Importación de Líneas de producto
	EXEC importacion.CargarLineasDeProducto @ruta=@ruta

	-- Medios de pago
	EXEC importacion.ImportarMediosDePago @ruta=@ruta

	-- Provincias
	INSERT INTO negocio.Provincia VALUES ('Buenos Aires'), ('Ciudad Autónoma de Buenos Aires');

	DECLARE @idBuenosAires INT;
	DECLARE @idCABA INT;
	SET @idBuenosAires = (SELECT id FROM negocio.Provincia WHERE nombre = 'Buenos Aires'); 
	SET @idCABA = (SELECT id FROM negocio.Provincia WHERE nombre = 'Ciudad Autónoma de Buenos Aires');
	
	-- Ciudades
	INSERT INTO negocio.Ciudad (nombre, idProvincia) VALUES
		('Ciudad Autónoma de Buenos Aires', @idCABA),
		('San Justo', @idBuenosAires),
		('Ramos Mejía', @idBuenosAires),
		('Lomas del Mirador', @idBuenosAires),
		('San Isidro', @idBuenosAires),
		('Hurlingham', @idBuenosAires),
		('Avellaneda', @idBuenosAires),
		('La Plata', @idBuenosAires),
		('Malvinas Argentinas', @idBuenosAires),
		('San Martín', @idBuenosAires),
		('Carapachay', @idBuenosAires),
		('Chilavert', @idBuenosAires);
		
	-- Domicilios
	INSERT INTO negocio.Domicilio (calle, numero, idCiudad, codigoPostal) VALUES
		('Av. Brig. Gral. Juan Manuel de Rosas', 3634, (SELECT id FROM negocio.Ciudad WHERE nombre = 'San Justo'), 'B1754'),
		('Av. de Mayo', 791, (SELECT id FROM negocio.Ciudad WHERE nombre = 'Ramos Mejía'), 'B1704'),
		('Pres. Juan Domingo Perón', 763, (SELECT id FROM negocio.Ciudad WHERE nombre = 'Lomas del Mirador'), 'B1704'),
		('Bernardo de Irigoyen', 2647, (SELECT id FROM negocio.Ciudad WHERE nombre = 'San Isidro'), NULL),
		('Av. Vergara', 1910, (SELECT id FROM negocio.Ciudad WHERE nombre = 'Hurlingham'), NULL),
		('Av. Belgrano', 422, (SELECT id FROM negocio.Ciudad WHERE nombre = 'Avellaneda'), NULL),
		('Calle 7 ', 767, (SELECT id FROM negocio.Ciudad WHERE nombre = 'La Plata'), NULL),
		('Av. Arturo Illia', 3770, (SELECT id FROM negocio.Ciudad WHERE nombre = 'Malvinas Argentinas'), NULL),
		('Av. Rivadavia', 6538, (SELECT id FROM negocio.Ciudad WHERE nombre = 'Ciudad Autónoma de Buenos Aires'), NULL),
		('Av. Don Bosco', 2680, (SELECT id FROM negocio.Ciudad WHERE nombre = 'San Justo'), NULL),
		('Av. Santa Fe', 1954, (SELECT id FROM negocio.Ciudad WHERE nombre = 'Ciudad Autónoma de Buenos Aires'), NULL),
		('Av. San Martín', 420, (SELECT id FROM negocio.Ciudad WHERE nombre = 'San Martín'), NULL),
		('Independencia', 3067, (SELECT id FROM negocio.Ciudad WHERE nombre = 'Carapachay'), NULL),
		('Av. Rivadavia', 2243, (SELECT id FROM negocio.Ciudad WHERE nombre = 'Ciudad Autónoma de Buenos Aires'), NULL),
		('Juramento', 2971, (SELECT id FROM negocio.Ciudad WHERE nombre = 'Ciudad Autónoma de Buenos Aires'), NULL),
		('Av. Presidente Hipólito Yrigoyen', 299, NULL, NULL),
		('Lacroze', 5910, (SELECT id FROM negocio.Ciudad WHERE nombre = 'Chilavert'), NULL);

	-- Importación de sucursal
	EXEC importacion.ImportarSucursal @ruta=@ruta

	-- Importación de empleados
	EXEC importacion.ImportarEmpleados @ruta=@ruta		
END
GO

-- Creación de Store Procedures para importar catálogos

CREATE OR ALTER PROCEDURE importacion.ImportarCatalogoCsv @ruta VARCHAR(256) AS
BEGIN
	DROP TABLE IF EXISTS #CatalogoCsv;
	CREATE TABLE #CatalogoCsv (id VARCHAR(30) primary key, category VARCHAR(50), name VARCHAR(100), price VARCHAR(30), reference_price VARCHAR(30), reference_unit VARCHAR(30), date VARCHAR(30));

	DECLARE @catalogo CHAR(3);
	SET @catalogo = 'CSV';

	EXEC importacion.ImportarCsv @ruta=@ruta, @tabla='#CatalogoCsv';
	
	-- Reemplazar caracter ? por ñ
	UPDATE #CatalogoCsv
	SET name=REPLACE(name, '?', 'ñ');

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

	-- Borrado lógico para los productos que no están incluídos en el catálogo actualizado
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

CREATE OR ALTER PROCEDURE importacion.ImportarAccesoriosElectronicos @ruta VARCHAR(256) AS
BEGIN
	DROP TABLE IF EXISTS #CatalogoAccesoriosElectronicos;
	CREATE TABLE #CatalogoAccesoriosElectronicos(Product VARCHAR(30), PrecioUnitarioEnDolares VARCHAR(50));

	DECLARE @catalogo CHAR(3);
	SET @catalogo = 'ELE';

	EXEC importacion.ImportarXlsx @ruta=@ruta, @hoja='Sheet1', @tabla='#CatalogoAccesoriosElectronicos';

	DECLARE @idLineaProdElectronica INT;
	SET @idLineaProdElectronica = (SELECT id FROM productos.LineaProducto WHERE nombre = 'Electrónica');

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

	-- Borrado lógico para los productos que no están incluídos en el catálogo actualizado
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
	CREATE TABLE #CatalogoProductosImportados(IdProducto VARCHAR(30), NombreProducto VARCHAR(50), Proveedor VARCHAR(50), Categoría VARCHAR(30), CantidadPorUnidad VARCHAR(30), PrecioUnidad VARCHAR(30));

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
	SELECT IdProducto, cpi.NombreProducto, Proveedor, Categoría, CantidadPorUnidad, PrecioUnidad, GETDATE()
	FROM #CatalogoProductosImportados AS cpi INNER JOIN Duplicado AS d ON cpi.NombreProducto = d.NombreProducto;

	-- Eliminar duplicados
	DELETE FROM #CatalogoProductosImportados
	WHERE NombreProducto IN (
		SELECT NombreProducto
		FROM importacion.ErroresCatalogoProductosImportados
	);

	-- Borrado lógico para los productos que no están incluídos en el catálogo actualizado
	UPDATE productos.Producto
	SET estado='I'
	WHERE nombre NOT IN (SELECT NombreProducto FROM #CatalogoProductosImportados) AND catalogo = @catalogo;

	-- Actualizar existentes
	UPDATE productos.Producto
	SET nombre = cpi.NombreProducto, precioUnitario = cpi.PrecioUnidad, idLineaProd = @idLineaProdImportados, idProveedor = (SELECT id FROM productos.Proveedor WHERE nombre = cpi.Proveedor), estado='A'
	FROM productos.Producto AS p, #CatalogoProductosImportados AS cpi
	WHERE p.nombre = cpi.NombreProducto;

	-- Eliminar existentes de inserción
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