USE Com2900G18
GO

------SCHEMA PRODUCTOS------

--Linea Producto

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
        PRINT 'Error: La linea de producto no existe.';
    END
END;
GO

--Categoria

CREATE OR ALTER PROCEDURE productos.ModificarCategoria
    @id INT,
    @nombre VARCHAR(50),
    @idLineaProd INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM productos.Categoria WHERE id = @id)
    BEGIN
        PRINT 'Error: La categoria no existe.';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM productos.LineaProducto WHERE id = @idLineaProd)
    BEGIN
        PRINT 'Error: La linea de producto no existe.';
        RETURN;
    END

    UPDATE productos.Categoria
    SET nombre = @nombre,
        idLineaProd = @idLineaProd
    WHERE id = @id;
END;
GO

--Proveedor

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
        PRINT 'Error: El proveedor no existe.';
    END
END;
GO

--Producto

CREATE OR ALTER PROCEDURE productos.ModificarProducto
    @id INT,
    @nombre VARCHAR(100),
    @idLineaProd INT,
    @idProveedor INT,
    @precioUnitario DECIMAL(10,2),
    @cantidadPorUnidad VARCHAR(30)
AS
BEGIN
--Validamos existencia de producto
    IF NOT EXISTS (SELECT 1 FROM productos.Producto WHERE id = @id)
    BEGIN
        PRINT 'Error: El producto no existe.';
        RETURN;
    END
--Validamos existencia de linea de producto
    IF NOT EXISTS (SELECT 1 FROM productos.LineaProducto WHERE id = @idLineaProd)
    BEGIN
        PRINT 'Error: La linea de producto no existe.';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM productos.Proveedor WHERE id = @idProveedor)
    BEGIN
        PRINT 'Error:El proveedor no existe.';
        RETURN;
    END

    UPDATE productos.Producto
    SET nombre = @nombre,
        idLineaProd = @idLineaProd,
        idProveedor = @idProveedor,
        precioUnitario = @precioUnitario,
        cantidadPorUnidad = @cantidadPorUnidad
    WHERE id = @id;
END;
GO

------SCHEMA NEGOCIO------

--Sucursal

CREATE OR ALTER PROCEDURE negocio.ModificarSucursal
    @id INT,
    @nombre VARCHAR(50),
    @direccion VARCHAR(100),
    @horario VARCHAR(100),
    @telefono CHAR(9),
    @ciudad VARCHAR(50)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM negocio.Sucursal WHERE id = @id)
    BEGIN
        UPDATE negocio.Sucursal
        SET nombre = @nombre,
            direccion = @direccion,
            horario = @horario,
            telefono = @telefono,
            ciudad = @ciudad
        WHERE id = @id;
    END
    ELSE
    BEGIN
        PRINT 'Error: La sucursal no existe.';
    END
END;
GO

--Cargo

CREATE OR ALTER PROCEDURE negocio.ModificarCargo
    @id INT,
    @nombre VARCHAR(30)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM negocio.Cargo WHERE id = @id)
    BEGIN
        UPDATE negocio.Cargo
        SET nombre = @nombre
        WHERE id = @id;
    END
    ELSE
    BEGIN
        PRINT 'Error: El cargo no existe.';
    END
END;
GO

--Empleado

CREATE OR ALTER PROCEDURE negocio.ModificarEmpleado
    @id INT,
    @nombre VARCHAR(100),
    @apellido VARCHAR(100),
    @dni INT,
    @domicilio VARCHAR(100),
    @emailPersonal VARCHAR(100),
    @emailEmpresa VARCHAR(100),
    @cuil BIGINT,
    @idCargo INT,
    @idSucursal INT,
    @turno VARCHAR(20)
AS
BEGIN
--Validamos la existencia del empleado
    IF NOT EXISTS (SELECT 1 FROM negocio.Empleado WHERE id = @id)
    BEGIN
        PRINT 'Error: El empleado no existe.';
        RETURN;
    END
--Validamos la existencia del cargo
    IF NOT EXISTS (SELECT 1 FROM negocio.Cargo WHERE id = @idCargo)
    BEGIN
        PRINT 'Error: El cargo no existe.';
        RETURN;
    END
--Validamos la existencia de la sucursal
    IF NOT EXISTS (SELECT 1 FROM negocio.Sucursal WHERE id = @idSucursal)
    BEGIN
        PRINT 'Error: La sucursal no existe.';
        RETURN;
    END

    UPDATE negocio.Empleado
    SET nombre = @nombre,
        apellido = @apellido,
        dni = @dni,
        domicilio = @domicilio,
        emailPersonal = @emailPersonal,
        emailEmpresa = @emailEmpresa,
        cuil = @cuil,
        idCargo = @idCargo,
        idSucursal = @idSucursal,
        turno = @turno
    WHERE id = @id;
END;
GO

------SCHEMA VENTAS------

--Medio Pago

CREATE OR ALTER PROCEDURE ventas.ModificarMedioPago
    @id INT,
    @nombre VARCHAR(50),
    @reemplazaPor VARCHAR(50)
AS
BEGIN
--Validamos que el medio de pago exista
    IF NOT EXISTS (SELECT 1 FROM ventas.MedioPago WHERE id = @id)
    BEGIN
        PRINT 'Error: El medio de pago no existe.';
        RETURN;
    END

    UPDATE ventas.MedioPago
    SET nombre = @nombre,
        reemplazaPor = @reemplazaPor
    WHERE id = @id;
END;
GO

--Pago

CREATE OR ALTER PROCEDURE ventas.ModificarPago
    @id INT,
    @cod VARCHAR(50),
    @montoTotal DECIMAL(10,2),
    @idMedioPago INT
AS
BEGIN
--Validamos que el pago exista
    IF NOT EXISTS (SELECT 1 FROM ventas.Pago WHERE id = @id)
    BEGIN
        PRINT 'Error: El ID del pago no existe.';
        RETURN;
    END

--Validamos que el medio de pago exista
    IF NOT EXISTS (SELECT 1 FROM ventas.MedioPago WHERE id = @idMedioPago)
    BEGIN
        PRINT 'Error: El medio de pago no existe.';
        RETURN;
    END

    UPDATE ventas.Pago
    SET cod = @cod,
        montoTotal = @montoTotal,
        idMedioPago = @idMedioPago
    WHERE id = @id;
END;
GO

--Tipo Factura

CREATE OR ALTER PROCEDURE ventas.ModificarTipoFactura
    @id INT,
    @sigla CHAR(1)
AS
BEGIN
--Validamos que el tipo de factura exista
    IF NOT EXISTS (SELECT 1 FROM ventas.TipoFactura WHERE id = @id)
    BEGIN
        PRINT 'Error: El tipo de factura no existe.';
        RETURN;
    END

    UPDATE ventas.TipoFactura
    SET sigla = @sigla
    WHERE id = @id;
END;
GO

--Cliente

CREATE OR ALTER PROCEDURE ventas.ModificarCliente
    @id INT,
    @nombre VARCHAR(50),
    @apellido VARCHAR(50),
    @dni INT,
    @genero VARCHAR(20),
    @tipoCliente VARCHAR(20)
AS
BEGIN
--Validamos que el cliente exista
    IF NOT EXISTS (SELECT 1 FROM ventas.Cliente WHERE id = @id)
    BEGIN
        PRINT 'Error: El cliente no existe.';
        RETURN;
    END

    UPDATE ventas.Cliente
    SET nombre = @nombre,
        apellido = @apellido,
        dni = @dni,
        genero = @genero,
        tipoCliente = @tipoCliente
    WHERE id = @id;
END;
GO

--Venta

CREATE OR ALTER PROCEDURE ventas.ModificarVenta
    @id INT,
    @idCliente INT,
    @idEmpleado INT,
    @idSucursal INT,
    @fecha DATE,
    @hora TIME,
    @totalSinIVA DECIMAL(10,2)
AS
BEGIN
--Validamos que la venta exista
    IF NOT EXISTS (SELECT 1 FROM ventas.Venta WHERE id = @id)
    BEGIN
        PRINT 'Error: La venta no existe.';
        RETURN;
    END
--Validamos que el cliente exista
    IF NOT EXISTS (SELECT 1 FROM ventas.Cliente WHERE id = @idCliente)
    BEGIN
        PRINT 'Error: El cliente no existe.';
        RETURN;
    END
--Validamos que el empleado exista
    IF NOT EXISTS (SELECT 1 FROM negocio.Empleado WHERE id = @idEmpleado)
    BEGIN
        PRINT 'Error: El empleado no existe.';
        RETURN;
    END
--Validamos que la sucursal exista
    IF NOT EXISTS (SELECT 1 FROM negocio.Sucursal WHERE id = @idSucursal)
    BEGIN
        PRINT 'Error: La sucursal no existe.';
        RETURN;
    END

    UPDATE ventas.Venta
    SET idCliente = @idCliente,
        idEmpleado = @idEmpleado,
        idSucursal = @idSucursal,
        fecha = @fecha,
        hora = @hora,
        totalSinIVA = @totalSinIVA
    WHERE id = @id;
END;
GO

--Detalle Venta

CREATE OR ALTER PROCEDURE ventas.ModificarDetalleVenta
    @id INT,
    @idVenta INT,
    @idProducto INT,
    @cantidad INT
AS
BEGIN
--Validamos que el detalle de venta exista
    IF NOT EXISTS (SELECT 1 FROM ventas.DetalleVenta WHERE id = @id)
    BEGIN
        PRINT 'Error: El detalle de venta no existe.';
        RETURN;
    END

--Validamos que la venta exista
    IF NOT EXISTS (SELECT 1 FROM ventas.Venta WHERE id = @idVenta)
    BEGIN
        PRINT 'Error: La venta no existe.';
        RETURN;
    END

--Validamos que el producto exista
    IF NOT EXISTS (SELECT 1 FROM productos.Producto WHERE id = @idProducto)
    BEGIN
        PRINT 'Error: El producto no existe.';
        RETURN;
    END

--Obtenemos el precio unitario del producto
    DECLARE @precioUnitario DECIMAL(10,2);
    SELECT @precioUnitario = precioUnitario
    FROM productos.Producto
    WHERE id = @idProducto;

--Calculamos el subtotal
    DECLARE @subtotal DECIMAL(10,2);
    SET @subtotal = @cantidad * @precioUnitario;

    UPDATE ventas.DetalleVenta
    SET idVenta = @idVenta,
        idProducto = @idProducto,
        cantidad = @cantidad,
        subtotal = @subtotal
    WHERE id = @id;
END;
GO

--Factura 

CREATE OR ALTER PROCEDURE ventas.ModificarFactura
    @id INT,
    @idTipoFactura INT,
    @idVenta INT,
    @CUIT VARCHAR(10),
    @fecha DATE,
    @hora TIME,
    @total DECIMAL(10,2),
    @IVA DECIMAL(3,2),
    @idPago INT,
    @estado VARCHAR(20)
AS
BEGIN
--Validamos que la factura exista
    IF NOT EXISTS (SELECT 1 FROM ventas.Factura WHERE id = @id)
    BEGIN
        PRINT 'Error: La factura no existe.';
        RETURN;
    END

--Validamos que el tipo de factura exista
    IF NOT EXISTS (SELECT 1 FROM ventas.TipoFactura WHERE id = @idTipoFactura)
    BEGIN
        PRINT 'Error: El tipo de factura no existe.';
        RETURN;
    END

--Validamos que la venta exista
    IF NOT EXISTS (SELECT 1 FROM ventas.Venta WHERE id = @idVenta)
    BEGIN
        PRINT 'Error: La venta no existe.';
        RETURN;
    END

--Validar que el pago exista
    IF NOT EXISTS (SELECT 1 FROM ventas.Pago WHERE id = @idPago)
    BEGIN
        PRINT 'Error: El pago no existe.';
        RETURN;
    END

    UPDATE ventas.Factura
    SET idTipoFactura = @idTipoFactura,
        idVenta = @idVenta,
        CUIT = @CUIT,
        fecha = @fecha,
        hora = @hora,
        total = @total,
        IVA = @IVA,
        totalConIVA = @total * (1 + @IVA),
        idPago = @idPago,
        estado = @estado
    WHERE id = @id;
END;
GO

--Nota Credito

CREATE OR ALTER PROCEDURE ventas.ModificarNotaCredito
    @id INT,
    @idFactura INT,
    @fecha DATE,
    @total DECIMAL(10,2),
    @motivo VARCHAR(100)
AS
BEGIN
--Validamos que la nota de credito exista
    IF NOT EXISTS (SELECT 1 FROM ventas.NotaCredito WHERE id = @id)
    BEGIN
        PRINT 'Error: La nota de credito no existe.';
        RETURN;
    END

--Validamos que la factura exista
    IF NOT EXISTS (SELECT 1 FROM ventas.Factura WHERE id = @idFactura)
    BEGIN
        PRINT 'Error: La factura no existe.';
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

--Detalle Nota Credito

CREATE OR ALTER PROCEDURE ventas.ModificarDetalleNotaCredito
    @id INT,
    @idNotaCredito INT,
    @cantidad INT
AS
BEGIN
--Validamos que el detalle de la nota de credito exista
    IF NOT EXISTS (SELECT 1 FROM ventas.DetalleNotaCredito WHERE id = @id)
    BEGIN
        PRINT 'Error: El detalle de la nota de credito no existe.';
        RETURN;
    END

--Validamos que la nota de credito exista
    IF NOT EXISTS (SELECT 1 FROM ventas.NotaCredito WHERE id = @idNotaCredito)
    BEGIN
        PRINT 'Error: La nota de credito no existe.';
        RETURN;
    END

--Calculamos el subtotal
    DECLARE @subtotal DECIMAL(10,2);
    SELECT @subtotal = cantidad * subtotal / cantidad
    FROM ventas.DetalleNotaCredito
    WHERE id = @id;

    UPDATE ventas.DetalleNotaCredito
    SET idNotaCredito = @idNotaCredito,
        cantidad = @cantidad,
        subtotal = @subtotal
    WHERE id = @id;
END;
GO


