USE Com2900G18
GO

--SCHEMA PRODUCTOS

--Elimino Linea Producto
CREATE OR ALTER PROCEDURE productos.EliminarLineaProducto
    @id INT
AS
BEGIN
	--Verifico idLineaProducto
    IF NOT EXISTS (SELECT 1 FROM productos.LineaProducto WHERE id = @id)
    BEGIN
        PRINT 'Error: El id de la línea de producto no existe.';
        RETURN;
    END

    DELETE FROM productos.LineaProducto
    WHERE id = @id;
END;
GO

--Elimino Categoria
CREATE OR ALTER PROCEDURE productos.EliminarCategoria
    @id INT
AS
BEGIN
	--Verifico idCategoria
    IF NOT EXISTS (SELECT 1 FROM productos.Categoria WHERE id = @id)
    BEGIN
        PRINT 'Error: El id de la categoria no existe.';
        RETURN;
    END

    DELETE FROM productos.Categoria
    WHERE id = @id;
END;
GO

--Elimino Proveedor
CREATE OR ALTER PROCEDURE productos.EliminarProveedor
    @id INT
AS
BEGIN	
	--Verifico idProveedor
    IF NOT EXISTS (SELECT 1 FROM productos.Proveedor WHERE id = @id)
    BEGIN
        PRINT 'Error: El id del proveedor no existe.';
        RETURN;
    END

    DELETE FROM productos.Proveedor
    WHERE id = @id;
END;
GO

--Elimino Producto
CREATE OR ALTER PROCEDURE productos.EliminarProductoLogico
    @id INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM productos.Producto WHERE id = @id)
    BEGIN
        PRINT 'Error: El id del producto no existe.';
        RETURN;
    END

    UPDATE productos.Producto
    SET estado = 'I'
    WHERE id = @id;
END;
GO

--SCHEMA NEGOCIO

--Elimino Provincia
CREATE OR ALTER PROCEDURE negocio.EliminarProvincia
    @id INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM negocio.Provincia WHERE id = @id)
    BEGIN
        PRINT 'Error: El id de la provincia no existe.';
        RETURN;
    END

    DELETE FROM negocio.Provincia
    WHERE id = @id;
END;
GO

--Elimino Ciudad
CREATE OR ALTER PROCEDURE negocio.EliminarCiudad
    @id INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM negocio.Ciudad WHERE id = @id)
    BEGIN
        PRINT 'Error: El id de la ciudad no existe.';
        RETURN;
    END

    DELETE FROM negocio.Ciudad
    WHERE id = @id;
END;
GO

--Elimino Domicilio
CREATE OR ALTER PROCEDURE negocio.EliminarDomicilio
    @id INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM negocio.Domicilio WHERE id = @id)
    BEGIN
        PRINT 'Error: El id del domicilio no existe.';
        RETURN;
    END

    DELETE FROM negocio.Domicilio
    WHERE id = @id;
END;
GO

--Elimino Sucursal
CREATE OR ALTER PROCEDURE negocio.EliminarSucursal
    @id INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM negocio.Sucursal WHERE id = @id)
    BEGIN
        PRINT 'Error: El id de la sucursal no existe.';
        RETURN;
    END

    DELETE FROM negocio.Sucursal
    WHERE id = @id;
END;
GO

--Elimino Cargo
CREATE OR ALTER PROCEDURE negocio.EliminarCargo
    @id INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM negocio.Cargo WHERE id = @id)
    BEGIN
        PRINT 'Error: El id del cargo no existe.';
        RETURN;
    END

    DELETE FROM negocio.Cargo
    WHERE id = @id;
END;
GO

--Elimino Empleado
CREATE OR ALTER PROCEDURE negocio.EliminarEmpleado
    @id INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM negocio.Empleado WHERE id = @id)
    BEGIN
        PRINT 'Error: El id del empleado no existe.';
        RETURN;
    END

    DELETE FROM negocio.Empleado
    WHERE id = @id;
END;
GO


--SCHEMA VENTAS

--Elimino Medio Pago
CREATE OR ALTER PROCEDURE ventas.EliminarMedioPago
    @id INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM ventas.MedioPago WHERE id = @id)
    BEGIN
        PRINT 'Error: El id del medio de pago no existe.';
        RETURN;
    END

    DELETE FROM ventas.MedioPago
    WHERE id = @id;
END;
GO

--Elimino Pago
CREATE OR ALTER PROCEDURE ventas.EliminarPago
    @id INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM ventas.Pago WHERE id = @id)
    BEGIN
        PRINT 'Error: El id del pago no existe.';
        RETURN;
    END

    DELETE FROM ventas.Pago
    WHERE id = @id;
END;
GO

--Elimino Tipo Factura
CREATE OR ALTER PROCEDURE ventas.EliminarTipoFactura
    @id INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM ventas.TipoFactura WHERE id = @id)
    BEGIN
        PRINT 'Error: El id del tipo de factura no existe.';
        RETURN;
    END

    DELETE FROM ventas.TipoFactura
    WHERE id = @id;
END;
GO

--Elimino Tipo Cliente
CREATE OR ALTER PROCEDURE ventas.EliminarTipoCliente
    @id INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM ventas.TipoCliente WHERE id = @id)
    BEGIN
        PRINT 'Error: El id del tipo de cliente no existe.';
        RETURN;
    END

    DELETE FROM ventas.TipoCliente
    WHERE id = @id;
END;
GO

--Elimino Factura
CREATE OR ALTER PROCEDURE ventas.EliminarFactura
    @id INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM ventas.Factura WHERE id = @id)
    BEGIN
        PRINT 'Error: El id de la factura no existe.';
        RETURN;
    END

    DELETE FROM ventas.Factura
    WHERE id = @id;
END;
GO

--Elimino Detalle Factura
CREATE OR ALTER PROCEDURE ventas.EliminarDetalleFactura
    @id INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM ventas.DetalleFactura WHERE id = @id)
    BEGIN
        PRINT 'Error: El id del detalle de factura no existe.';
        RETURN;
    END

    DELETE FROM ventas.DetalleFactura
    WHERE id = @id;
END;
GO

--Elimino Nota Credito
CREATE OR ALTER PROCEDURE ventas.EliminarNotaCredito
    @id INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM ventas.NotaCredito WHERE id = @id)
    BEGIN
        PRINT 'Error: El id de la nota de credito no existe.';
        RETURN;
    END

    DELETE FROM ventas.NotaCredito
    WHERE id = @id;
END;
GO

--Elimino Detalle Nota Credito 
CREATE OR ALTER PROCEDURE ventas.EliminarDetalleNotaCredito
    @id INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM ventas.DetalleNotaCredito WHERE id = @id)
    BEGIN
        PRINT 'Error: El id del detalle de la nota de credito no existe.';
        RETURN;
    END

    DELETE FROM ventas.DetalleNotaCredito
    WHERE id = @id;
END;
GO









