USE Com2900G18
GO

--Modificamos línea de producto
EXEC productos.ModificarLineaProducto @id = 1, @nombre = 'Electrónica General'; -- Mcorrecto
EXEC productos.ModificarLineaProducto @id = 99, @nombre = 'Nuevo Nombre'; -- Error: Línea de producto inexistente

--Modificamos categoría
EXEC productos.ModificarCategoria @id = 1, @nombre = 'Pequeños Electrodomésticos', @idLineaProd = 1; -- correcto
EXEC productos.ModificarCategoria @id = 99, @nombre = 'Categoría Inexistente', @idLineaProd = 1; -- Error: Categoría inexistente
EXEC productos.ModificarCategoria @id = 2, @nombre = 'Lavarropas Grandes', @idLineaProd = 99; -- Error: Línea de producto inexistente

--Modificamos proveedor
EXEC productos.ModificarProveedor @id = 1, @nombre = 'Samsung Electronics'; -- correcto
EXEC productos.ModificarProveedor @id = 99, @nombre = 'Proveedor Inexistente'; -- Error: Proveedor inexistente

--Modificamos producto
EXEC productos.ModificarProducto 
    @id = 1, 
    @nombre = 'Galaxy S24', 
    @idLineaProd = 1, 
    @idProveedor = 1, 
    @precioUnitario = 1300.00, 
    @cantidadPorUnidad = 'Unidad', 
    @catalogo = 'IMP'; --correcto

EXEC productos.ModificarProducto 
    @id = 99, 
    @nombre = 'Producto Inexistente', 
    @idLineaProd = 1, 
    @idProveedor = 1, 
    @precioUnitario = 999.99, 
    @cantidadPorUnidad = 'Unidad', 
    @catalogo = 'ELE'; -- Error: Producto inexistente

EXEC productos.ModificarProducto 
    @id = 1, 
    @nombre = 'Galaxy S24', 
    @idLineaProd = 99, 
    @idProveedor = 1, 
    @precioUnitario = 999.99, 
    @cantidadPorUnidad = 'Unidad', 
    @catalogo = 'ELE'; -- Error: Línea de producto inexistente

--Modificamos sucursal
EXEC negocio.ModificarSucursal 
    @id = 1, 
    @nombre = 'Sucursal Buenos Aires Centro', 
    @direccion = 'Av. Corrientes 4321', 
    @horario = '09:00-18:00', 
    @telefono = '112233445', 
    @ciudad = 'CABA'; -- correcto

EXEC negocio.ModificarSucursal 
    @id = 99, 
    @nombre = 'Sucursal Inexistente', 
    @direccion = 'Dirección Inexistente', 
    @horario = '09:00-18:00', 
    @telefono = '000000000', 
    @ciudad = 'CABA'; -- Error: Sucursal inexistente

--Modificamos cargo
EXEC negocio.ModificarCargo @id = 1, @nombre = 'Director General'; -- correcto
EXEC negocio.ModificarCargo @id = 99, @nombre = 'Cargo Inexistente'; -- Error: Cargo inexistente

--Modificamos empleado
EXEC negocio.ModificarEmpleado 
    @id = 257020, 
    @nombre = 'Juan Carlos', 
    @apellido = 'Pérez', 
    @dni = 30567890, 
    @domicilio = 'Calle Nueva 789', 
    @emailPersonal = 'juancarlos.perez@gmail.com', 
    @emailEmpresa = 'juancarlos.perez@empresa.com', 
    @cuil = 20305678909, 
    @idCargo = 2, 
    @idSucursal = 2, 
    @turno = 'TT'; -- correcto

EXEC negocio.ModificarEmpleado 
    @id = 999999, 
    @nombre = 'Empleado Inexistente', 
    @apellido = 'Prueba', 
    @dni = 12345678, 
    @domicilio = 'Dirección Falsa', 
    @emailPersonal = 'email@falso.com', 
    @emailEmpresa = 'empresa@falso.com', 
    @cuil = 20123456789, 
    @idCargo = 1, 
    @idSucursal = 1, 
    @turno = 'Jornada completa'; -- Error: Empleado inexistente

--Modificamos medio de pago
EXEC ventas.ModificarMedioPago @id = 1, @nombre = 'Efectivo Modificado', @reemplazaPor = NULL; --correcto
EXEC ventas.ModificarMedioPago @id = 99, @nombre = 'Medio de Pago Inexistente', @reemplazaPor = NULL; -- Error: Medio de pago inexistente

--Modificamos cliente
EXEC ventas.ModificarCliente 
    @id = 1, 
    @nombre = 'Carlos Alberto', 
    @apellido = 'Pérez', 
    @dni = 30123456, 
    @genero = 'Male', 
    @tipoCliente = 'VIP'; -- correcto

EXEC ventas.ModificarCliente 
    @id = 99, 
    @nombre = 'Cliente Inexistente', 
    @apellido = 'Prueba', 
    @dni = 12345678, 
    @genero = 'Female', 
    @tipoCliente = 'Normal'; -- Error: Cliente inexistente

--Validamos productos
SELECT * FROM productos.LineaProducto;
SELECT * FROM productos.Categoria;
SELECT * FROM productos.Proveedor;
SELECT * FROM productos.Producto;

--Validamos sucursales, cargos y empleados
SELECT * FROM negocio.Sucursal;
SELECT * FROM negocio.Cargo;
SELECT * FROM negocio.Empleado;

--Validamos ventas
SELECT * FROM ventas.MedioPago;
SELECT * FROM ventas.Cliente;

