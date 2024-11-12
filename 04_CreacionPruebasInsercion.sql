USE Com2900G18
GO

--SCHEMA PRODUCTOS

--Linea Producto
-- Sin errores
EXEC productos.InsertarLineaProducto @nombre = 'Electrónica';
EXEC productos.InsertarLineaProducto @nombre = 'Hogar';
EXEC productos.InsertarLineaProducto @nombre = 'Oficina';

-- Error (nombre duplicado)
EXEC productos.InsertarLineaProducto @nombre = 'Electrónica';

-- Verifico
SELECT * FROM productos.LineaProducto;
GO

--Categoria
-- Sin errores
EXEC productos.InsertarCategoria @nombre = 'Televisores', @idLineaProd = 1;
EXEC productos.InsertarCategoria @nombre = 'Muebles', @idLineaProd = 2;
EXEC productos.InsertarCategoria @nombre = 'Escritorios', @idLineaProd = 3;

-- Error (idLineaProd no existe)
EXEC productos.InsertarCategoria @nombre = 'Cocina', @idLineaProd = 99;

-- Verifico
SELECT * FROM productos.Categoria;
GO

--Proveedor
-- Sin errores
EXEC productos.InsertarProveedor @nombre = 'Proveedor A';
EXEC productos.InsertarProveedor @nombre = 'Proveedor B';
EXEC productos.InsertarProveedor @nombre = 'Proveedor C';

-- Error (nombre duplicado)
EXEC productos.InsertarProveedor @nombre = 'Proveedor A';

-- Verifico
SELECT * FROM productos.Proveedor;
GO

--Producto
-- Sin errores
EXEC productos.InsertarProducto @nombre = 'Televisor 40"', @precioUnitario = 500.00, @cantidadPorUnidad = '1', @idLineaProd = 1, @idProveedor = 1, @catalogo = 'ELE';
EXEC productos.InsertarProducto @nombre = 'Escritorio', @precioUnitario = 150.00, @cantidadPorUnidad = '1', @idLineaProd = 3, @idProveedor = 2, @catalogo = 'IMP';

-- Error (nombre duplicado , idLineaProd no existe)
EXEC productos.InsertarProducto @nombre = 'Televisor 40"', @precioUnitario = 600.00, @cantidadPorUnidad = '1', @idLineaProd = 1, @idProveedor = 1, @catalogo = 'ELE';
EXEC productos.InsertarProducto @nombre = 'Silla', @precioUnitario = 75.00, @cantidadPorUnidad = '1', @idLineaProd = 99, @idProveedor = 2, @catalogo = 'IMP'; 

-- Verifico
SELECT * FROM productos.Producto;
GO

--SCHEMA NEGOCIO

--Provincia
-- Sin errores
EXEC negocio.InsertarProvincia @nombre = 'Buenos Aires';
EXEC negocio.InsertarProvincia @nombre = 'Cordoba';
EXEC negocio.InsertarProvincia @nombre = 'Santa Fe';

-- Error (nombre duplicado)
EXEC negocio.InsertarProvincia @nombre = 'Buenos Aires';

-- Verifico
SELECT * FROM negocio.Provincia;
GO

--Ciudad
-- Sin errores
EXEC negocio.InsertarCiudad @nombre = 'La Plata', @reemplazaPor = NULL, @idProvincia = 1;
EXEC negocio.InsertarCiudad @nombre = 'Córdoba', @reemplazaPor = NULL, @idProvincia = 2;

-- Error (nombre duplicado, idProvincia no existe)
EXEC negocio.InsertarCiudad @nombre = 'La Plata', @reemplazaPor = NULL, @idProvincia = 1; 
EXEC negocio.InsertarCiudad @nombre = 'Rosario', @reemplazaPor = NULL, @idProvincia = 99; 

-- Verifico
SELECT * FROM negocio.Ciudad;
GO

--Domicilio
-- Sin errores
EXEC negocio.InsertarDomicilio @calle = 'San Martin', @numero = 123, @idCiudad = 1, @codigoPostal = '1900';
EXEC negocio.InsertarDomicilio @calle = '9 de Julio', @numero = 456, @idCiudad = 2, @codigoPostal = '5000';
EXEC negocio.InsertarDomicilio @calle = 'Florencio Varela', @numero = 345, @idCiudad = 1, @codigoPostal = '1900';

-- Error (idCiudad inexistente)
EXEC negocio.InsertarDomicilio @calle = 'Belgrano', @numero = 789, @idCiudad = 99, @codigoPostal = '6000';

-- Verifico
SELECT * FROM negocio.Domicilio;
GO

--Cargo
-- Sin errores
EXEC negocio.InsertarCargo @nombre = 'Gerente';
EXEC negocio.InsertarCargo @nombre = 'Supervisor';
EXEC negocio.InsertarCargo @nombre = 'Vendedor';

-- Error (nombre duplicado)
EXEC negocio.InsertarCargo @nombre = 'Gerente';

-- Verifico
SELECT * FROM negocio.Cargo;
GO

--Sucursal
-- Sin errores
EXEC negocio.InsertarSucursal @idDomicilio = 1, @horario = '8:00 - 17:00', @telefono = '123456789';
EXEC negocio.InsertarSucursal @idDomicilio = 2, @horario = '9:00 - 18:00', @telefono = '987654321';
EXEC negocio.InsertarSucursal @idDomicilio = 3, @horario = '10:00 - 19:00', @telefono = '555555555';

-- Error (idDomicilio inexistente)
EXEC negocio.InsertarSucursal @idDomicilio = 99, @horario = '8:00 - 17:00', @telefono = '111111111';

-- Verifico
SELECT * FROM negocio.Sucursal;
GO

--Empleado
-- Sin errores
EXEC negocio.InsertarEmpleado 
    @nombre = 'Juan', @apellido = 'Pérez', @dni = 12345678, @idDomicilio = 1, 
    @emailPersonal = 'juan.perez@gmail.com', @emailEmpresa = 'juan.perez@empresa.com', 
    @cuil = 20123456789, @idCargo = 1, @idSucursal = 1, @turno = 'TM';

EXEC negocio.InsertarEmpleado 
    @nombre = 'Ana', @apellido = 'López', @dni = 87654321, @idDomicilio = 2, 
    @emailPersonal = 'ana.lopez@gmail.com', @emailEmpresa = 'ana.lopez@empresa.com', 
    @cuil = 20876543210, @idCargo = 2, @idSucursal = 2, @turno = 'TT';

EXEC negocio.InsertarEmpleado 
    @nombre = 'Carlos', @apellido = 'Ramírez', @dni = 11223344, @idDomicilio = 3, 
    @emailPersonal = 'carlos.ramirez@gmail.com', @emailEmpresa = 'carlos.ramirez@empresa.com', 
    @cuil = 20112233445, @idCargo = 3, @idSucursal = 3, @turno = 'Jornada Completa';

-- Error
EXEC negocio.InsertarEmpleado 
    @nombre = 'Mario', @apellido = 'González', @dni = 22334455, @idDomicilio = 99, 
    @emailPersonal = 'mario.gonzalez@gmail.com', @emailEmpresa = 'mario.gonzalez@empresa.com', 
    @cuil = 20223344556, @idCargo = 1, @idSucursal = 1, @turno = 'TM'; -- idDomicilio inexistente

EXEC negocio.InsertarEmpleado 
    @nombre = 'Lucía', @apellido = 'Martínez', @dni = 33445566, @idDomicilio = 1, 
    @emailPersonal = 'lucia.martinez@gmail.com', @emailEmpresa = 'lucia.martinez@empresa.com', 
    @cuil = 20334455667, @idCargo = 99, @idSucursal = 1, @turno = 'TT'; -- idCargo inexistente

EXEC negocio.InsertarEmpleado 
    @nombre = 'Raúl', @apellido = 'Fernández', @dni = 44556677, @idDomicilio = 2, 
    @emailPersonal = 'raul.fernandez@gmail.com', @emailEmpresa = 'raul.fernandez@empresa.com', 
    @cuil = 20445566778, @idCargo = 2, @idSucursal = 99, @turno = 'TT'; -- idSucursal inexistente

-- Verifico
SELECT * FROM negocio.Empleado;
GO


--SCHEMA VENTAS

--Medio Pago
-- Sin errores
EXEC ventas.InsertarMedioPago @nombre = 'Efectivo';
EXEC ventas.InsertarMedioPago @nombre = 'Tarjeta de Credito';
EXEC ventas.InsertarMedioPago @nombre = 'Transferencia Bancaria';

-- Error (nombre duplicado)
EXEC ventas.InsertarMedioPago @nombre = 'Efectivo';

-- Verifico
SELECT * FROM ventas.MedioPago;
GO

--Tipo Factura
-- Sin errores
EXEC ventas.InsertarTipoFactura @sigla = 'A';
EXEC ventas.InsertarTipoFactura @sigla = 'B';
EXEC ventas.InsertarTipoFactura @sigla = 'C';

-- Error (sigla duplicada)
EXEC ventas.InsertarTipoFactura @sigla = 'A';

-- Verifico
SELECT * FROM ventas.TipoFactura;
GO

--Tipo Cliente
-- Sin errores
EXEC ventas.InsertarTipoCliente @nombre = 'Miembro';
EXEC ventas.InsertarTipoCliente @nombre = 'No miembro';
EXEC ventas.InsertarTipoCliente @nombre = 'Distribuidor';

-- Error (nombre duplicado)
EXEC ventas.InsertarTipoCliente @nombre = 'Miembro';

-- Verifico
SELECT * FROM ventas.TipoCliente;
GO

--Pago
-- Sin errores
EXEC ventas.InsertarPago @cod = 'PA-001', @montoTotal = 500.00, @idMedioPago = 1;
EXEC ventas.InsertarPago @cod = 'PA-002', @montoTotal = 750.00, @idMedioPago = 2;
EXEC ventas.InsertarPago @cod = 'PA-004', @montoTotal = 750.00, @idMedioPago = 3;

-- Error (codigo duplicado es UNIQUE, idMedioPago no existe)
EXEC ventas.InsertarPago @cod = 'PA-001', @montoTotal = 100.00, @idMedioPago = 1; 
EXEC ventas.InsertarPago @cod = 'PA-003', @montoTotal = 200.00, @idMedioPago = 99; 

-- Verifico
SELECT * FROM ventas.Pago;
GO

--Factura
-- Sin errores
EXEC ventas.InsertarFactura 
    @idTipoFactura = 1, @idTipoCliente = 1, @genero = 'Male', @fecha = '2024-11-10', 
    @hora = '12:00:00', @total = 500.00, @idPago = 1, @idEmpleado = 257020, @idSucursal = 1;

EXEC ventas.InsertarFactura 
    @idTipoFactura = 2, @idTipoCliente = 2, @genero = 'Female', @fecha = '2024-11-11', 
    @hora = '15:00:00', @total = 750.00, @idPago = 2, @idEmpleado = 257021, @idSucursal = 2;

-- Error (idTipoFactura , idTipoCliente no existen)
EXEC ventas.InsertarFactura 
    @idTipoFactura = 99, @idTipoCliente = 1, @genero = 'Male', @fecha = '2024-11-12', 
    @hora = '10:00:00', @total = 300.00, @idPago = 3, @idEmpleado = 257022, @idSucursal = 3;

EXEC ventas.InsertarFactura 
    @idTipoFactura = 1, @idTipoCliente = 99, @genero = 'Female', @fecha = '2024-11-13', 
    @hora = '09:00:00', @total = 400.00, @idPago = 4, @idEmpleado = 257023, @idSucursal = 4; 

-- Verifico
SELECT * FROM ventas.Factura;
GO



--Detalle Factura
-- Sin errores
EXEC ventas.InsertarDetalleFactura @idFactura = 2, @idProducto = 1, @cantidad = 2, @precioUnitario = 250.00;
EXEC ventas.InsertarDetalleFactura @idFactura = 3, @idProducto = 2, @cantidad = 1, @precioUnitario = 750.00;

-- Error (idProducto, idFactura no existen)
EXEC ventas.InsertarDetalleFactura @idFactura = 99, @idProducto = 1, @cantidad = 3, @precioUnitario = 100.00; 
EXEC ventas.InsertarDetalleFactura @idFactura = 2, @idProducto = 99, @cantidad = 1, @precioUnitario = 250.00; 

-- Verifico
SELECT * FROM ventas.DetalleFactura;
GO

--Nota Credito
-- Sin errores
EXEC ventas.InsertarNotaCredito @idFactura = 2, @fecha = '2024-11-15', @total = 150.00, @motivo = 'Devolucion parcial';
EXEC ventas.InsertarNotaCredito @idFactura = 3, @fecha = '2024-11-16', @total = 250.00, @motivo = 'Descuento especial';

-- Error (idFactura no existe)
EXEC ventas.InsertarNotaCredito @idFactura = 99, @fecha = '2024-11-17', @total = 100.00, @motivo = 'Devolucion'; 

-- Verifico
SELECT * FROM ventas.NotaCredito;
GO

--Detalle Nota Credito
-- Sin errores
EXEC ventas.InsertarDetalleNotaCredito @idNotaCredito = 1, @idDetalleFactura = 1, @cantidad = 1;
EXEC ventas.InsertarDetalleNotaCredito @idNotaCredito = 3, @idDetalleFactura = 2, @cantidad = 1;

-- Error (idNotaCredito, idFactura no existen)
EXEC ventas.InsertarDetalleNotaCredito @idNotaCredito = 99, @idDetalleFactura = 1, @cantidad = 1; 
EXEC ventas.InsertarDetalleNotaCredito @idNotaCredito = 3, @idDetalleFactura = 99, @cantidad = 1; 

-- Verifico
SELECT * FROM ventas.DetalleNotaCredito;
GO


