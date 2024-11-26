/*
	Entrega 5

	Cuando un cliente reclama la devolución de un producto se genera una nota de crédito por el
	valor del producto o un producto del mismo tipo.
	En el caso de que el cliente solicite la nota de crédito, solo los Supervisores tienen el permiso
	para generarla.
	Tener en cuenta que la nota de crédito debe estar asociada a una Factura con estado pagada.
	Asigne los roles correspondientes para poder cumplir con este requisito.
	Por otra parte, se requiere que los datos de los empleados se encuentren encriptados, dado
	que los mismos contienen información personal.
	La información de las ventas es de vital importancia para el negocio, por ello se requiere que
	se establezcan políticas de respaldo tanto en las ventas diarias generadas como en los
	reportes generados.
	Plantee una política de respaldo adecuada para cumplir con este requisito y justifique la
	misma.
*/

USE Com2900G18
GO

-- Creamos los logins y usuarios para cada cargo y hacemos la asignacion correspondiente

CREATE OR ALTER PROCEDURE CrearLoginYUsuarios
AS
BEGIN

	IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'LoginCajero')
	BEGIN
		CREATE LOGIN LoginCajero WITH PASSWORD = 'Cajero.suc', DEFAULT_DATABASE = Com2900G18;
		PRINT 'LoginCajero creado correctamente.';
	END
	ELSE
		PRINT 'LoginCajero ya existe.';

	IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'LoginSupervisor')
	BEGIN
		CREATE LOGIN LoginSupervisor WITH PASSWORD = 'Supervisor.suc', DEFAULT_DATABASE = Com2900G18;
		PRINT 'LoginSupervisor creado correctamente.';
	END
	ELSE
		PRINT 'LoginSupervisor ya existe.';

	IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'LoginGerente')
	BEGIN
		CREATE LOGIN LoginGerente WITH PASSWORD = 'Gerente.suc', DEFAULT_DATABASE = Com2900G18;
		PRINT 'LoginGerente creado correctamente.';
	END
	ELSE
		PRINT 'LoginGerente ya existe.';

	IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'Cajero_Sucursal')
    BEGIN
        CREATE USER Cajero_Sucursal FOR LOGIN LoginCajero;
        PRINT 'Usuario Cajero_Sucursal creado correctamente.';
    END
    ELSE
        PRINT 'Usuario Cajero_Sucursal ya existe.';

    -- Crear Usuario para Supervisor si no existe
    IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'Supervisor_Sucursal')
    BEGIN
        CREATE USER Supervisor_Sucursal FOR LOGIN LoginSupervisor;
        PRINT 'Usuario Supervisor_Sucursal creado correctamente.';
    END
    ELSE
        PRINT 'Usuario Supervisor_Sucursal ya existe.';

    -- Crear Usuario para Gerente si no existe
    IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'Gerente_Sucursal')
    BEGIN
        CREATE USER Gerente_Sucursal FOR LOGIN LoginGerente;
        PRINT 'Usuario Gerente_Sucursal creado correctamente.';
    END
    ELSE
        PRINT 'Usuario Gerente_Sucursal ya existe.';
END;
GO

EXEC CrearLoginYUsuarios;
GO

CREATE OR ALTER PROCEDURE CrearRoles
AS
BEGIN
    -- Declaramos la variable para almacenar el SQL dinámico
    DECLARE @sql NVARCHAR(MAX);

    -- Inicializamos la variable @sql
    SET @sql = '';


    SELECT @sql = @sql + 
        'IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE type = ''R'' AND name = ''' + nombre + ''') 
        BEGIN 
            EXEC sp_executesql N''CREATE ROLE [' + nombre + ']''; 
        END; '
    FROM negocio.Cargo;

    -- Ejecutamos
    EXEC sp_executesql @sql;

    PRINT 'Se crearon los roles correctamente.';
END;
GO

-- Ejecutamos el SP para que se creen los roles
EXEC CrearRoles;
GO

-- Verificamos si los roles fueron creados
SELECT name
FROM sys.database_principals
WHERE type = 'R';
GO

-- Asignamos los roles a los usuarios
EXEC sp_addrolemember 'Cajero', 'Cajero_Sucursal';
EXEC sp_addrolemember 'Supervisor', 'Supervisor_Sucursal';
EXEC sp_addrolemember 'Gerente de Sucursal', 'Gerente_Sucursal';
GO


CREATE OR ALTER PROCEDURE AsignarPermisos
    @Rol NVARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificamos si existe el rol
    IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = @Rol AND type = 'R')
    BEGIN
        PRINT 'El rol especificado no existe.';
        RETURN;
    END

    DECLARE @Sql NVARCHAR(MAX);

    -- Asignamos permisos según el rol
    IF @Rol = 'Cajero'
    BEGIN
        SET @Sql = '
        GRANT SELECT ON productos.Producto TO ' + QUOTENAME(@Rol) + ';
        GRANT SELECT ON ventas.Cliente TO ' + QUOTENAME(@Rol) + ';
        GRANT SELECT, INSERT ON ventas.Venta TO ' + QUOTENAME(@Rol) + ';
        GRANT INSERT ON ventas.DetalleVenta TO ' + QUOTENAME(@Rol) + ';
        GRANT INSERT, SELECT ON ventas.Factura TO ' + QUOTENAME(@Rol) + ';
        GRANT SELECT ON ventas.MedioPago TO ' + QUOTENAME(@Rol) + ';
        ';
    END
    ELSE IF @Rol = 'Supervisor'
    BEGIN
        SET @Sql = '
        GRANT SELECT, UPDATE ON productos.Producto TO ' + QUOTENAME(@Rol) + ';
        GRANT SELECT ON productos.LineaProducto TO ' + QUOTENAME(@Rol) + ';
        GRANT SELECT ON productos.Categoria TO ' + QUOTENAME(@Rol) + ';
        GRANT SELECT ON productos.Proveedor TO ' + QUOTENAME(@Rol) + ';
        GRANT SELECT ON ventas.Cliente TO ' + QUOTENAME(@Rol) + ';
        GRANT SELECT, UPDATE ON ventas.Venta TO ' + QUOTENAME(@Rol) + ';
        GRANT SELECT ON ventas.DetalleVenta TO ' + QUOTENAME(@Rol) + ';
        GRANT SELECT, UPDATE ON ventas.Factura TO ' + QUOTENAME(@Rol) + ';
        GRANT INSERT, SELECT ON ventas.NotaCredito TO ' + QUOTENAME(@Rol) + ';
        GRANT INSERT, SELECT ON ventas.DetalleNotaCredito TO ' + QUOTENAME(@Rol) + ';
        ';
    END
    ELSE IF @Rol = 'Gerente de Sucursal'
    BEGIN
        SET @Sql = '
        GRANT SELECT, UPDATE ON productos.Producto TO ' + QUOTENAME(@Rol) + ';
        GRANT SELECT, UPDATE ON productos.LineaProducto TO ' + QUOTENAME(@Rol) + ';
        GRANT SELECT, UPDATE ON productos.Categoria TO ' + QUOTENAME(@Rol) + ';
        GRANT SELECT, UPDATE ON productos.Proveedor TO ' + QUOTENAME(@Rol) + ';
        GRANT SELECT, INSERT, UPDATE ON negocio.Empleado TO ' + QUOTENAME(@Rol) + ';
        GRANT SELECT ON negocio.Sucursal TO ' + QUOTENAME(@Rol) + ';
        GRANT SELECT, INSERT, UPDATE ON ventas.Venta TO ' + QUOTENAME(@Rol) + ';
        GRANT SELECT, INSERT, UPDATE ON ventas.DetalleVenta TO ' + QUOTENAME(@Rol) + ';
        GRANT SELECT, INSERT, UPDATE ON ventas.Factura TO ' + QUOTENAME(@Rol) + ';
        GRANT SELECT, INSERT, UPDATE ON ventas.NotaCredito TO ' + QUOTENAME(@Rol) + ';
        GRANT SELECT ON ventas.Cliente TO ' + QUOTENAME(@Rol) + ';
        ';
    END
    ELSE
    BEGIN
        PRINT 'Rol no registrado.';
        RETURN;
    END

    EXEC sp_executesql @Sql;

    PRINT 'Permisos asignados correctamente.';
END;
GO

EXEC AsignarPermisos @Rol = 'Cajero';
EXEC AsignarPermisos @Rol = 'Supervisor';
EXEC AsignarPermisos @Rol = 'Gerente de Sucursal'
GO

--Visualizamos si los permisos fueron asignados correctamente
SELECT 
    dp.name AS Rol,
    dp.type_desc AS Tipo,
    perm.permission_name AS Permiso,
    perm.state_desc AS Estado,
    obj.name AS Objeto
FROM 
    sys.database_permissions perm
JOIN 
    sys.database_principals dp ON perm.grantee_principal_id = dp.principal_id
LEFT JOIN 
    sys.objects obj ON perm.major_id = obj.object_id
WHERE 
    dp.name = 'Cajero';


--Probamos uno de los permisos (para el cajero en este caso)

/*
EXECUTE AS LOGIN = 'LoginCajero'; 

DELETE FROM productos.Producto WHERE id = 1;
*/