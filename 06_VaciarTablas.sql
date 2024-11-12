-- Se vacían las tablas para eliminar los casos de prueba antes de importar los datos

TRUNCATE TABLE ventas.DetalleNotaCredito
TRUNCATE TABLE ventas.NotaCredito
TRUNCATE TABLE ventas.DetalleFactura
TRUNCATE TABLE ventas.Factura
TRUNCATE TABLE ventas.TipoCliente
TRUNCATE TABLE ventas.TipoFactura
TRUNCATE TABLE ventas.Pago
TRUNCATE TABLE ventas.MedioPago
TRUNCATE TABLE negocio.Empleado
TRUNCATE TABLE negocio.Cargo
TRUNCATE TABLE negocio.Sucursal
TRUNCATE TABLE negocio.Domicilio
TRUNCATE TABLE negocio.Ciudad
TRUNCATE TABLE negocio.Provincia
TRUNCATE TABLE productos.Producto
TRUNCATE TABLE productos.Proveedor
TRUNCATE TABLE productos.Categoria
TRUNCATE TABLE productos.LineaProducto