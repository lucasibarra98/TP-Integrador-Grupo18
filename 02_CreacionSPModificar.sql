USE Com2900G18
GO

--SCHEMA PRODUCTOS

--Modifico Linea Producto
CREATE OR ALTER PROCEDURE productos.ModificarLineaProducto
    @id INT,
    @nombre VARCHAR(40)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM productos.LineaProducto WHERE id = @id)
    BEGIN
        UPDATE productos.LineaProducto
        SET nombre = @nombre
        WHERE id = @id;
    END
    ELSE
    BEGIN
        PRINT 'Error: El id de la línea de producto no existe.';
    END
END;
GO

--Modifico Categoria
CREATE OR ALTER PROCEDURE productos.ModificarCategoria
    @id INT,
    @nombre VARCHAR(50),
    @idLineaProd INT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM productos.Categoria WHERE id = @id) AND
       EXISTS (SELECT 1 FROM productos.LineaProducto WHERE id = @idLineaProd)
    BEGIN
        UPDATE productos.Categoria
        SET nombre = @nombre, idLineaProd = @idLineaProd
        WHERE id = @id;
    END
    ELSE
    BEGIN
        PRINT 'Error: El id de la categoría o de la linea de producto no existe.';
    END
END;
GO

--Modifico Proveedor
CREATE OR ALTER PROCEDURE productos.ModificarProveedor
    @id INT,
    @nombre VARCHAR(50)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM productos.Proveedor WHERE id = @id)
    BEGIN
        UPDATE productos.Proveedor
        SET nombre = @nombre
        WHERE id = @id;
    END
    ELSE
    BEGIN
        PRINT 'Error: El id del proveedor no existe.';
    END
END;
GO

--Modifico Producto
CREATE OR ALTER PROCEDURE productos.ModificarProducto
    @id INT,
    @nombre VARCHAR(100),
    @precioUnitario DECIMAL(10,2),
    @cantidadPorUnidad VARCHAR(30),
    @idLineaProd INT,
    @idProveedor INT,
    @catalogo CHAR(3)
AS
BEGIN
	--Verifico idProdcut
    IF NOT EXISTS (SELECT 1 FROM productos.Producto WHERE id = @id)
    BEGIN
        PRINT 'Error: El id del producto no existe.';
        RETURN;
    END

	--Verifico idLineaProducto
    IF NOT EXISTS (SELECT 1 FROM productos.LineaProducto WHERE id = @idLineaProd)
    BEGIN
        PRINT 'Error: El id de la línea de producto no existe.';
        RETURN;
    END

	--Verifico idProveedor
    IF NOT EXISTS (SELECT 1 FROM productos.Proveedor WHERE id = @idProveedor)
    BEGIN
        PRINT 'Error: El id del proveedor no existe.';
        RETURN;
    END

    UPDATE productos.Producto
    SET nombre = @nombre,
        precioUnitario = @precioUnitario,
        cantidadPorUnidad = @cantidadPorUnidad,
        idLineaProd = @idLineaProd,
        idProveedor = @idProveedor,
        catalogo = @catalogo
    WHERE id = @id;
END;
GO

--SCHEMA NEGOCIO

--Modifico Provincia
CREATE OR ALTER PROCEDURE negocio.ModificarProvincia
    @id INT,
    @nombre VARCHAR(50)
AS
BEGIN
	--Verifico idProvincia
    IF NOT EXISTS (SELECT 1 FROM negocio.Provincia WHERE id = @id)
    BEGIN
        PRINT 'Error: El id de la provincia no existe.';
        RETURN;
    END

    UPDATE negocio.Provincia
    SET nombre = @nombre
    WHERE id = @id;
END;
GO

--Modifico Ciudad
CREATE OR ALTER PROCEDURE negocio.ModificarCiudad
    @id INT,
    @nombre VARCHAR(50),
    @reemplazaPor VARCHAR(50),
    @idProvincia INT
AS
BEGIN
	--Verifico idCiudad
    IF NOT EXISTS (SELECT 1 FROM negocio.Ciudad WHERE id = @id)
    BEGIN
        PRINT 'Error: El id de la ciudad no existe.';
        RETURN;
    END
	--Verifico idProvincia
    IF NOT EXISTS (SELECT 1 FROM negocio.Provincia WHERE id = @idProvincia)
    BEGIN
        PRINT 'Error: El id de la provincia no existe.';
        RETURN;
    END

    UPDATE negocio.Ciudad
    SET nombre = @nombre,
        reemplazaPor = @reemplazaPor,
        idProvincia = @idProvincia
    WHERE id = @id;
END;
GO

--Modifico Domicilio
CREATE OR ALTER PROCEDURE negocio.ModificarDomicilio
    @id INT,
    @calle VARCHAR(50),
    @numero INT,
    @idCiudad INT,
    @codigoPostal VARCHAR(8)
AS
BEGIN
	--Verifico idDomicilio
    IF NOT EXISTS (SELECT 1 FROM negocio.Domicilio WHERE id = @id)
    BEGIN
        PRINT 'Error: El id del domicilio no existe.';
        RETURN;
    END
	--Verifico idCiudad
    IF NOT EXISTS (SELECT 1 FROM negocio.Ciudad WHERE id = @idCiudad)
    BEGIN
        PRINT 'Error: El id de la ciudad no existe.';
        RETURN;
    END

    UPDATE negocio.Domicilio
    SET calle = @calle,
        numero = @numero,
        idCiudad = @idCiudad,
        codigoPostal = @codigoPostal
    WHERE id = @id;
END;
GO

--Modifico Sucursal 
CREATE OR ALTER PROCEDURE negocio.ModificarSucursal
    @id INT,
    @idDomicilio INT,
    @horario VARCHAR(100),
    @telefono CHAR(9)
AS
BEGIN
	--Verifico idSucursal
    IF NOT EXISTS (SELECT 1 FROM negocio.Sucursal WHERE id = @id)
    BEGIN
        PRINT 'Error: El id de la sucursal no existe.';
        RETURN;
    END
	--Verifico idDomicilio
    IF NOT EXISTS (SELECT 1 FROM negocio.Domicilio WHERE id = @idDomicilio)
    BEGIN
        PRINT 'Error: El id del domicilio no existe.';
        RETURN;
    END

    UPDATE negocio.Sucursal
    SET idDomicilio = @idDomicilio,
        horario = @horario,
        telefono = @telefono
    WHERE id = @id;
END;
GO

--Modifico Cargo 
CREATE OR ALTER PROCEDURE negocio.ModificarCargo
    @id INT,
    @nombre VARCHAR(30)
AS
BEGIN
	--Verifico idCargo
    IF NOT EXISTS (SELECT 1 FROM negocio.Cargo WHERE id = @id)
    BEGIN
        PRINT 'Error: El id del cargo no existe.';
        RETURN;
    END

    UPDATE negocio.Cargo
    SET nombre = @nombre
    WHERE id = @id;
END;
GO

--Modifico Empleado
CREATE OR ALTER PROCEDURE negocio.ModificarEmpleado
    @id INT,
    @nombre VARCHAR(20),
    @apellido VARCHAR(20),
    @dni INT,
    @idDomicilio INT,
    @emailPersonal VARCHAR(50),
    @emailEmpresa VARCHAR(50),
    @cuil BIGINT,
    @idCargo INT,
    @idSucursal INT,
    @turno VARCHAR(20)
AS
BEGIN
	--Verifico idEmpleado
    IF NOT EXISTS (SELECT 1 FROM negocio.Empleado WHERE id = @id)
    BEGIN
        PRINT 'Error: El ID del empleado no existe.';
        RETURN;
    END
	--Verifico idDomicilio
    IF NOT EXISTS (SELECT 1 FROM negocio.Domicilio WHERE id = @idDomicilio)
    BEGIN
        PRINT 'Error: El id del domicilio no existe.';
        RETURN;
    END
	--Verifico idCargo
    IF NOT EXISTS (SELECT 1 FROM negocio.Cargo WHERE id = @idCargo)
    BEGIN
        PRINT 'Error: El id del cargo no existe.';
        RETURN;
    END
	--Verifico idSucursal
    IF NOT EXISTS (SELECT 1 FROM negocio.Sucursal WHERE id = @idSucursal)
    BEGIN
        PRINT 'Error: El id de la sucursal no existe.';
        RETURN;
    END

    UPDATE negocio.Empleado
    SET nombre = @nombre,
        apellido = @apellido,
        dni = @dni,
        idDomicilio = @idDomicilio,
        emailPersonal = @emailPersonal,
        emailEmpresa = @emailEmpresa,
        cuil = @cuil,
        idCargo = @idCargo,
        idSucursal = @idSucursal,
        turno = @turno
    WHERE id = @id;
END;
GO

--SCHEMA VENTAS

--Modifico Medio Pago
CREATE OR ALTER PROCEDURE ventas.ModificarMedioPago
    @id INT,
    @nombre VARCHAR(50)
AS
BEGIN
	--Verifico Medio Pago
    IF NOT EXISTS (SELECT 1 FROM ventas.MedioPago WHERE id = @id)
    BEGIN
        PRINT 'Error: El id del medio de pago no existe.';
        RETURN;
    END

    UPDATE ventas.MedioPago
    SET nombre = @nombre
    WHERE id = @id;
END;
GO

--Modifico Pago
CREATE OR ALTER PROCEDURE ventas.ModificarPago
    @id INT,
    @cod VARCHAR(50),
    @montoTotal DECIMAL(10,2),
    @idMedioPago INT
AS
BEGIN
	--Verifico idPago
    IF NOT EXISTS (SELECT 1 FROM ventas.Pago WHERE id = @id)
    BEGIN
        PRINT 'Error: El id del pago no existe.';
        RETURN;
    END
	--Verifico idMedioPago
    IF NOT EXISTS (SELECT 1 FROM ventas.MedioPago WHERE id = @idMedioPago)
    BEGIN
        PRINT 'Error: El id del medio de pago no existe.';
        RETURN;
    END

    UPDATE ventas.Pago
    SET cod = @cod,
        montoTotal = @montoTotal,
        idMedioPago = @idMedioPago
    WHERE id = @id;
END;
GO

--Modifico Tipo Factura
CREATE OR ALTER PROCEDURE ventas.ModificarTipoFactura
    @id INT,
    @sigla CHAR(1)
AS
BEGIN
	--Verifico idTipoFactura
    IF NOT EXISTS (SELECT 1 FROM ventas.TipoFactura WHERE id = @id)
    BEGIN
        PRINT 'Error: El id del tipo de factura no existe.';
        RETURN;
    END

    UPDATE ventas.TipoFactura
    SET sigla = @sigla
    WHERE id = @id;
END;
GO

--Modifico Tipo Cliente
CREATE OR ALTER PROCEDURE ventas.ModificarTipoCliente
    @id INT,
    @nombre VARCHAR(50)
AS
BEGIN
	--Verifico idTipoCliente
    IF NOT EXISTS (SELECT 1 FROM ventas.TipoCliente WHERE id = @id)
    BEGIN
        PRINT 'Error: El id del tipo de cliente no existe.';
        RETURN;
    END

    UPDATE ventas.TipoCliente
    SET nombre = @nombre
    WHERE id = @id;
END;
GO

--Modifico Factura
CREATE OR ALTER PROCEDURE ventas.ModificarFactura
    @id INT,
    @idTipoFactura INT,
    @idTipoCliente INT,
    @genero VARCHAR(10),
    @fecha DATE,
    @hora TIME,
    @total DECIMAL(10,2),
    @idPago INT,
    @idEmpleado INT,
    @idSucursal INT
AS
BEGIN
	--Verifico idFactura
    IF NOT EXISTS (SELECT 1 FROM ventas.Factura WHERE id = @id)
    BEGIN
        PRINT 'Error: El id de la factura no existe.';
        RETURN;
    END
	--Verifico idTipoFactura
    IF NOT EXISTS (SELECT 1 FROM ventas.TipoFactura WHERE id = @idTipoFactura)
    BEGIN
        PRINT 'Error: El id del tipo de factura no existe.';
        RETURN;
    END
	--Verifico idTipoCliente
    IF NOT EXISTS (SELECT 1 FROM ventas.TipoCliente WHERE id = @idTipoCliente)
    BEGIN
        PRINT 'Error: El id del tipo de cliente no existe.';
        RETURN;
    END
	--Verifico idPago
    IF NOT EXISTS (SELECT 1 FROM ventas.Pago WHERE id = @idPago)
    BEGIN
        PRINT 'Error: El id del pago no existe.';
        RETURN;
    END
	--Verifico idEmpleado
    IF NOT EXISTS (SELECT 1 FROM negocio.Empleado WHERE id = @idEmpleado)
    BEGIN
        PRINT 'Error: El id del empleado no existe.';
        RETURN;
    END
	--Verifico idSucursal
    IF NOT EXISTS (SELECT 1 FROM negocio.Sucursal WHERE id = @idSucursal)
    BEGIN
        PRINT 'Error: El id de la sucursal no existe.';
        RETURN;
    END

    UPDATE ventas.Factura
    SET idTipoFactura = @idTipoFactura,
        idTipoCliente = @idTipoCliente,
        genero = @genero,
        fecha = @fecha,
        hora = @hora,
        total = @total,
        idPago = @idPago,
        idEmpleado = @idEmpleado,
        idSucursal = @idSucursal
    WHERE id = @id;
END;
GO

--Modifico Detalle Factura
CREATE OR ALTER PROCEDURE ventas.ModificarDetalleFactura
    @id INT,
    @idFactura INT,
    @idProducto INT,
    @cantidad INT,
    @precioUnitario DECIMAL(10,2)
AS
BEGIN
	--Verifico idDetalleFactura
    IF NOT EXISTS (SELECT 1 FROM ventas.DetalleFactura WHERE id = @id)
    BEGIN
        PRINT 'Error: El id del detalle de factura no existe.';
        RETURN;
    END
	--Verifico idFactura
    IF NOT EXISTS (SELECT 1 FROM ventas.Factura WHERE id = @idFactura)
    BEGIN
        PRINT 'Error: El id de la factura no existe.';
        RETURN;
    END
	--Verifico idProducto
    IF NOT EXISTS (SELECT 1 FROM productos.Producto WHERE id = @idProducto)
    BEGIN
        PRINT 'Error: El id del producto no existe.';
        RETURN;
    END

	--Obtengo subtotal
    DECLARE @subtotal DECIMAL(10,2);
    SET @subtotal = @cantidad * @precioUnitario;

    UPDATE ventas.DetalleFactura
    SET idFactura = @idFactura,
        idProducto = @idProducto,
        cantidad = @cantidad,
        precioUnitario = @precioUnitario,
        subtotal = @subtotal
    WHERE id = @id;
END;
GO

--Modifico Nota Credito
CREATE OR ALTER PROCEDURE ventas.ModificarNotaCredito
    @id INT,
    @idFactura INT,
    @fecha DATE,
    @total DECIMAL(10,2),
    @motivo VARCHAR(100)
AS
BEGIN
	--Verifico idNotaCredito
    IF NOT EXISTS (SELECT 1 FROM ventas.NotaCredito WHERE id = @id)
    BEGIN
        PRINT 'Error: El id de la nota de credito no existe.';
        RETURN;
    END
	--Verifico idFactura
    IF NOT EXISTS (SELECT 1 FROM ventas.Factura WHERE id = @idFactura)
    BEGIN
        PRINT 'Error: El id de la factura no existe.';
        RETURN;
    END

    UPDATE ventas.NotaCredito
    SET idFactura = @idFactura,
        fecha = @fecha,
        total = @total,
        motivo = @motivo
    WHERE id = @id;
END;
GO


--Modifico Detalle Nota Credito
CREATE OR ALTER PROCEDURE ventas.ModificarDetalleNotaCredito
    @id INT,
    @idNotaCredito INT,
    @idDetalleFactura INT,
    @cantidad INT
AS
BEGIN
	--Verifo idDetalleNotaCredito
    IF NOT EXISTS (SELECT 1 FROM ventas.DetalleNotaCredito WHERE id = @id)
    BEGIN
        PRINT 'Error: El id del detalle de la nota de credito no existe.';
        RETURN;
    END
	--Verifico idNotaCredito
    IF NOT EXISTS (SELECT 1 FROM ventas.NotaCredito WHERE id = @idNotaCredito)
    BEGIN
        PRINT 'Error: El id de la nota de credito no existe.';
        RETURN;
    END
	--Verifico idDetalleFactura
    IF NOT EXISTS (SELECT 1 FROM ventas.DetalleFactura WHERE id = @idDetalleFactura)
    BEGIN
        PRINT 'Error: El id del detalle de la factura no existe.';
        RETURN;
    END

    DECLARE @subtotal DECIMAL(10,2);
    DECLARE @precioUnitario DECIMAL(10,2);
	
	--Obtengo precio unitario
    SELECT @precioUnitario = precioUnitario
    FROM ventas.DetalleFactura
    WHERE id = @idDetalleFactura;

    -- Calculo subtotal
    SET @subtotal = @precioUnitario * @cantidad;

    UPDATE ventas.DetalleNotaCredito
    SET idNotaCredito = @idNotaCredito,
        idDetalleFactura = @idDetalleFactura,
        cantidad = @cantidad,
        subtotal = @subtotal
    WHERE id = @id;
END;
GO

