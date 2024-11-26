USE Com2900G18
GO
------SCHEMA PRODUCTOS------

--Linea Producto

--Insercion correcta
EXEC productos.InsertarLineaProducto @nombre = 'Electrodomesticos'; 
EXEC productos.InsertarLineaProducto @nombre = 'Informatica'; 

--Insercion con error (duplicado)
EXEC productos.InsertarLineaProducto @nombre = 'Electrodomesticos';

--Visualizacion
SELECT * FROM productos.LineaProducto;

--Categoria

--Insercion correcta
EXEC productos.InsertarCategoria @nombre = 'Cocinas', @idLineaProd = 1; 
EXEC productos.InsertarCategoria @nombre = 'Lavarropas', @idLineaProd = 1; 
EXEC productos.InsertarCategoria @nombre = 'Monitores', @idLineaProd = 2; 

--Insercion con error (categoria duplicada)
EXEC productos.InsertarCategoria @nombre = 'Cocinas', @idLineaProd = 1; 

--Insercion con error (idLineaProd inexistente)
EXEC productos.InsertarCategoria @nombre = 'Impresoras', @idLineaProd = 99; 

--Visualizacion
SELECT * FROM productos.Categoria;

--Proveedor

--Insercion correcta
EXEC productos.InsertarProveedor @nombre = 'Samsung'; 
EXEC productos.InsertarProveedor @nombre = 'LG'; 
EXEC productos.InsertarProveedor @nombre = 'HP'; 

--Insercion con error (proveedor duplicado)
EXEC productos.InsertarProveedor @nombre = 'Samsung'; 

--Visualizacion
SELECT * FROM productos.Proveedor;

--Producto

-- Insercion correcta
EXEC productos.InsertarProducto 
    @nombre = 'Galaxy S23',
    @idLineaProd = 1,
    @idProveedor = 1,
    @precioUnitario = 1200.50,
    @cantidadPorUnidad = 'Unidad',
    @catalogo = 'ELE'; 

EXEC productos.InsertarProducto 
    @nombre = 'Monitor LG UltraFine',
    @idLineaProd = 2,
    @idProveedor = 2,
    @precioUnitario = 400.00,
    @cantidadPorUnidad = 'Unidad',
    @catalogo = 'ELE'; 

EXEC productos.InsertarProducto 
    @nombre = 'Impresora HP LaserJet',
    @idLineaProd = 2,
    @idProveedor = 3,
    @precioUnitario = 350.75,
    @cantidadPorUnidad = 'Unidad',
    @catalogo = 'IMP'; 

-- Insercion con error (nombre duplicado)
EXEC productos.InsertarProducto 
    @nombre = 'Galaxy S23',
    @idLineaProd = 1,
    @idProveedor = 1,
    @precioUnitario = 1200.50,
    @cantidadPorUnidad = 'Unidad',
    @catalogo = 'ELE'; 

-- Insercion con error (idLineaProd inexistente)
EXEC productos.InsertarProducto 
    @nombre = 'Tablet Samsung Galaxy Tab',
    @idLineaProd = 99,
    @idProveedor = 1,
    @precioUnitario = 600.00,
    @cantidadPorUnidad = 'Unidad',
    @catalogo = 'ELE'; 

--Insercion con error (idProveedor inexistente)
EXEC productos.InsertarProducto 
    @nombre = 'Teclado Gaming',
    @idLineaProd = 2,
    @idProveedor = 99,
    @precioUnitario = 150.00,
    @cantidadPorUnidad = 'Unidad',
    @catalogo = 'IMP'; 

--Visualizacion
SELECT * FROM productos.Producto;


------SCHEMA NEGOCIO------

--Sucursal

--Insercion correcta
EXEC negocio.InsertarSucursal 
    @nombre = 'Sucursal Buenos Aires',
    @direccion = 'Av. Corrientes 1234',
    @horario = '08:00-18:00',
    @telefono = '123456789',
    @ciudad = 'Buenos Aires'; 

EXEC negocio.InsertarSucursal 
    @nombre = 'Sucursal Córdoba',
    @direccion = 'Av. Colón 5678',
    @horario = '09:00-17:00',
    @telefono = '987654321',
    @ciudad = 'Córdoba'; 

--Insercion con error (direccion duplicada)
EXEC negocio.InsertarSucursal 
    @nombre = 'Sucursal Repetida',
    @direccion = 'Av. Corrientes 1234',
    @horario = '08:00-18:00',
    @telefono = '123456780',
    @ciudad = 'Buenos Aires'; 

--Visualizacion
SELECT * FROM negocio.Sucursal;

--Cargo

-- Insercion correcta
EXEC negocio.InsertarCargo @nombre = 'Gerente';
EXEC negocio.InsertarCargo @nombre = 'Vendedor'; 
EXEC negocio.InsertarCargo @nombre = 'Cajero'; 

-- Insercion con error (nombre duplicado)
EXEC negocio.InsertarCargo @nombre = 'Gerente'; 

-- Visualizacion
SELECT * FROM negocio.Cargo;

--Empleado

-- Inserción correcta
EXEC negocio.InsertarEmpleado 
    @nombre = 'Juan',
    @apellido = 'Pérez',
    @dni = 30123456,
    @domicilio = 'Calle Falsa 123',
    @emailPersonal = 'juan.perez@gmail.com',
    @emailEmpresa = 'juan.perez@empresa.com',
    @cuil = 20301234569,
    @idCargo = 1,
    @idSucursal = 1, 
    @turno = 'TM'; 

EXEC negocio.InsertarEmpleado 
    @nombre = 'María',
    @apellido = 'López',
    @dni = 40123456,
    @domicilio = 'Av. Libertador 456',
    @emailPersonal = 'maria.lopez@gmail.com',
    @emailEmpresa = 'maria.lopez@empresa.com',
    @cuil = 27401234563,
    @idCargo = 2, 
    @idSucursal = 2,
    @turno = 'Jornada completa';

-- Inserción con error (dni duplicado)
EXEC negocio.InsertarEmpleado 
    @nombre = 'Carlos',
    @apellido = 'Gómez',
    @dni = 30123456, 
    @domicilio = 'Av. Siempre Viva 742',
    @emailPersonal = 'carlos.gomez@gmail.com',
    @emailEmpresa = 'carlos.gomez@empresa.com',
    @cuil = 23333333333,
    @idCargo = 1,
    @idSucursal = 1,
    @turno = 'TT'; 

-- Insercion con error (idCargo inexistente)
EXEC negocio.InsertarEmpleado 
    @nombre = 'Ana',
    @apellido = 'Martínez',
    @dni = 50123456,
    @domicilio = 'Av. San Martín 789',
    @emailPersonal = 'ana.martinez@gmail.com',
    @emailEmpresa = 'ana.martinez@empresa.com',
    @cuil = 27501234568,
    @idCargo = 99, 
    @idSucursal = 1,
    @turno = 'TM'; 

--Insercion con error (idSucursal inexistente)
EXEC negocio.InsertarEmpleado 
    @nombre = 'Pedro',
    @apellido = 'Ramírez',
    @dni = 60123456,
    @domicilio = 'Calle Principal 321',
    @emailPersonal = 'pedro.ramirez@gmail.com',
    @emailEmpresa = 'pedro.ramirez@empresa.com',
    @cuil = 27601234569,
    @idCargo = 2,
    @idSucursal = 99, 
    @turno = 'TT'; 

-- Visualizacion
SELECT * FROM negocio.Empleado;

------SCHEMA VENTAS------

-- Insertar nuevos pagos
EXEC ventas.InsertarMedioPago @nombre = 'Efectivo';
EXEC ventas.InsertarMedioPago @nombre = 'Tarjeta de credito';
EXEC ventas.InsertarMedioPago @nombre = 'Tarjeta de debito';

-- Insertar clientes
EXEC ventas.InsertarCliente @nombre = 'Carlos', @apellido = 'Pérez', @dni = 30123456, @genero = 'Male', @tipoCliente = 'Normal';
EXEC ventas.InsertarCliente @nombre = 'María', @apellido = 'Gómez', @dni = 29123456, @genero = 'Female', @tipoCliente = 'Member';

-- Insertar ventas
EXEC ventas.InsertarVenta @idCliente = 1, @idEmpleado = 257020, @idSucursal = 1, @fecha = '2024-11-25', @hora = '10:30'
EXEC ventas.InsertarVenta @idCliente = 2, @idEmpleado = 257021, @idSucursal = 2, @fecha = '2024-11-26', @hora = '14:15'
EXEC ventas.InsertarVenta @idCliente = 1, @idEmpleado = 257020, @idSucursal = 1, @fecha = '2024-11-27', @hora = '16:45'

-- Insertar detalles de venta
EXEC ventas.InsertarDetalleVenta @idVenta = 1, @idProducto = 1, @cantidad = 2; -- Producto 1
EXEC ventas.InsertarDetalleVenta @idVenta = 1, @idProducto = 2, @cantidad = 1; -- Producto 2
EXEC ventas.InsertarDetalleVenta @idVenta = 2, @idProducto = 3, @cantidad = 4; -- Producto 3
EXEC ventas.InsertarDetalleVenta @idVenta = 3, @idProducto = 1, @cantidad = 1; -- Producto 1


-- Actualizamos los totales de cada venta
EXEC ventas.ActualizarTotalVenta @idVenta = 1;
EXEC ventas.ActualizarTotalVenta @idVenta = 2;
EXEC ventas.ActualizarTotalVenta @idVenta = 3;

-- Insertar tipos de factura
EXEC ventas.InsertarTipoFactura @sigla = 'A';
EXEC ventas.InsertarTipoFactura @sigla = 'B';

--Insertar configuracion
EXEC negocio.InsertarConfiguracion @cuit = NULL, @cuitGenerico = 20222222223, @cuilGenerico = 00000000000;

-- Insertar facturas
EXEC ventas.InsertarFactura 
    @idTipoFactura = 1,
	@idFactura = '123-45-678',
    @idVenta = 1,  
    @IVA = 0.21 

EXEC ventas.InsertarFactura 
    @idTipoFactura = 2, 
	@idFactura = '321-54-987',
    @idVenta = 2,   
    @IVA = 0.21


EXEC ventas.InsertarFactura 
    @idTipoFactura = 1,
	@idFactura = '122-99-678',
    @idVenta = 3, 
    @IVA = 0.10

-- Insertar pagos
EXEC ventas.InsertarPago
    @idFactura = 5,
    @idMedioPago = 2,
    @cod = 'PA001'; 

EXEC ventas.InsertarPago
    @idFactura = 6,
    @idMedioPago = 2,
    @cod = 'PA002'; 


--Verificamos los estados de las facturas
SELECT id, estado FROM ventas.Factura WHERE idVenta IN (1, 2, 3);

-- Insertar nota de crédito para la factura 1
EXEC ventas.InsertarNotaCredito @idFactura = 5, @fecha = '2024-11-28', @total = 500.00, @motivo = 'Devolucion de productos dañados';
EXEC ventas.InsertarDetalleNotaCredito @idNotaCredito = 1, @idDetalleVenta = 1, @cantidad = 1, @subtotal = 250.00; 



-- SELECT para validar las inserciones
-- Validar medio de pago
SELECT * FROM ventas.MedioPago;
SELECT * FROM ventas.Pago;

-- Validar clientes y ventas
SELECT * FROM ventas.Cliente;
SELECT * FROM ventas.Venta;

-- Validar detalle de ventas
SELECT * FROM ventas.DetalleVenta;

-- Validar facturas
SELECT * FROM ventas.Factura;

-- Validar notas de crédito
SELECT * FROM ventas.NotaCredito;
SELECT * FROM ventas.DetalleNotaCredito;



