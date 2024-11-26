USE Com2900G18
GO

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
ALTER COLUMN cuil NVARCHAR(MAX);
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

SELECT * FROM negocio.Empleado;
*/

-- Valido encriptado
/*
EXEC negocio.DesencriptarDatosEmpleado;

SELECT * FROM negocio.Empleado;
*/