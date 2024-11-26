-- Se vacían las tablas para eliminar los casos de prueba antes de importar los datos

USE Com2900G18;

-- Desactivar las restricciones de claves foráneas temporalmente
EXEC sp_MSforeachtable @command1="ALTER TABLE ? NOCHECK CONSTRAINT all";

-- Vaciar las tablas y reiniciar los contadores de identidad

DELETE FROM ventas.DetalleNotaCredito;
DBCC CHECKIDENT ('ventas.DetalleNotaCredito', RESEED, 0);
GO

DELETE FROM ventas.NotaCredito;
DBCC CHECKIDENT ('ventas.NotaCredito', RESEED, 0);
GO

DELETE FROM ventas.Factura;
DBCC CHECKIDENT ('ventas.Factura', RESEED, 0);
GO

DELETE FROM ventas.Pago;
DBCC CHECKIDENT ('ventas.Pago', RESEED, 0);
GO

DELETE FROM ventas.DetalleVenta;
DBCC CHECKIDENT ('ventas.DetalleVenta', RESEED, 0);
GO

DELETE FROM ventas.Venta;
DBCC CHECKIDENT ('ventas.Venta', RESEED, 0);
GO

DELETE FROM ventas.TipoFactura;
DBCC CHECKIDENT ('ventas.TipoFactura', RESEED, 0);
GO

DELETE FROM ventas.MedioPago;
DBCC CHECKIDENT ('ventas.MedioPago', RESEED, 0);
GO

DELETE FROM negocio.Empleado;
DBCC CHECKIDENT ('negocio.Empleado', RESEED, 257019);
GO

DELETE FROM negocio.Cargo;
DBCC CHECKIDENT ('negocio.Cargo', RESEED, 0);
GO

DELETE FROM negocio.Sucursal;
DBCC CHECKIDENT ('negocio.Sucursal', RESEED, 0);
GO

DELETE FROM productos.Producto;
DBCC CHECKIDENT ('productos.Producto', RESEED, 0);
GO

DELETE FROM productos.Proveedor;
DBCC CHECKIDENT ('productos.Proveedor', RESEED, 0);
GO

DELETE FROM productos.Categoria;
DBCC CHECKIDENT ('productos.Categoria', RESEED, 0);
GO

DELETE FROM productos.LineaProducto;
DBCC CHECKIDENT ('productos.LineaProducto', RESEED, 0);
GO

DELETE FROM ventas.Cliente;
DBCC CHECKIDENT ('ventas.Cliente', RESEED, 0);
GO

-- Reactivar las restricciones de claves foráneas
EXEC sp_MSforeachtable @command1="ALTER TABLE ? WITH CHECK CHECK CONSTRAINT all";
GO
