USE Com2900G18
GO

--Insercion de los datos para prueba 
/*
INSERT INTO negocio.Sucursal(nombre, direccion, horario, telefono, ciudad)
VALUES
('Sucursal Central', 'Av. Libertador 1234', 'Lunes a Viernes 9:00 - 18:00', '011123456', 'Buenos Aires'),
('Sucursal Norte', 'Calle Ficticia 5678', 'Lunes a Viernes 10:00 - 17:00', '011987654', 'San Fernando'),
('Sucursal Sur', 'Ruta 202, Km 10', 'Lunes a Viernes 8:00 - 19:00', '011345678', 'Avellaneda');
GO

INSERT INTO negocio.Cargo (nombre)
VALUES
('Cajero'),
('Supervisor'),
('Gerente de Sucursal');
GO

INSERT INTO negocio.Empleado(nombre, apellido, dni, domicilio, emailPersonal, emailEmpresa, cuil, idCargo, idSucursal, turno)
VALUES 
('Juan', 'Perez', 40000001, 'Av. Siempre Viva 123', 'juan.perez@email.com', 'juan.perez@empresa.com', 20200001, 1, 1, 'TM'),
('Ana', 'Lopez', 40000002, 'Calle Ficticia 456', 'ana.lopez@email.com', 'ana.lopez@empresa.com', 20200002, 2, 1, 'TT'),
('Carlos', 'Gomez', 40000003, 'Ruta 25 Km 10', 'carlos.gomez@email.com', 'carlos.gomez@empresa.com', 20200003, 1, 2, 'Jornada completa'),
('Maria', 'Martinez', 40000004, 'Calle Larga 789', 'maria.martinez@email.com', 'maria.martinez@empresa.com', 20200004, 3, 2, 'TM'),
('Luis', 'Fernandez', 40000005, 'Av. Libertad 101', 'luis.fernandez@email.com', 'luis.fernandez@empresa.com', 20200005, 1, 3, 'TT'),
('Laura', 'Sanchez', 40000006, 'Calle 9 de Julio 202', 'laura.sanchez@email.com', 'laura.sanchez@empresa.com', 20200006, 2, 3, 'Jornada completa'),
('Pedro', 'Rodriguez', 40000007, 'Calle de la Paz 305', 'pedro.rodriguez@email.com', 'pedro.rodriguez@empresa.com', 20200007, 3, 1, 'TM'),
('Sofia', 'Torres', 40000008, 'Calle Sol 510', 'sofia.torres@email.com', 'sofia.torres@empresa.com', 20200008, 2, 2, 'TT'),
('Ricardo', 'Vazquez', 40000009, 'Av. 25 de Mayo 80', 'ricardo.vazquez@email.com', 'ricardo.vazquez@empresa.com', 20200009, 1, 3, 'Jornada completa'),
('Elena', 'Jimenez', 40000010, 'Calle 6 Norte 408', 'elena.jimenez@email.com', 'elena.jimenez@empresa.com', 20200010, 3, 1, 'TM');
GO
*/
-- Hacemos un SP para la encriptacion de los datos

SELECT *
FROM negocio.Empleado

ALTER TABLE negocio.Empleado
ADD dniOriginal INT, domicilioOriginal VARCHAR(100), emailPersonalOriginal VARCHAR(100), cuilOriginal BIGINT;

UPDATE negocio.Empleado
SET 
    dniOriginal = CONVERT(INT, CONVERT(NVARCHAR, dni))
	cuilOriginal = cuil
	
	,
    domicilioOriginal = domicilio,
    emailPersonalOriginal = emailPersonal,
    cuilOriginal = cuil;

SELECT *
FROM negocio.Empleado

/*
CREATE OR ALTER PROCEDURE EncriptarDatosSensibles
    @Frase VARCHAR(100) -- Parámetro de frase de paso
AS
BEGIN
    -- Insertar directamente los datos encriptados en la tabla negocio.Empleado
    UPDATE negocio.Empleado
    SET
        -- Encriptar y almacenar los datos en VARBINARY en la misma tabla original
        dni = ENCRYPTBYPASSPHRASE(@Frase, CAST(dni AS VARCHAR(20))),    -- Encriptar dni (convertido a VARCHAR)
        emailPersonal = ENCRYPTBYPASSPHRASE(@Frase, emailPersonal),       -- Encriptar emailPersonal
        cuil = ENCRYPTBYPASSPHRASE(@Frase, CAST(cuil AS VARCHAR(20))),    -- Encriptar cuil (convertido a VARCHAR)
        domicilio = ENCRYPTBYPASSPHRASE(@Frase, domicilio)                -- Encriptar domicilio

    PRINT 'Datos encriptados y almacenados directamente en la tabla original.';
END;
GO

EXEC EncriptarYTransferirDatos @Frase = 'AuroraSAG18';


ALTER TABLE negocio.Empleado
ALTER COLUMN cuil VARBINARY(MAX); -- Cambia a VARBINARY(MAX)

SELECT
    id,
    --CAST(DECRYPTBYPASSPHRASE('AuroraSAG18', dni) AS VARCHAR(20)) AS dni,
    CAST(DECRYPTBYPASSPHRASE('AuroraSAG18', emailPersonal) AS VARCHAR(100)) AS emailPersonal,
    CAST(DECRYPTBYPASSPHRASE('AuroraSAG18', cuil) AS VARCHAR(20)) AS cuil,
    CAST(DECRYPTBYPASSPHRASE('AuroraSAG18', domicilio) AS VARCHAR(100)) AS domicilio
FROM negocio.Empleado;
-- Mostramos los datos encriptados

SELECT *
FROM negocio.Empleado

SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Empleado' AND COLUMN_NAME = 'cuil';


CREATE OR ALTER PROCEDURE DesencriptarYTransferirDatos
    @Frase NVARCHAR(100) -- Frase de paso para desencriptar los datos
AS
BEGIN
    -- Crear una tabla temporal para almacenar los datos desencriptados
    CREATE TABLE #EmpleadoTemp
    (
        id INT,
        emailPersonal NVARCHAR(100),
        cuil NVARCHAR(20),
        domicilio NVARCHAR(100)
    );

    -- Insertar los datos desencriptados en la tabla temporal
    INSERT INTO #EmpleadoTemp (id, emailPersonal, cuil, domicilio)
    SELECT 
        id,
        CAST(DecryptByPassPhrase(@Frase, emailPersonal) AS NVARCHAR(100)), -- Desencriptar el emailPersonal
        CAST(DecryptByPassPhrase(@Frase, cuil) AS NVARCHAR(20)), -- Desencriptar cuil
        CAST(DecryptByPassPhrase(@Frase, domicilio) AS NVARCHAR(100)) -- Desencriptar domicilio
    FROM negocio.Empleado;

    -- Transferir los datos desencriptados de la tabla temporal a la tabla original
    UPDATE e
    SET 
        e.emailPersonal = et.emailPersonal,
        e.cuil = et.cuil,
        e.domicilio = et.domicilio
    FROM negocio.Empleado e
    INNER JOIN #EmpleadoTemp et ON e.id = et.id;

    -- Eliminar la tabla temporal después de la transferencia
    DROP TABLE #EmpleadoTemp;

    PRINT 'Datos desencriptados y transferidos a la tabla original.';
END;
GO

EXEC DesencriptarDatos @Frase = 'AuroraSAG18';
*/

UPDATE negocio.Empleado
SET
domicilio = CAST(DecryptByPassPhrase('AuroraSAG18', domicilio) AS VARCHAR(100));

SELECT *
FROM negocio.Empleado

SELECT 
    COLUMN_NAME, 
    DATA_TYPE
FROM 
    INFORMATION_SCHEMA.COLUMNS
WHERE 
    TABLE_SCHEMA = 'negocio'
    AND TABLE_NAME = 'Empleado';



SELECT 
    tc.constraint_name AS ConstraintName,
    tc.constraint_type AS ConstraintType,
    kcu.column_name AS ColumnName
FROM 
    information_schema.table_constraints tc
JOIN 
    information_schema.key_column_usage kcu
    ON tc.constraint_name = kcu.constraint_name
WHERE 
    tc.table_schema = 'negocio'  -- Esquema de la tabla
    AND tc.table_name = 'Empleado'  -- Nombre de la tabla
    AND tc.constraint_type = 'UNIQUE';  -- Verificar las restricciones de unicidad