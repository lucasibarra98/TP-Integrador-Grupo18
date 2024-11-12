USE Com2900G18
GO

--SCHEMA PRODUCTOS

-- Inserta linea de producto
CREATE OR ALTER PROCEDURE productos.InsertarLineaProducto
    @nombre VARCHAR(40)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM productos.LineaProducto WHERE nombre = @nombre)
    BEGIN
        INSERT INTO productos.LineaProducto (nombre)
        VALUES (@nombre);
    END
    ELSE
    BEGIN
        PRINT 'Error: El nombre de la linea de producto ya existe.';
    END
END;
GO

-- Inserta categoria
CREATE OR ALTER PROCEDURE productos.InsertarCategoria
    @nombre VARCHAR(50),
    @idLineaProd INT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM productos.LineaProducto WHERE id = @idLineaProd)
    BEGIN
        INSERT INTO productos.Categoria (nombre, idLineaProd)
        VALUES (@nombre, @idLineaProd);
    END
    ELSE
    BEGIN
        PRINT 'Error: El id de la linea de producto no existe.';
    END
END;
GO

-- Inserta proveedor
CREATE OR ALTER PROCEDURE productos.InsertarProveedor
    @nombre VARCHAR(50)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM productos.Proveedor WHERE nombre = @nombre)
    BEGIN
        INSERT INTO productos.Proveedor (nombre)
        VALUES (@nombre);
    END
    ELSE
    BEGIN
        PRINT 'Error: El nombre del proveedor ya existe.';
    END
END;
GO

-- Inserta producto
-- Inserta un nuevo producto
CREATE OR ALTER PROCEDURE productos.InsertarProducto
    @nombre VARCHAR(100),
    @precioUnitario DECIMAL(10,2),
    @cantidadPorUnidad VARCHAR(30),
    @idLineaProd INT,
    @idProveedor INT,
    @catalogo CHAR(3)
AS
BEGIN
    -- Verifico idLineaProd
    IF NOT EXISTS (SELECT 1 FROM productos.LineaProducto WHERE id = @idLineaProd)
    BEGIN
        PRINT 'Error: El id de la línea de producto no existe.';
        RETURN;
    END

    -- Verifico idProveedor
    IF NOT EXISTS (SELECT 1 FROM productos.Proveedor WHERE id = @idProveedor)
    BEGIN
        PRINT 'Error: El id del proveedor no existe.';
        RETURN;
    END

    -- Verifico producto
    IF EXISTS (SELECT 1 FROM productos.Producto WHERE nombre = @nombre)
    BEGIN
        PRINT 'Error: El nombre del producto ya existe.';
        RETURN;
    END

    -- Inserto producto
    INSERT INTO productos.Producto (nombre, precioUnitario, cantidadPorUnidad, idLineaProd, idProveedor, catalogo)
    VALUES (@nombre, @precioUnitario, @cantidadPorUnidad, @idLineaProd, @idProveedor, @catalogo);
END;
GO


--SCHEMA NEGOCIO

-- Inserto provincia
CREATE OR ALTER PROCEDURE negocio.InsertarProvincia
    @nombre VARCHAR(50)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM negocio.Provincia WHERE nombre = @nombre)
    BEGIN
        INSERT INTO negocio.Provincia (nombre)
        VALUES (@nombre);
    END
    ELSE
    BEGIN
        PRINT 'Error: El nombre de la provincia ya existe.';
    END
END;
GO

-- Inserto ciudad
CREATE OR ALTER PROCEDURE negocio.InsertarCiudad
    @nombre VARCHAR(50),
    @reemplazaPor VARCHAR(50) = NULL,
    @idProvincia INT
AS
BEGIN
    -- Verifico idProvincia
    IF NOT EXISTS (SELECT 1 FROM negocio.Provincia WHERE id = @idProvincia)
    BEGIN
        PRINT 'Error: El id de la provincia no existe.';
        RETURN;
    END

    -- Verifico nombre ciudad
    IF EXISTS (SELECT 1 FROM negocio.Ciudad WHERE nombre = @nombre)
    BEGIN
        PRINT 'Error: El nombre de la ciudad ya existe.';
        RETURN;
    END

    -- Inserto ciudad
    INSERT INTO negocio.Ciudad (nombre, reemplazaPor, idProvincia)
    VALUES (@nombre, @reemplazaPor, @idProvincia);
END;
GO

-- Inserta domicilio
CREATE OR ALTER PROCEDURE negocio.InsertarDomicilio
    @calle VARCHAR(50),
    @numero INT,
    @idCiudad INT,
    @codigoPostal VARCHAR(8)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM negocio.Ciudad WHERE id = @idCiudad)
    BEGIN
        INSERT INTO negocio.Domicilio (calle, numero, idCiudad, codigoPostal)
        VALUES (@calle, @numero, @idCiudad, @codigoPostal);
    END
    ELSE
    BEGIN
        PRINT 'Error: El id de la ciudad no existe.';
    END
END;
GO

-- Inserta sucursal
CREATE OR ALTER PROCEDURE negocio.InsertarSucursal
    @idDomicilio INT,
    @horario VARCHAR(100),
    @telefono CHAR(9)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM negocio.Domicilio WHERE id = @idDomicilio)
    BEGIN
        INSERT INTO negocio.Sucursal (idDomicilio, horario, telefono)
        VALUES (@idDomicilio, @horario, @telefono);
    END
    ELSE
    BEGIN
        PRINT 'Error: El id del domicilio no existe.';
    END
END;
GO

-- Inserta cargo
CREATE OR ALTER PROCEDURE negocio.InsertarCargo
    @nombre VARCHAR(30)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM negocio.Cargo WHERE nombre = @nombre)
    BEGIN
        INSERT INTO negocio.Cargo (nombre)
        VALUES (@nombre);
    END
    ELSE
    BEGIN
        PRINT 'Error: El nombre del cargo ya existe.';
    END
END;
GO

-- Inserta empleado
CREATE OR ALTER PROCEDURE negocio.InsertarEmpleado
    @nombre VARCHAR(100),
    @apellido VARCHAR(100),
    @dni INT,
    @idDomicilio INT,
    @emailPersonal VARCHAR(100),
    @emailEmpresa VARCHAR(100),
    @cuil BIGINT,
    @idCargo INT,
    @idSucursal INT,
    @turno VARCHAR(20)
AS
BEGIN
    -- Verifico idDomicilio
    IF NOT EXISTS (SELECT 1 FROM negocio.Domicilio WHERE id = @idDomicilio)
    BEGIN
        PRINT 'Error: El id del domicilio no existe.';
        RETURN;
    END

    -- Verifico idCargo
    IF NOT EXISTS (SELECT 1 FROM negocio.Cargo WHERE id = @idCargo)
    BEGIN
        PRINT 'Error: El id del cargo no existe.';
        RETURN;
    END

    -- Verifico idSucursal
    IF NOT EXISTS (SELECT 1 FROM negocio.Sucursal WHERE id = @idSucursal)
    BEGIN
        PRINT 'Error: El id de la sucursal no existe.';
        RETURN;
    END

    -- Realizo la insercion
    INSERT INTO negocio.Empleado (nombre, apellido, dni, idDomicilio, emailPersonal, emailEmpresa, cuil, idCargo, idSucursal, turno)
    VALUES (@nombre, @apellido, @dni, @idDomicilio, @emailPersonal, @emailEmpresa, @cuil, @idCargo, @idSucursal, @turno);
END;
GO


--SCHEMA VENTAS

-- Inserta medio de pago
CREATE OR ALTER PROCEDURE ventas.InsertarMedioPago
    @nombre VARCHAR(50),
    @reemplazaPor VARCHAR(50)
AS
BEGIN
	-- Verifico nombre
    IF NOT EXISTS (SELECT 1 FROM ventas.MedioPago WHERE nombre = @nombre)
    BEGIN
        INSERT INTO ventas.MedioPago (nombre,reemplazaPor)
        VALUES (@nombre,@reemplazaPor);
    END
    ELSE
    BEGIN
        PRINT 'Error: El nombre del medio de pago ya existe.';
    END
END;
GO

-- Inserta tipo de factura
CREATE OR ALTER PROCEDURE ventas.InsertarTipoFactura
    @sigla CHAR(1)
AS
BEGIN
	-- Verifico sigla
    IF NOT EXISTS (SELECT 1 FROM ventas.TipoFactura WHERE sigla = @sigla)
    BEGIN
        INSERT INTO ventas.TipoFactura (sigla)
        VALUES (@sigla);
    END
    ELSE
    BEGIN
        PRINT 'Error: La sigla del tipo de factura ya existe.';
    END
END;
GO

-- Inserta tipo de cliente
CREATE OR ALTER PROCEDURE ventas.InsertarTipoCliente
    @nombre VARCHAR(50)
AS
BEGIN
	-- Verifico nombre
    IF NOT EXISTS (SELECT 1 FROM ventas.TipoCliente WHERE nombre = @nombre)
    BEGIN
        INSERT INTO ventas.TipoCliente (nombre)
        VALUES (@nombre);
    END
    ELSE
    BEGIN
        PRINT 'Error: El nombre del tipo de cliente ya existe.';
    END
END;
GO

-- Inserta factura
CREATE OR ALTER PROCEDURE ventas.InsertarFactura
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
    -- Verifico idTipoFactura
    IF NOT EXISTS (SELECT 1 FROM ventas.TipoFactura WHERE id = @idTipoFactura)
    BEGIN
        PRINT 'Error: El id del tipo de factura no existe.';
        RETURN;
    END

    -- Verifico idTipoCliente
    IF NOT EXISTS (SELECT 1 FROM ventas.TipoCliente WHERE id = @idTipoCliente)
    BEGIN
        PRINT 'Error: El id del tipo de cliente no existe.';
        RETURN;
    END

    -- Verifico idPago
    IF NOT EXISTS (SELECT 1 FROM ventas.Pago WHERE id = @idPago)
    BEGIN
        PRINT 'Error: El id del pago no existe.';
        RETURN;
    END

    -- Verifico idEmpleado
    IF NOT EXISTS (SELECT 1 FROM negocio.Empleado WHERE id = @idEmpleado)
    BEGIN
        PRINT 'Error: El id del empleado no existe.';
        RETURN;
    END

    -- Verifico idSucursal
    IF NOT EXISTS (SELECT 1 FROM negocio.Sucursal WHERE id = @idSucursal)
    BEGIN
        PRINT 'Error: El id de la sucursal no existe.';
        RETURN;
    END

    -- Realizo la insercion
    INSERT INTO ventas.Factura (idTipoFactura, idTipoCliente, genero, fecha, hora, total, idPago, idEmpleado, idSucursal)
    VALUES (@idTipoFactura, @idTipoCliente, @genero, @fecha, @hora, @total, @idPago, @idEmpleado, @idSucursal);
END;
GO


-- Inserta pago
CREATE OR ALTER PROCEDURE ventas.InsertarPago
    @cod VARCHAR(50),
    @montoTotal DECIMAL(10,2),
    @idMedioPago INT
AS
BEGIN
    -- Verifico idMedioPago
    IF NOT EXISTS (SELECT 1 FROM ventas.MedioPago WHERE id = @idMedioPago)
    BEGIN
        PRINT 'Error: El id del medio de pago no existe.';
        RETURN;
    END

    -- Verifico codigo pago no duplicado
    IF EXISTS (SELECT 1 FROM ventas.Pago WHERE cod = @cod)
    BEGIN
        PRINT 'Error: El codigo de pago ya existe.';
        RETURN;
    END

    -- Inserta el registro si todas las condiciones se cumplen
    INSERT INTO ventas.Pago (cod, montoTotal, idMedioPago)
    VALUES (@cod, @montoTotal, @idMedioPago);
END;
GO

-- Inserta detalle de factura
CREATE OR ALTER PROCEDURE ventas.InsertarDetalleFactura
    @idFactura INT,
    @idProducto INT,
    @cantidad INT,
    @precioUnitario DECIMAL(10,2)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM ventas.Factura WHERE id = @idFactura)
    BEGIN
        PRINT 'Error: El id de la factura no existe.';
        RETURN;
    END

    -- Verifico idProducto
    IF NOT EXISTS (SELECT 1 FROM productos.Producto WHERE id = @idProducto)
    BEGIN
        PRINT 'Error: El id del producto no existe.';
        RETURN;
    END

    -- Calculo subtotal
    DECLARE @subtotal DECIMAL(10,2);
    SET @subtotal = @cantidad * @precioUnitario;

    -- Inserto detalle de factura
    INSERT INTO ventas.DetalleFactura (idFactura, idProducto, cantidad, precioUnitario, subtotal)
    VALUES (@idFactura, @idProducto, @cantidad, @precioUnitario, @subtotal);
END
GO

-- Inserta nota de credito
CREATE OR ALTER PROCEDURE ventas.InsertarNotaCredito
    @idFactura INT,
    @fecha DATE,
    @total DECIMAL(10,2),
    @motivo VARCHAR(100)
AS
BEGIN
	--Verifico idFactura
    IF EXISTS (SELECT 1 FROM ventas.Factura WHERE id = @idFactura)
    BEGIN
        INSERT INTO ventas.NotaCredito (idFactura, fecha, total, motivo)
        VALUES (@idFactura, @fecha, @total, @motivo);
    END
    ELSE
    BEGIN
        PRINT 'Error: El id de la factura no existe.';
    END
END;
GO

-- Inserta detalle de nota de credito
CREATE OR ALTER PROCEDURE ventas.InsertarDetalleNotaCredito
    @idNotaCredito INT,
    @idDetalleFactura INT,
    @cantidad INT
AS
BEGIN
    -- Verifico idNotaCredito
    IF NOT EXISTS (SELECT 1 FROM ventas.NotaCredito WHERE id = @idNotaCredito)
    BEGIN
        PRINT 'Error: El id de la nota de crédito no existe.';
        RETURN;
    END

    -- Verifico idDetalleFactura
    IF NOT EXISTS (SELECT 1 FROM ventas.DetalleFactura WHERE id = @idDetalleFactura)
    BEGIN
        PRINT 'Error: El id del detalle de factura no existe.';
        RETURN;
    END

    -- Calculo subtotal
    DECLARE @precioUnitario DECIMAL(10,2);
    DECLARE @subtotal DECIMAL(10,2);

    SELECT @precioUnitario = precioUnitario
    FROM ventas.DetalleFactura
    WHERE id = @idDetalleFactura;

    SET @subtotal = @precioUnitario * @cantidad;

    -- Inserto detalle de nota de crédito
    INSERT INTO ventas.DetalleNotaCredito (idNotaCredito, idDetalleFactura, cantidad, subtotal)
    VALUES (@idNotaCredito, @idDetalleFactura, @cantidad, @subtotal);
END;
GO

