-- Se vacían las tablas para eliminar los casos de prueba antes de importar los datos

USE Com2900G18;

DELETE FROM ventas.Factura
GO
DELETE FROM ventas.Pago
GO
DELETE FROM ventas.DetalleVenta
GO
DELETE FROM ventas.Venta
GO
DELETE FROM ventas.DetalleNotaCredito;
GO
DELETE FROM ventas.NotaCredito
GO
DELETE FROM ventas.TipoFactura
GO
DELETE FROM ventas.MedioPago
GO
DELETE FROM negocio.Empleado
GO
DELETE FROM negocio.Cargo
GO
DELETE FROM negocio.Sucursal
GO
DELETE FROM productos.Producto
GO
DELETE FROM productos.Proveedor
GO
DELETE FROM productos.Categoria
GO
DELETE FROM productos.LineaProducto
GO