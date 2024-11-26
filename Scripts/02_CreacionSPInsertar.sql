USE Com2900G18
GO

------SCHEMA PRODUCTOS------

--Linea Producto

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
        PRINT 'Error: La linea de producto ya existe.';
    END
END;
GO


--Categoria 

CREATE OR ALTER PROCEDURE productos.InsertarCategoria
    @nombre VARCHAR(50),
    @idLineaProd INT
AS
BEGIN
--Validamos que exista la linea de producto asociada 
    IF NOT EXISTS (SELECT 1 FROM productos.LineaProducto WHERE id = @idLineaProd)
    BEGIN
        PRINT 'Error: La linea de producto asociada no existe.';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM productos.Categoria WHERE nombre = @nombre)
    BEGIN
        INSERT INTO productos.Categoria (nombre, idLineaProd)
        VALUES (@nombre, @idLineaProd);
    END
    ELSE
    BEGIN
        PRINT 'Error: La categoria ya existe.';
    END
END;
GO

--Proveedor

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
        PRINT 'Error: El proveedor ya existe.';
    END
END;
GO

--Producto

CREATE OR ALTER PROCEDURE productos.InsertarProducto
    @nombre VARCHAR(100),
    @idLineaProd INT,
    @idProveedor INT = NULL,
    @precioUnitario DECIMAL(10,2),
    @cantidadPorUnidad VARCHAR(30) = NULL,
    @catalogo CHAR(3)
AS
BEGIN
--Validamos que este correcta la linea de producto asociada
    IF NOT EXISTS (SELECT 1 FROM productos.LineaProducto WHERE id = @idLineaProd)
    BEGIN
        PRINT 'Error: La linea de producto asociada no existe.';
        RETURN;
    END
--Validamos que el proveedor este en la tabla de proveedores
    IF @idProveedor IS NOT NULL AND NOT EXISTS (SELECT 1 FROM productos.Proveedor WHERE id = @idProveedor)
    BEGIN
        PRINT 'Error: El proveedor asociado no existe.';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM productos.Producto WHERE nombre = @nombre)
    BEGIN
        INSERT INTO productos.Producto (nombre, idLineaProd, idProveedor, precioUnitario, cantidadPorUnidad, catalogo)
        VALUES (@nombre, @idLineaProd, @idProveedor, @precioUnitario, @cantidadPorUnidad, @catalogo);
    END
    ELSE
    BEGIN
        PRINT 'Error: El producto ya existe.';
    END
END;
GO

------SCHEMA NEGOCIO------

--Sucursal

CREATE OR ALTER PROCEDURE negocio.InsertarSucursal
    @nombre VARCHAR(50),
    @direccion VARCHAR(100),
    @horario VARCHAR(100),
    @telefono CHAR(9),
    @ciudad VARCHAR(50)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM negocio.Sucursal WHERE direccion = @direccion)
    BEGIN
        INSERT INTO negocio.Sucursal (nombre, direccion, horario, telefono, ciudad)
        VALUES (@nombre, @direccion, @horario, @telefono, @ciudad);
    END
    ELSE
    BEGIN
        PRINT 'Error: La sucursal con esta direccion ya existe.';
    END
END;
GO

--Cargo

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
        PRINT 'Error: El cargo ya existe.';
    END
END;
GO

--Empleado 

CREATE OR ALTER PROCEDURE negocio.InsertarEmpleado
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
--Validamos la existencia del cargo dentro de los registros
    IF NOT EXISTS (SELECT 1 FROM negocio.Cargo WHERE id = @idCargo)
    BEGIN
        PRINT 'Error: El cargo asociado no existe.';
        RETURN;
    END
--Validamos la existencia de la sucursal dentro de los registros
    IF NOT EXISTS (SELECT 1 FROM negocio.Sucursal WHERE id = @idSucursal)
    BEGIN
        PRINT 'Error: La sucursal asociada no existe.';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM negocio.Empleado WHERE dni = @dni)
    BEGIN
        INSERT INTO negocio.Empleado (nombre, apellido, dni, domicilio, emailPersonal, emailEmpresa, cuil, idCargo, idSucursal, turno)
        VALUES (@nombre, @apellido, @dni, @domicilio, @emailPersonal, @emailEmpresa, @cuil, @idCargo, @idSucursal, @turno);
    END
    ELSE
    BEGIN
        PRINT 'Error: El empleado ya existe.';
    END
END;
GO

------SCHEMA VENTAS------

--Medio de pago

CREATE OR ALTER PROCEDURE ventas.InsertarMedioPago
    @nombre VARCHAR(50),
    @reemplazaPor VARCHAR(50) = NULL
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM ventas.MedioPago WHERE nombre = @nombre)
    BEGIN
        INSERT INTO ventas.MedioPago (nombre, reemplazaPor)
        VALUES (@nombre, @reemplazaPor);
    END
    ELSE
    BEGIN
        PRINT 'Error: El medio de pago ya existe.';
    END
END;
GO

--Pago

CREATE OR ALTER PROCEDURE ventas.InsertarPago
    @idFactura INT,
    @idMedioPago INT,
    @cod VARCHAR(50)
AS
BEGIN
    BEGIN TRY
      
        DECLARE @totalConIVA DECIMAL(10,2);

--Validamos la existencia de la factura
        IF NOT EXISTS (SELECT 1 FROM ventas.Factura WHERE id = @idFactura)
        BEGIN
            PRINT 'Error: La factura no existe.';
            RETURN;
        END

--Validamos la existencia del medio de pago
        IF NOT EXISTS (SELECT 1 FROM ventas.MedioPago WHERE id = @idMedioPago)
        BEGIN
            PRINT 'Error: El medio de pago no existe.';
            RETURN;
        END

--Obtenemos el total con IVA de la factura
        SELECT @totalConIVA = totalConIVA FROM ventas.Factura WHERE id = @idFactura;

--Insertamos el pago con el monto total derivado del totalConIVA
        INSERT INTO ventas.Pago (cod, montoTotal, idMedioPago)
        VALUES (@cod, @totalConIVA, @idMedioPago);

--Obtenemos el ID del pago recién creado
        DECLARE @idPago INT = SCOPE_IDENTITY();

--Actualizar el estado de la factura a "Pagada"
        UPDATE ventas.Factura
        SET idPago = @idPago, estado = 'Pagada'
        WHERE id = @idFactura;
    END TRY
    BEGIN CATCH
        PRINT 'Error al realizar el pago: ' + ERROR_MESSAGE();
    END CATCH
END;
GO



--Tipo Factura

CREATE OR ALTER PROCEDURE ventas.InsertarTipoFactura
    @sigla CHAR(1)
AS
BEGIN
--Validamos unique en sigla de tipo factura
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

--Cliente

CREATE OR ALTER PROCEDURE ventas.InsertarCliente
    @nombre VARCHAR(50),
    @apellido VARCHAR(50),
    @dni INT,
    @genero VARCHAR(20),
    @tipoCliente VARCHAR(20)
AS
BEGIN
--Validamos DNI unique
    IF NOT EXISTS (SELECT 1 FROM ventas.Cliente WHERE dni = @dni)
    BEGIN
        INSERT INTO ventas.Cliente (nombre, apellido, dni, genero, tipoCliente)
        VALUES (@nombre, @apellido, @dni, @genero, @tipoCliente);
    END
    ELSE
    BEGIN
        PRINT 'Error: El cliente con este DNI ya existe.';
    END
END;
GO

--Venta

CREATE OR ALTER PROCEDURE ventas.InsertarVenta
    @idCliente INT,
    @idEmpleado INT,
    @idSucursal INT,
	@fecha DATE = NULL,
	@hora TIME = NULL
AS
BEGIN
	IF @fecha IS NULL
		SET @fecha = CAST(GETDATE() AS DATE)

	IF @hora IS NULL
		SET @hora = CAST(GETDATE() AS TIME)

    BEGIN TRY
--Verificamos que el cliente existe
        IF NOT EXISTS (SELECT 1 FROM ventas.Cliente WHERE id = @idCliente)
        BEGIN
            PRINT 'Error: El cliente no existe.';
            RETURN;
        END

--Verificamos que el empleado existe
        IF NOT EXISTS (SELECT 1 FROM negocio.Empleado WHERE id = @idEmpleado)
        BEGIN
            PRINT 'Error: El empleado no existe.';
            RETURN;
        END

--Verificamos que la sucursal existe
        IF NOT EXISTS (SELECT 1 FROM negocio.Sucursal WHERE id = @idSucursal)
        BEGIN
            PRINT 'Error: La sucursal no existe.';
            RETURN;
        END

        INSERT INTO ventas.Venta (idCliente, idEmpleado, idSucursal, fecha, hora, totalSinIVA)
        VALUES (@idCliente, @idEmpleado, @idSucursal, @fecha, @hora, 0);

    END TRY
    BEGIN CATCH
        PRINT 'Error al insertar la venta.';
    END CATCH
END;
GO

--Actualizar total de la venta luego de insertar todos los detalles 

CREATE OR ALTER PROCEDURE ventas.ActualizarTotalVenta
    @idVenta INT
AS
BEGIN
    BEGIN TRY
        DECLARE @totalSinIVA DECIMAL(10,2);

--Verificamos que la venta existe
        IF NOT EXISTS (SELECT 1 FROM ventas.Venta WHERE id = @idVenta)
        BEGIN
            PRINT 'Error: La venta no existe.';
            RETURN;
        END

--Calculamos el totalSinIVA como la suma de los subtotales de los detalles de venta asociados
        SELECT @totalSinIVA = SUM(subtotal)
        FROM ventas.DetalleVenta
        WHERE idVenta = @idVenta;

--Actualizamos el totalSinIVA en la tabla ventas.Venta
        UPDATE ventas.Venta
        SET totalSinIVA = @totalSinIVA
        WHERE id = @idVenta;

    END TRY
    BEGIN CATCH
        PRINT 'Ocurrió un error al actualizar el total de la venta.';
    END CATCH
END;
GO


--Detalle Venta

CREATE OR ALTER PROCEDURE ventas.InsertarDetalleVenta
    @idVenta INT,
    @idProducto INT,
    @cantidad INT
AS
BEGIN
    BEGIN TRY
        DECLARE @precioUnitario DECIMAL(10,2);
        DECLARE @subtotal DECIMAL(10,2);
        DECLARE @cotizacionDolar DECIMAL(10,2) = 1; -- Por defecto, 1 si no es importado
        DECLARE @catalogo CHAR(3);

--Verificamos que el producto exista
        IF NOT EXISTS (SELECT 1 FROM productos.Producto WHERE id = @idProducto)
        BEGIN
            PRINT 'Error: El producto no existe.';
            RETURN;
        END

--Verificamos que la venta exista
        IF NOT EXISTS (SELECT 1 FROM ventas.Venta WHERE id = @idVenta)
        BEGIN
            PRINT 'Error: La venta no existe.';
            RETURN;
        END

--Obtenemos precio unitario y catalogo del producto
        SELECT @precioUnitario = precioUnitario,
               @catalogo = catalogo
        FROM productos.Producto
        WHERE id = @idProducto;

--Obtenemos cotización si el producto es importado
        IF @catalogo = 'IMP'
        BEGIN
            EXEC obtenerCotizacion @cotizacionDolar OUTPUT;
        END

--Calculamos subtotal
        SET @subtotal = @precioUnitario * @cotizacionDolar * @cantidad;

        INSERT INTO ventas.DetalleVenta (idVenta, idProducto, cantidad, precioUnitario ,subtotal)
        VALUES (@idVenta, @idProducto, @cantidad, @precioUnitario, @subtotal);

    END TRY
    BEGIN CATCH
        PRINT 'Error al insertar el detalle de venta: ' + ERROR_MESSAGE();
    END CATCH
END;
GO




--Factura

CREATE OR ALTER PROCEDURE ventas.InsertarFactura
    @idTipoFactura INT,
    @idVenta INT,
    @CUIT BIGINT,
    @IVA DECIMAL(3,2),
    @idPago INT = NULL
AS
BEGIN
    BEGIN TRY
        DECLARE @totalSinIVA DECIMAL(10,2);
        DECLARE @totalConIVA DECIMAL(10,2);

--Verificamos que la venta existe
        IF NOT EXISTS (SELECT 1 FROM ventas.Venta WHERE id = @idVenta)
        BEGIN
            PRINT 'Error: La venta no existe.';
            RETURN;
        END

--Obtenemos el totalSinIVA de la venta
        SELECT @totalSinIVA = totalSinIVA FROM ventas.Venta WHERE id = @idVenta;

--Calculamos el total con IVA
        SET @totalConIVA = @totalSinIVA * (1 + @IVA);

        -- Insertar la factura
        INSERT INTO ventas.Factura (idTipoFactura, idVenta, CUIT, total, IVA, totalConIVA, idPago, estado)
        VALUES (@idTipoFactura, @idVenta, @CUIT, @totalSinIVA, @IVA, @totalConIVA, @idPago,
                CASE WHEN @idPago IS NOT NULL THEN 'Pagada' ELSE 'Pendiente' END);
    END TRY
    BEGIN CATCH
        PRINT 'Error al insertar la factura. ' + ERROR_MESSAGE();;
    END CATCH
END;
GO





--Nota Credito

CREATE OR ALTER PROCEDURE ventas.InsertarNotaCredito
    @idFactura INT,
    @fecha DATE,
    @total DECIMAL(10,2),
    @motivo VARCHAR(100)
AS
BEGIN
 --Validamos que la factura exista
    IF NOT EXISTS (SELECT 1 FROM ventas.Factura WHERE id = @idFactura)
    BEGIN
        PRINT 'Error: La factura no existe.';
        RETURN;
    END

    INSERT INTO ventas.NotaCredito (idFactura, fecha, total, motivo)
    VALUES (@idFactura, @fecha, @total, @motivo);
END;
GO

--Detalle Nota Credito

CREATE OR ALTER PROCEDURE ventas.InsertarDetalleNotaCredito
    @idNotaCredito INT,
    @cantidad INT,
    @subtotal DECIMAL(10,2)
AS
BEGIN
--Validamos que la nota de credito exista
    IF NOT EXISTS (SELECT 1 FROM ventas.NotaCredito WHERE id = @idNotaCredito)
    BEGIN
        PRINT 'Error: La nota de credito no existe.';
        RETURN;
    END

    INSERT INTO ventas.DetalleNotaCredito (idNotaCredito, cantidad, subtotal)
    VALUES (@idNotaCredito, @cantidad, @subtotal);
END;
GO



