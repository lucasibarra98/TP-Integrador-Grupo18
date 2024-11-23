USE Com2900G18
GO

--Insercion de los datos para prueba 

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

-- Hacemos un SP para la encriptacion de los datos

CREATE OR ALTER PROCEDURE EncriptarYConvertirDatos
    @PassPhrase NVARCHAR(100)  -- Frase de contraseña para la encriptación
AS
BEGIN

    UPDATE negocio.Empleado
    SET dni = EncryptByPassPhrase(@PassPhrase, CONVERT(VARBINARY(MAX), dni));

    UPDATE negocio.Empleado
    SET cuil = EncryptByPassPhrase(@PassPhrase, CONVERT(VARBINARY(MAX), cuil));
    
    PRINT 'Datos convertidos y encriptados correctamente.';
END;

EXEC EncriptarYConvertirDatos @PassPhrase = 'AuroraSAG18';

SELECT *
FROM negocio.Empleado

-- Mostramos los datos encriptados

CREATE OR ALTER PROCEDURE DesencriptarDatos
    @PassPhrase NVARCHAR(100)  -- Frase de contraseña para la desencriptación
AS
BEGIN
    -- Desencriptar y convertir los valores a su tipo original
    UPDATE negocio.Empleado
    SET dni = CONVERT(INT, DecryptByPassPhrase(@PassPhrase, dni)),
        cuil = CONVERT(BIGINT, DecryptByPassPhrase(@PassPhrase, cuil));
    
    PRINT 'Datos desencriptados correctamente.';
END;

EXEC DesencriptarDatos @PassPhrase = 'AuroraSAG18';

SELECT *
FROM negocio.Empleado