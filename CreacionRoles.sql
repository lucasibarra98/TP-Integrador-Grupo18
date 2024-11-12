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

EXEC CrearRolesDesdeTablaCargo;
GO

SELECT name
FROM sys.database_principals
WHERE type = 'R';
GO