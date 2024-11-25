USE Com2900G18
GO

-- Creamos los logins para cada cargo

CREATE LOGIN LoginCajero WITH PASSWORD = 'Cajero.suc';
CREATE LOGIN LoginSupervisor WITH PASSWORD = 'Supervisor.suc';
CREATE LOGIN LoginGerente WITH PASSWORD = 'Gerente.suc';
GO

-- Creamos usuarios y asignamos login correspondiente

CREATE USER Cajero_Sucursal FOR LOGIN LoginCajero;
CREATE USER Supervisor_Sucursal FOR LOGIN LoginSupervisor;
CREATE USER Gerente_Sucursal FOR LOGIN LoginGerente;
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
    dp.name = 'Supervisor';


--Probamos uno de los permisos

EXECUTE AS LOGIN = 'LoginCajero'; 

DELETE FROM productos.Producto WHERE id = 1;