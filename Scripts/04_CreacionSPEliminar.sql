USE Com2900G18
GO

------SCHEMA PRODUCTOS------

--Linea Producto 

CREATE OR ALTER PROCEDURE productos.EliminarLineaProducto
    @id INT
AS
BEGIN
--Verificamos si la linea de producto existe
    IF NOT EXISTS (SELECT 1 FROM productos.LineaProducto WHERE id = @id)
    BEGIN
        PRINT 'Error: La linea de producto no existe.';
        RETURN;
    END

--Verificamos si la linea de producto esta asociada a alguna categoria o producto
    IF EXISTS (SELECT 1 FROM productos.Categoria WHERE idLineaProd = @id) OR
       EXISTS (SELECT 1 FROM productos.Producto WHERE idLineaProd = @id)
    BEGIN
        PRINT 'Error: No se puede eliminar la linea de producto porque esta asociada a una o mas categorias o productos.';
        RETURN;
    END

    DELETE FROM productos.LineaProducto
    WHERE id = @id;
END;
GO

--Categoria

CREATE OR ALTER PROCEDURE productos.EliminarCategoria
    @id INT
AS
BEGIN
--Verificamos si la categoria existe
    IF NOT EXISTS (SELECT 1 FROM productos.Categoria WHERE id = @id)
    BEGIN
        PRINT 'Error: La categoria no existe.';
        RETURN;
    END

--Verificamos si la categoria esta asociada a algun producto
    IF EXISTS (SELECT 1 FROM productos.Producto WHERE idLineaProd = @id)
    BEGIN
        PRINT 'Error: No se puede eliminar la categoria porque esta asociada a uno o mas productos.';
        RETURN;
    END

    DELETE FROM productos.Categoria
    WHERE id = @id;
END;
GO

--Proveedor 

CREATE OR ALTER PROCEDURE productos.EliminarProveedor
    @id INT
AS
BEGIN
--Verificamos si el proveedor existe
    IF NOT EXISTS (SELECT 1 FROM productos.Proveedor WHERE id = @id)
    BEGIN
        PRINT 'Error: El proveedor no existe.';
        RETURN;
    END

--Verificamos si el proveedor esta asociado a algun producto
    IF EXISTS (SELECT 1 FROM productos.Producto WHERE idProveedor = @id)
    BEGIN
        PRINT 'Error: No se puede eliminar el proveedor porque esta asociado a uno o mas productos.';
        RETURN;
    END

    -- Eliminar el proveedor
    DELETE FROM productos.Proveedor
    WHERE id = @id;
END;
GO

--Productos

CREATE OR ALTER PROCEDURE productos.EliminarProducto
    @id INT
AS
BEGIN
--Verificamos si el producto existe
    IF NOT EXISTS (SELECT 1 FROM productos.Producto WHERE id = @id)
    BEGIN
        PRINT 'Error: El producto no existe.';
        RETURN;
    END

--Verificamos si el producto ya esta inactivo
    IF EXISTS (SELECT 1 FROM productos.Producto WHERE id = @id AND estado = 'I')
    BEGIN
        PRINT 'Error: El producto ya esta inactivo.';
        RETURN;
    END

--Marcamos el producto como inactivo
    UPDATE productos.Producto
    SET estado = 'I'
    WHERE id = @id;
END;
GO

------SCHEMA NEGOCIO------

--Sucursal

CREATE OR ALTER PROCEDURE negocio.EliminarSucursal
    @id INT
AS
BEGIN
--Verificamos si la sucursal existe
    IF NOT EXISTS (SELECT 1 FROM negocio.Sucursal WHERE id = @id)
    BEGIN
        PRINT 'Error: La sucursal no existe.';
        RETURN;
    END

--Verificamos si la sucursal esta asociada a empleados o ventas
    IF EXISTS (SELECT 1 FROM negocio.Empleado WHERE idSucursal = @id) OR
       EXISTS (SELECT 1 FROM ventas.Venta WHERE idSucursal = @id)
    BEGIN
        PRINT 'Error: No se puede eliminar la sucursal porque esta asociada a empleados o ventas.';
        RETURN;
    END

    DELETE FROM negocio.Sucursal
    WHERE id = @id;
END;
GO

--Cargo

CREATE OR ALTER PROCEDURE negocio.EliminarCargo
    @id INT
AS
BEGIN
--Verificamos si el cargo existe
    IF NOT EXISTS (SELECT 1 FROM negocio.Cargo WHERE id = @id)
    BEGIN
        PRINT 'Error: El cargo no existe.';
        RETURN;
    END

--Verificamos si el cargo esta asociado a empleados
    IF EXISTS (SELECT 1 FROM negocio.Empleado WHERE idCargo = @id)
    BEGIN
        PRINT 'Error: No se puede eliminar el cargo porque esta asociado a uno o mas empleados.';
        RETURN;
    END

    DELETE FROM negocio.Cargo
    WHERE id = @id;
END;
GO

--Empleado

CREATE OR ALTER PROCEDURE negocio.EliminarEmpleado
    @id INT
AS
BEGIN
--Verificamos si el empleado existe
    IF NOT EXISTS (SELECT 1 FROM negocio.Empleado WHERE id = @id)
    BEGIN
        PRINT 'Error: El empleado no existe.';
        RETURN;
    END

--Verificamos si el empleado esta asociado a ventas
    IF EXISTS (SELECT 1 FROM ventas.Venta WHERE idEmpleado = @id)
    BEGIN
        PRINT 'Error: No se puede eliminar el empleado porque esta asociado a ventas.';
        RETURN;
    END

    DELETE FROM negocio.Empleado
    WHERE id = @id;
END;
GO


------SCHEMA VENTAS------

--Medio Pago

CREATE OR ALTER PROCEDURE ventas.EliminarMedioPago
    @id INT
AS
BEGIN
--Verificamos si el medio de pago existe
    IF NOT EXISTS (SELECT 1 FROM ventas.MedioPago WHERE id = @id)
    BEGIN
        PRINT 'Error: El medio de pago no existe.';
        RETURN;
    END

--Verificamos si el medio de pago esta asociado a algun pago
    IF EXISTS (SELECT 1 FROM ventas.Pago WHERE idMedioPago = @id)
    BEGIN
        PRINT 'Error: No se puede eliminar el medio de pago porque está asociado a uno o mas pagos.';
        RETURN;
    END

    DELETE FROM ventas.MedioPago
    WHERE id = @id;
END;
GO

--Pago

CREATE OR ALTER PROCEDURE ventas.EliminarPago
    @id INT
AS
BEGIN
--Verificamos si el pago existe
    IF NOT EXISTS (SELECT 1 FROM ventas.Pago WHERE id = @id)
    BEGIN
        PRINT 'Error: El pago no existe.';
        RETURN;
    END

--Verificamos si el pago está asociado a alguna factura
    IF EXISTS (SELECT 1 FROM ventas.Factura WHERE idPago = @id)
    BEGIN
        PRINT 'Error: No se puede eliminar el pago porque esta asociado a una o mas facturas.';
        RETURN;
    END

    DELETE FROM ventas.Pago
    WHERE id = @id;
END;
GO

--Tipo Factura

CREATE OR ALTER PROCEDURE ventas.EliminarTipoFactura
    @id INT
AS
BEGIN
--Verificamos si el tipo de factura existe
    IF NOT EXISTS (SELECT 1 FROM ventas.TipoFactura WHERE id = @id)
    BEGIN
        PRINT 'Error: El tipo de factura no existe.';
        RETURN;
    END

--Verificamos si el tipo de factura esta asociado a alguna factura
    IF EXISTS (SELECT 1 FROM ventas.Factura WHERE idTipoFactura = @id)
    BEGIN
        PRINT 'Error: No se puede eliminar el tipo de factura porque está asociado a una o mas facturas.';
        RETURN;
    END

    DELETE FROM ventas.TipoFactura
    WHERE id = @id;
END;
GO

--Cliente

CREATE OR ALTER PROCEDURE ventas.EliminarCliente
    @id INT
AS
BEGIN
--Verificamos si el cliente existe
    IF NOT EXISTS (SELECT 1 FROM ventas.Cliente WHERE id = @id)
    BEGIN
        PRINT 'Error: El cliente no existe.';
        RETURN;
    END

--Verificamos si el cliente está asociado a alguna venta
    IF EXISTS (SELECT 1 FROM ventas.Venta WHERE idCliente = @id)
    BEGIN
        PRINT 'Error: No se puede eliminar el cliente porque está asociado a una o mas ventas.';
        RETURN;
    END

    DELETE FROM ventas.Cliente
    WHERE id = @id;
END;
GO

--Venta

CREATE OR ALTER PROCEDURE ventas.EliminarVenta
    @id INT
AS
BEGIN
--Verificamos si la venta existe
    IF NOT EXISTS (SELECT 1 FROM ventas.Venta WHERE id = @id)
    BEGIN
        PRINT 'Error: La venta no existe.';
        RETURN;
    END

--Verificamos si la venta esta asociada a algún detalle de venta
    IF EXISTS (SELECT 1 FROM ventas.DetalleVenta WHERE idVenta = @id)
    BEGIN
        PRINT 'Error: No se puede eliminar la venta porque tiene detalles asociados.';
        RETURN;
    END

--Verificamos si la venta esta asociada a alguna factura
    IF EXISTS (SELECT 1 FROM ventas.Factura WHERE idVenta = @id)
    BEGIN
        PRINT 'Error: No se puede eliminar la venta porque está asociada a una o mas facturas.';
        RETURN;
    END

    DELETE FROM ventas.Venta
    WHERE id = @id;
END;
GO

--Detalle Venta

CREATE OR ALTER PROCEDURE ventas.EliminarDetalleVenta
    @id INT
AS
BEGIN
--Verificamos si el detalle de venta existe
    IF NOT EXISTS (SELECT 1 FROM ventas.DetalleVenta WHERE id = @id)
    BEGIN
        PRINT 'Error: El detalle de venta no existe.';
        RETURN;
    END

    DELETE FROM ventas.DetalleVenta
    WHERE id = @id;
END;
GO

--Factura

CREATE OR ALTER PROCEDURE ventas.EliminarFactura
    @id INT
AS
BEGIN
--Verificar si la factura existe
    IF NOT EXISTS (SELECT 1 FROM ventas.Factura WHERE id = @id)
    BEGIN
        PRINT 'Error: El ID de la factura no existe.';
        RETURN;
    END

--Verificar si la factura está asociada a alguna nota de credito
    IF EXISTS (SELECT 1 FROM ventas.NotaCredito WHERE idFactura = @id)
    BEGIN
        PRINT 'Error: No se puede eliminar la factura porque tiene notas de credito asociadas.';
        RETURN;
    END

    DELETE FROM ventas.Factura
    WHERE id = @id;
END;
GO

--Nota Credito

CREATE OR ALTER PROCEDURE ventas.EliminarNotaCredito
    @id INT
AS
BEGIN
--Verificamos si la nota de credito existe
    IF NOT EXISTS (SELECT 1 FROM ventas.NotaCredito WHERE id = @id)
    BEGIN
        PRINT 'Error: La nota de credito no existe.';
        RETURN;
    END

    DELETE FROM ventas.NotaCredito
    WHERE id = @id;
END;
GO

--Detalle Nota Credito

CREATE OR ALTER PROCEDURE ventas.EliminarDetalleNotaCredito
    @id INT
AS
BEGIN
-- Verificamos si el detalle de la nota de credito existe
    IF NOT EXISTS (SELECT 1 FROM ventas.DetalleNotaCredito WHERE id = @id)
    BEGIN
        PRINT 'Error: El detalle de la nota de credito no existe.';
        RETURN;
    END

    DELETE FROM ventas.DetalleNotaCredito
    WHERE id = @id;
END;
GO





