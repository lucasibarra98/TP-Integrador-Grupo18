USE Com2900G18
GO

--SCHEMA PRODUCTO

-- Linea Producto
EXEC productos.ModificarLineaProducto @id = 1, @nombre = 'Electronica';
EXEC productos.ModificarLineaProducto @id = 99, @nombre = 'Inexistente'; -- id inexistente
SELECT * FROM productos.LineaProducto;
GO

--Categoria
EXEC productos.ModificarCategoria @id = 1, @nombre = 'Gadgets', @idLineaProd = 1;
EXEC productos.ModificarCategoria @id = 99, @nombre = 'Inexistente', @idLineaProd = 1; -- id inexistente
SELECT * FROM productos.Categoria;
GO

--Proveedor
EXEC productos.ModificarProveedor @id = 1, @nombre = 'IBM';
EXEC productos.ModificarProveedor @id = 99, @nombre = 'Inexistente'; -- id inexistente
SELECT * FROM productos.Proveedor;
GO

--Producto
EXEC productos.ModificarProducto 
    @id = 1, @nombre = 'Iphone', @precioUnitario = 599.99, 
    @cantidadPorUnidad = '5', @idLineaProd = 1, 
    @idProveedor = 1, @catalogo = 'ELE';

EXEC productos.ModificarProducto 
    @id = 99, @nombre = 'Inexistente', @precioUnitario = 199.99, 
    @cantidadPorUnidad = '2', @idLineaProd = 1, 
    @idProveedor = 1, @catalogo = 'ELE'; -- id inexistente

SELECT * FROM productos.Producto;
GO

--SCHEMA NEGOCIO

--Provincia
EXEC negocio.ModificarProvincia @id = 1, @nombre = 'Buenos Aires';
EXEC negocio.ModificarProvincia @id = 99, @nombre = 'Formosa'; -- id inexistente
SELECT * FROM negocio.Provincia;
GO

--Ciudad
EXEC negocio.ModificarCiudad 
    @id = 1, @nombre = 'Ciudad Autonoma de Buenos Aires', 
    @reemplazaPor = NULL, @idProvincia = 1;

EXEC negocio.ModificarCiudad 
    @id = 99, @nombre = 'Casanova', @reemplazaPor = NULL, @idProvincia = 1; -- id inexistente

SELECT * FROM negocio.Ciudad;
GO

--Domicilio
EXEC negocio.ModificarDomicilio 
    @id = 1, @calle = 'Av. de Mayo', @numero = 123, 
    @idCiudad = 1, @codigoPostal = '1000';

EXEC negocio.ModificarDomicilio 
    @id = 99, @calle = 'Falsa', @numero = 0, @idCiudad = 1, @codigoPostal = '9999'; -- id inexistente

SELECT * FROM negocio.Domicilio;
GO

--Sucursal 
EXEC negocio.ModificarSucursal 
    @id = 1, @idDomicilio = 1, @horario = '9:00 - 18:00', @telefono = '112233445';

EXEC negocio.ModificarSucursal 
    @id = 99, @idDomicilio = 1, @horario = '9:00 - 18:00', @telefono = '000000000'; -- id inexistente

SELECT * FROM negocio.Sucursal;
GO

--Cargo
EXEC negocio.ModificarCargo @id = 1, @nombre = 'Director';
EXEC negocio.ModificarCargo @id = 99, @nombre = 'CEO'; -- id inexistente
SELECT * FROM negocio.Cargo;
GO

--Empleado
EXEC negocio.ModificarEmpleado 
    @id = 257020, @nombre = 'Carlos', @apellido = 'Gomez', 
    @dni = 34567890, @idDomicilio = 1, 
    @emailPersonal = 'carlos.gomez@gmail.com', 
    @emailEmpresa = 'carlos.gomez@empresa.com', @cuil = 20345678901, 
    @idCargo = 1, @idSucursal = 1, @turno = 'TT';

EXEC negocio.ModificarEmpleado 
    @id = 99, @nombre = 'Carlitos', @apellido = 'Lito', 
    @dni = 12345678, @idDomicilio = 1, 
    @emailPersonal = 'error@gmail.com', 
    @emailEmpresa = 'error@empresa.com', @cuil = 20123456789, 
    @idCargo = 1, @idSucursal = 1, @turno = 'TM'; -- id inexistente

SELECT * FROM negocio.Empleado;
GO

--SCHEMA VENTAS

--Medio Pago
EXEC ventas.ModificarMedioPago @id = 1, @nombre = 'QR';
EXEC ventas.ModificarMedioPago @id = 99, @nombre = 'Bitcoin'; -- id inexistente
SELECT * FROM ventas.MedioPago;
GO

-- Pago
EXEC ventas.ModificarPago @id = 1, @cod = 'PA-123', @montoTotal = 150.00, @idMedioPago = 1;
EXEC ventas.ModificarPago @id = 99, @cod = 'PAGO-ERROR', @montoTotal = 50.00, @idMedioPago = 1; -- id inexistente
SELECT * FROM ventas.Pago;
GO

--Tipo Factura
EXEC ventas.ModificarTipoFactura @id = 1, @sigla = 'D';
EXEC ventas.ModificarTipoFactura @id = 99, @sigla = 'R'; -- id inexistente
SELECT * FROM ventas.TipoFactura;
GO

--Tipo Cliente
EXEC ventas.ModificarTipoCliente @id = 1, @nombre = 'VIP';
EXEC ventas.ModificarTipoCliente @id = 99, @nombre = 'Premium'; -- id inexistente
SELECT * FROM ventas.TipoCliente;
GO

--Factura
EXEC ventas.ModificarFactura 
    @id = 1, @idTipoFactura = 1, @idTipoCliente = 1, @genero = 'Male', 
    @fecha = '2024-11-25', @hora = '14:00:00', @total = 1000.00, 
    @idPago = 1, @idEmpleado = 257020, @idSucursal = 1;

EXEC ventas.ModificarFactura 
    @id = 99, @idTipoFactura = 1, @idTipoCliente = 1, @genero = 'Female', 
    @fecha = '2024-11-26', @hora = '12:00:00', @total = 500.00, 
    @idPago = 1, @idEmpleado = 257021, @idSucursal = 1; -- id inexistente

SELECT * FROM ventas.Factura;
GO

--Detalle Factura
EXEC ventas.ModificarDetalleFactura @id = 1, @idFactura = 1, @idProducto = 1, @cantidad = 3, @precioUnitario = 200.00;
EXEC ventas.ModificarDetalleFactura @id = 99, @idFactura = 1, @idProducto = 1, @cantidad = 2, @precioUnitario = 100.00; -- id inexistente
SELECT * FROM ventas.DetalleFactura;
GO

--Nota Credito
EXEC ventas.ModificarNotaCredito @id = 1, @idFactura = 1, @fecha = '2024-11-28', @total = 200.00, @motivo = 'Descuento aplicado';
EXEC ventas.ModificarNotaCredito @id = 99, @idFactura = 1, @fecha = '2024-11-29', @total = 100.00, @motivo = 'Saldo insuficiente'; -- id inexistente
SELECT * FROM ventas.NotaCredito;
GO

--Detalle Nota Credito
EXEC ventas.ModificarDetalleNotaCredito @id = 1, @idNotaCredito = 1, @idDetalleFactura = 1, @cantidad = 1;
EXEC ventas.ModificarDetalleNotaCredito @id = 99, @idNotaCredito = 1, @idDetalleFactura = 1, @cantidad = 2; -- id inexistente
SELECT * FROM ventas.DetalleNotaCredito;
GO

