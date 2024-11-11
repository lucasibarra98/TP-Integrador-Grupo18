USE Com2900G18;
GO

CREATE SCHEMA importacion
GO

-- Creación de Store Procedures para importar xlsx y csv de forma genérica

CREATE OR ALTER PROCEDURE importacion.ImportarXlsx @ruta VARCHAR(256), @hoja VARCHAR(31), @tabla VARCHAR(256) AS
BEGIN
	DECLARE @sql NVARCHAR(1024)

	EXEC sp_configure 'show advanced options', 1
	RECONFIGURE WITH OVERRIDE
	EXEC sp_configure 'ad hoc distributed queries', 1
	RECONFIGURE WITH OVERRIDE

	SET @sql = N'
		INSERT INTO '+ @tabla +'
			SELECT *
			FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'', ''Excel 12.0; Database=' + @ruta + ';HDR=YES'', ''SELECT * FROM [' + @hoja + '$]'')
	'

	EXEC sp_executesql @sql;

	EXEC sp_configure 'ad hoc distributed queries', 0
	RECONFIGURE WITH OVERRIDE
	EXEC sp_configure 'show advanced options', 0
	RECONFIGURE WITH OVERRIDE
END
GO

CREATE OR ALTER PROCEDURE importacion.ImportarCsv @ruta VARCHAR(256), @tabla VARCHAR(256) AS
BEGIN
	DECLARE @sql NVARCHAR(1024) 

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
	'

	EXEC sp_executesql @sql
END
GO

/*
	Creación de Store Procedure para importar tabla de clasificación de productos en tabla temporal
	y cargar tablas de línea de producto y categoría
*/

CREATE OR ALTER PROCEDURE importacion.ImportarClasificacionProducto @ruta VARCHAR(256) AS
BEGIN
	DROP TABLE IF EXISTS #ClasificacionProducto
	CREATE TABLE #ClasificacionProducto([Línea de producto] VARCHAR(40), Producto VARCHAR(50))

	EXEC importacion.ImportarXlsx @ruta=@ruta, @hoja='Clasificacion productos', @tabla = '#ClasificacionProducto'
	
	INSERT INTO productos.LineaProducto (nombre) -- Ver si insertar usando los SP de inserción
		SELECT DISTINCT [Línea de producto]
		FROM #ClasificacionProducto

	INSERT INTO productos.Categoria -- Ver si insertar usando los SP de inserción
		SELECT [Producto], lp.id
		FROM #ClasificacionProducto AS cp INNER JOIN productos.LineaProducto AS lp ON cp.[Línea de producto] = lp.nombre
END
GO

CREATE OR ALTER PROCEDURE importacion.CargarLineasDeProducto @ruta VARCHAR(256) AS
BEGIN
	EXEC importacion.ImportarClasificacionProducto @ruta=@ruta

	EXEC productos.InsertarLineaProducto @nombre = 'Electrónica'
	EXEC productos.InsertarLineaProducto @nombre = 'Importados'
END
GO

-- Creación de Store Procedures para importar catálogos

CREATE OR ALTER PROCEDURE importacion.ImportarCatalogoCsv @ruta VARCHAR(256) AS
BEGIN
	DROP TABLE IF EXISTS #CatalogoCsv
	CREATE TABLE #CatalogoCsv (id VARCHAR(30) primary key, category VARCHAR(50), name VARCHAR(100), price VARCHAR(30), reference_price VARCHAR(30), reference_unit VARCHAR(30), date VARCHAR(30))
	CREATE TABLE #ErroresCatalogoCsv (id VARCHAR(30) primary key, category VARCHAR(50), name VARCHAR(100), price VARCHAR(30), reference_price VARCHAR(30), reference_unit VARCHAR(30), date VARCHAR(30), fechaHoraError DATETIME)

	EXEC importacion.ImportarCsv @ruta=@ruta, @tabla='#CatalogoCsv'

	-- Reemplazar caracter ? por ñ
	UPDATE #CatalogoCsv
	SET name=REPLACE(name, '?', 'ñ')

	-- Obtener duplicados
	;WITH CatalogoConCantidad AS(
		SELECT name, COUNT(name) AS cantidad
		FROM #CatalogoCsv
		GROUP BY name
	),
	Duplicado AS(
		SELECT * FROM CatalogoConCantidad
		WHERE cantidad > 1
	)
	
	-- Insertar en tabla de errores
	INSERT INTO #ErroresCatalogoCsv
	SELECT id, category, cc.name, price, reference_price, reference_unit, date, GETDATE()
	FROM #CatalogoCsv AS cc INNER JOIN Duplicado AS d ON cc.name = d.name

	-- Eliminar duplicados
	DELETE FROM #CatalogoCsv
	WHERE name IN (
		SELECT name
		FROM #ErroresCatalogoCsv
	)

	-- Borrado lógico para los productos que no están incluídos en el catálogo actualizado
	UPDATE productos.Producto
	SET estado='I'
	WHERE nombre NOT IN (SELECT name FROM #CatalogoCsv)

	-- Actualizar existentes
	UPDATE productos.Producto
	SET nombre = c.name, precioUnitario = c.price, idLineaProd = (SELECT lp.id FROM productos.LineaProducto AS lp INNER JOIN productos.Categoria AS cat ON cat.idLineaProd = lp.id WHERE cat.nombre = c.category), estado='A'
	FROM productos.Producto AS p, #CatalogoCsv AS c
	WHERE p.nombre = c.name

	-- Insertar los que no existen actualmente
	INSERT INTO productos.Producto (nombre, precioUnitario, idLineaProd)
		SELECT cc.name, CAST(cc.price AS DECIMAL(10, 2)) AS precioUnitario, CAST(lp.idLineaProd AS INT) AS idLineaProd 
		FROM #CatalogoCsv AS cc INNER JOIN productos.Categoria AS lp ON cc.category = lp.nombre
		WHERE NOT EXISTS (SELECT 1 FROM productos.Producto WHERE nombre = cc.name)
END
GO

CREATE OR ALTER PROCEDURE importacion.ImportarAccesoriosElectronicos @ruta VARCHAR(256) AS
BEGIN
	DROP TABLE IF EXISTS #CatalogoAccesoriosElectronicos
	CREATE TABLE #CatalogoAccesoriosElectronicos(Product VARCHAR(30), [Precio Unitario en dolares] VARCHAR(50))
	CREATE TABLE #ErroresCatalogoAccesoriosElectronicos(Product VARCHAR(30), [Precio Unitario en dolares] VARCHAR(50), fechaHoraError DATETIME)

	EXEC importacion.ImportarXlsx @ruta=@ruta, @hoja='Sheet1', @tabla='#CatalogoAccesoriosElectronicos'

	DECLARE @idLineaProdElectronica INT
	SET @idLineaProdElectronica = (SELECT id FROM productos.LineaProducto WHERE nombre = 'Electrónica')

	-- Obtener duplicados
	;WITH CatalogoConCantidad AS(
		SELECT Product, COUNT(Product) AS cantidad
		FROM #CatalogoAccesoriosElectronicos
		GROUP BY Product
	),
	Duplicado AS(
		SELECT * FROM CatalogoConCantidad
		WHERE cantidad > 1
	)
	
	-- Insertar en tabla de errores
	INSERT INTO #ErroresCatalogoAccesoriosElectronicos
	SELECT cae.Product, [Precio Unitario en dolares], GETDATE()
	FROM #CatalogoAccesoriosElectronicos AS cae INNER JOIN Duplicado AS d ON cae.Product = d.Product

	-- Eliminar duplicados
	DELETE FROM #CatalogoAccesoriosElectronicos
	WHERE Product IN (
		SELECT Product
		FROM #ErroresCatalogoAccesoriosElectronicos
	)

	-- Borrado lógico para los productos que no están incluídos en el catálogo actualizado
	UPDATE productos.Producto
	SET estado='I'
	WHERE nombre NOT IN (SELECT Product FROM #CatalogoAccesoriosElectronicos)

	-- Actualizar existentes
	UPDATE productos.Producto
	SET nombre = c.Product, precioUnitario = c.[Precio Unitario en dolares], idLineaProd = @idLineaProdElectronica, estado='A'
	FROM productos.Producto AS p, #CatalogoAccesoriosElectronicos AS c
	WHERE p.nombre = c.Product

	-- Insertar los que no existen actualmente
	INSERT INTO productos.Producto (nombre, precioUnitario, idLineaProd)
		SELECT Product, CAST([Precio Unitario en dolares] AS DECIMAL(10, 2)) AS precioUnitario, idLineaProd = @idLineaProdElectronica
		FROM #CatalogoAccesoriosElectronicos AS cae
		WHERE NOT EXISTS (SELECT 1 FROM productos.Producto WHERE nombre = cae.Product)
END
GO

CREATE OR ALTER PROCEDURE importacion.ImportarProductosImportados @ruta VARCHAR(256) AS
BEGIN
	DROP TABLE IF EXISTS #CatalogoProductosImportados
	CREATE TABLE #CatalogoProductosImportados(IdProducto VARCHAR(30), NombreProducto VARCHAR(50), Proveedor VARCHAR(50), Categoría VARCHAR(30), CantidadPorUnidad VARCHAR(30), PrecioUnidad VARCHAR(30))
	CREATE TABLE #ErroresCatalogoProductosImportados(IdProducto VARCHAR(30), NombreProducto VARCHAR(50), Proveedor VARCHAR(50), Categoría VARCHAR(30), CantidadPorUnidad VARCHAR(30), PrecioUnidad VARCHAR(30), fechaHoraError DATETIME)

	EXEC importacion.ImportarXlsx @ruta=@ruta, @hoja='Listado de Productos', @tabla='#CatalogoProductosImportados'

	DECLARE @idLineaProdImportados INT
	SET @idLineaProdImportados = (SELECT id FROM productos.LineaProducto WHERE nombre = 'Importados')

	-- Obtener duplicados
	;WITH CatalogoConCantidad AS(
		SELECT NombreProducto, COUNT(NombreProducto) AS cantidad
		FROM #CatalogoProductosImportados
		GROUP BY NombreProducto
	),
	Duplicado AS(
		SELECT * FROM CatalogoConCantidad
		WHERE cantidad > 1
	)
	
	-- Insertar en tabla de errores
	INSERT INTO #ErroresCatalogoProductosImportados
	SELECT IdProducto, cpi.NombreProducto, Proveedor, Categoría, CantidadPorUnidad, PrecioUnidad, GETDATE()
	FROM #CatalogoProductosImportados AS cpi INNER JOIN Duplicado AS d ON cpi.NombreProducto = d.NombreProducto

	-- Eliminar duplicados
	DELETE FROM #CatalogoProductosImportados
	WHERE NombreProducto IN (
		SELECT NombreProducto
		FROM #ErroresCatalogoProductosImportados
	)

	-- Borrado lógico para los productos que no están incluídos en el catálogo actualizado
	UPDATE productos.Producto
	SET estado='I'
	WHERE nombre NOT IN (SELECT NombreProducto FROM #CatalogoProductosImportados)

	-- Actualizar existentes
	UPDATE productos.Producto
	SET nombre = cpi.NombreProducto, precioUnitario = cpi.PrecioUnidad, idLineaProd = @idLineaProdImportados, idProveedor = (SELECT id FROM productos.LineaProducto WHERE id = @idLineaProdImportados), estado='A'
	FROM productos.Producto AS p, #CatalogoProductosImportados AS cpi
	WHERE p.nombre = cpi.NombreProducto

	-- Eliminar existentes de inserción
	DELETE FROM #CatalogoProductosImportados
	WHERE NombreProducto IN (
		SELECT nombre
		FROM productos.Producto
	)
	
	-- Insertar los que no tienen duplicados
	INSERT INTO productos.Producto (nombre, precioUnitario, idLineaProd, idProveedor)
		SELECT NombreProducto, CAST(PrecioUnidad AS DECIMAL(10, 2)) AS precioUnitario, @idLineaProdImportados, (SELECT id FROM productos.LineaProducto WHERE id = @idLineaProdImportados)
		FROM #CatalogoProductosImportados AS cpi
		WHERE NOT EXISTS (SELECT 1 FROM productos.Producto WHERE nombre = cpi.NombreProducto)
END
GO

/*
TRUNCATE TABLE productos.LineaProductos
SELECT * FROM productos.LineaProductos
SELECT * FROM productos.Categoria
DELETE productos.LineaProductos
SELECT * FROM productos.Productos
*/
--SELECT * FROM productos.Producto

DECLARE @rutaInfoComplementaria VARCHAR(256)
DECLARE @rutaCatalogoCsv VARCHAR(256)
DECLARE @rutaCatalogoElectronica VARCHAR(256)
DECLARE @rutaCatalogoImportados VARCHAR(256)

SET @rutaInfoComplementaria = 'C:\TP\TP_integrador_Archivos\Informacion_complementaria.xlsx'
SET @rutaCatalogoCsv = 'C:\TP\TP_integrador_Archivos\Productos\catalogo.csv'
SET @rutaCatalogoElectronica = 'C:\TP\TP_integrador_Archivos\Productos\Electronic accessories.xlsx'
SET @rutaCatalogoImportados = 'C:\TP\TP_integrador_Archivos\Productos\Productos_importados.xlsx'

--EXEC importacion.CargarLineasDeProducto @ruta=@rutaInfoComplementaria
EXEC importacion.ImportarCatalogoCsv @ruta=@rutaCatalogoCsv
EXEC importacion.ImportarAccesoriosElectronicos @ruta=@rutaCatalogoElectronica
EXEC importacion.ImportarProductosImportados @ruta=@rutaCatalogoImportados

/*
SELECT * FROM productos.Producto WHERE idLineaProd=12
SELECT * FROM productos.LineaProducto
SELECT * FROM productos.Producto WHERE nombre LIKE '%Medallones%'
SELECT * FROM productos.Producto
DELETE FROM productos.Producto
SELECT * FROM productos.Producto A INNER JOIN productos.Producto B ON A.nombre = B.nombre
*/