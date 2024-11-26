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

-- Crear clave maestra
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'g18aurora';

-- Crear un certificado
CREATE CERTIFICATE CertificadoEmpleados
WITH SUBJECT = 'Cifrado de datos personales en la tabla de empleados';

-- Crear clave simétrica usando el certificado
CREATE SYMMETRIC KEY ClaveSimetricaEmpleados
WITH ALGORITHM = AES_256
ENCRYPTION BY CERTIFICATE CertificadoEmpleados;
GO

-- Modificar la tabla Empleado para cambiar los tipos de datos a NVARCHAR(MAX)

ALTER TABLE negocio.Empleado
ALTER COLUMN dni NVARCHAR(MAX) NOT NULL;

ALTER TABLE negocio.Empleado
ALTER COLUMN domicilio NVARCHAR(MAX) NOT NULL;

ALTER TABLE negocio.Empleado
ALTER COLUMN emailPersonal NVARCHAR(MAX) NOT NULL;

ALTER TABLE negocio.Empleado
ALTER COLUMN cuil NVARCHAR(MAX) NOT NULL;
GO


--Encriptado
CREATE OR ALTER PROCEDURE negocio.EncriptarDatosEmpleado
AS
BEGIN
    BEGIN TRY
        -- Abrir la clave simétrica
        OPEN SYMMETRIC KEY ClaveSimetricaEmpleados
        DECRYPTION BY CERTIFICATE CertificadoEmpleados;

        -- Encriptar los datos sensibles
        UPDATE negocio.Empleado
        SET 
			dni = EncryptByKey(Key_GUID('ClaveSimetricaEmpleados'), CONVERT(NVARCHAR(MAX), dni)),
            domicilio = EncryptByKey(Key_GUID('ClaveSimetricaEmpleados'), CONVERT(NVARCHAR(MAX), domicilio)),
            emailPersonal = EncryptByKey(Key_GUID('ClaveSimetricaEmpleados'), CONVERT(NVARCHAR(MAX), emailPersonal)),
			cuil = EncryptByKey(Key_GUID('ClaveSimetricaEmpleados'), CONVERT(NVARCHAR(MAX), cuil))

        -- Cerrar la clave simétrica
        CLOSE SYMMETRIC KEY ClaveSimetricaEmpleados;

        PRINT 'Cifrado completado exitosamente.';
    END TRY
    BEGIN CATCH
        PRINT 'Error al cifrar los datos de los empleados.';
    END CATCH
END;
GO

--Desencriptado
CREATE OR ALTER PROCEDURE negocio.DesencriptarDatosEmpleado
AS
BEGIN
    BEGIN TRY
        -- Abrir la clave simétrica
        OPEN SYMMETRIC KEY ClaveSimetricaEmpleados
        DECRYPTION BY CERTIFICATE CertificadoEmpleados;

        -- Actualizar los campos directamente con los valores desencriptados
        UPDATE negocio.Empleado
        SET 
			dni = CONVERT(NVARCHAR(MAX), DecryptByKey(dni)),
            domicilio = CONVERT(NVARCHAR(MAX), DecryptByKey(domicilio)),
            emailPersonal = CONVERT(NVARCHAR(MAX), DecryptByKey(emailPersonal)),
            cuil = CONVERT(NVARCHAR(MAX), DecryptByKey(cuil));

        -- Cerrar la clave simétrica
        CLOSE SYMMETRIC KEY ClaveSimetricaEmpleados;

        PRINT 'Descifrado completado exitosamente.';
    END TRY
    BEGIN CATCH
        -- En caso de error, se captura y se muestra un mensaje
        PRINT 'Error al descifrar los datos de los empleados.';
    END CATCH
END;
GO

--Pruebas
/*
EXEC negocio.EncriptarDatosEmpleado;

SELECT id, dni, nombre, apellido, domicilio, emailPersonal, emailEmpresa FROM negocio.Empleado;
*/

-- Valido encriptado
/*
EXEC negocio.DesencriptarDatosEmpleado;

SELECT id, dni, nombre, apellido, domicilio, emailPersonal, emailEmpresa FROM negocio.Empleado;
*/