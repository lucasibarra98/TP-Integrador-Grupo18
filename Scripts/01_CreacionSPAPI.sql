USE Com2900G18
GO

CREATE OR ALTER PROCEDURE obtenerCotizacion @cotizacion DECIMAL(10,2) OUTPUT AS
BEGIN
	EXEC sp_configure 'show advanced options', 1;
	RECONFIGURE;
	EXEC sp_configure 'Ole Automation Procedures', 1;
	RECONFIGURE;

	DECLARE @url NVARCHAR(64) = 'https://dolarapi.com/v1/dolares/oficial';
	DECLARE @object INT;
	DECLARE @json TABLE(respuesta NVARCHAR(MAX))
	DECLARE @respuesta NVARCHAR(MAX)

	EXEC sp_OACreate 'MSXML2.XMLHTTP', @object OUT
	EXEC sp_OAMethod @object, 'OPEN', NULL, 'GET', @url, 'FALSE'
	EXEC sp_OAMethod @object, 'SEND'
	EXEC sp_OAMethod @object, 'RESPONSETEXT', @respuesta OUTPUT

	INSERT @json
		EXEC sp_OAGetProperty @object, 'RESPONSETEXT'

	EXEC sp_configure 'Ole Automation Procedures', 0;
	RECONFIGURE;
	EXEC sp_configure 'show advanced options', 0;
	RECONFIGURE;

	DECLARE @datos NVARCHAR(MAX) = (SELECT respuesta FROM @json);

	SET @cotizacion = (SELECT * FROM OPENJSON(@datos)
	WITH(
		[precioDolar] DECIMAL(10,2) '$.venta'
	));
END

/*
DECLARE @variable DECIMAL(10,2)
EXEC obtenerCotizacion @cotizacion = @variable OUTPUT
*/