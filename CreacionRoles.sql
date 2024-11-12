CREATE OR ALTER PROCEDURE CrearRolesDesdeTablaCargo
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
EXEC CrearRolesDesdeTablaCargo;
GO

-- Verificamos si los roles fueron creados
SELECT name
FROM sys.database_principals
WHERE type = 'R';
GO

--Falta crear usuarios para que se puedan asignar los roles
/*
CREATE OR ALTER PROCEDURE AsignarRolAEmpleado
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX);

    -- Inicializamos la variable @sql
    SET @sql = '';

    -- Construir dinámicamente el SQL para asignar roles a los usuarios
    SELECT @sql = @sql + 
        'EXEC sp_addrolemember ''' + c.nombre + ''', ''' + e.nombre + ''';'
    FROM negocio.Empleado e
    INNER JOIN negocio.Cargo c ON e.idCargo = c.id  -- Hacemos el JOIN entre Empleado y Cargo
    WHERE c.nombre IS NOT NULL AND e.nombre IS NOT NULL;

    -- Ejecutar el SQL dinámico
    EXEC sp_executesql @sql;

    PRINT 'Roles asignados a los Empleados desde su tabla correspondiente.';
END;

EXEC AsignarRolAEmpleado;
*/

