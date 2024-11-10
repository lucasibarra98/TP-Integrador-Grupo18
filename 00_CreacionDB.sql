/*
Entrega 3
Luego de decidirse por un motor de base de datos relacional, llegó el momento de generar la
base de datos.
Deberá instalar el DMBS y documentar el proceso. No incluya capturas de pantalla. Detalle
las configuraciones aplicadas (ubicación de archivos, memoria asignada, seguridad, puertos,
etc.) en un documento como el que le entregaría al DBA.
Cree la base de datos, entidades y relaciones. Incluya restricciones y claves. Deberá entregar
un archivo .sql con el script completo de creación (debe funcionar si se lo ejecuta “tal cual” es
entregado). Incluya comentarios para indicar qué hace cada módulo de código.
Genere store procedures para manejar la inserción, modificado, borrado (si corresponde,
también debe decidir si determinadas entidades solo admitirán borrado lógico) de cada tabla.
Los nombres de los store procedures NO deben comenzar con “SP”.
Genere esquemas para organizar de forma lógica los componentes del sistema y aplique esto
en la creación de objetos. NO use el esquema “dbo”.
*/

/*
Fecha de Entrega: 12/11/24
Grupo 18
Bases de Datos Aplicadas
Integrantes:
	Hossein, Santiago - 43.872.682
	Mallet, Fernando - 39.770.041
	Ibarra, Lucas - 41.332.340
*/



---CREAMOS BASE 
CREATE DATABASE Com2900G18;
GO

USE Com2900G18;
GO

---CREAMOS SCHEMAS
CREATE SCHEMA ventas;
GO

CREATE SCHEMA productos;
GO

CREATE SCHEMA negocio;
GO

									-----------TABLAS-----------
-- SCHEMA productos
CREATE TABLE productos.LineaProducto
(
    id INT IDENTITY(1,1),
    nombre VARCHAR(40) UNIQUE NOT NULL,
    CONSTRAINT PK_LineaProd PRIMARY KEY (id)
);
GO

CREATE TABLE productos.Categoria
(
    id INT IDENTITY(1,1),
    nombre VARCHAR(50) UNIQUE NOT NULL,
    idLineaProd INT NOT NULL,
    CONSTRAINT PK_Categoria PRIMARY KEY (id),
    CONSTRAINT FK_LineaProd_Cat FOREIGN KEY (idLineaProd) REFERENCES productos.LineaProducto(id)
);
GO

CREATE TABLE productos.Proveedor
(
    id INT IDENTITY(1,1),
    nombre VARCHAR(50) UNIQUE NOT NULL,
    CONSTRAINT PK_Proveedor PRIMARY KEY (id)
);
GO

CREATE TABLE productos.Producto
(
    id INT IDENTITY(1,1),
    nombre VARCHAR(50) NOT NULL,
    precioUnitario DECIMAL(10,2) NOT NULL,
    cantidadPorUnidad VARCHAR(30),
	idLineaProd INT NOT NULL,
    idProveedor INT NOT NULL,
	estado CHAR(1) DEFAULT 'A' CHECK(estado IN ('A','I')), -- La columna estado se coloca para un borrado lógico, donde A es Activo e I es Inactivo.
    CONSTRAINT PK_Productos PRIMARY KEY (id),
    CONSTRAINT FK_LineaProd_Prod FOREIGN KEY (idLineaProd) REFERENCES productos.LineaProducto(id),
    CONSTRAINT FK_Proveedor_Prod FOREIGN KEY (idProveedor) REFERENCES productos.Proveedor(id),
	CONSTRAINT U_Productos UNIQUE (nombre, idProveedor) -- Estamos suponiendo que un mismo producto puede ser distribuido por mas de un proveedor.
);
GO

-- SCHEMA negocio
CREATE TABLE negocio.Ciudad
(
    id INT IDENTITY(1,1),
    nombre VARCHAR(50) UNIQUE NOT NULL,
    CONSTRAINT PK_Ciudad PRIMARY KEY (id)
);
GO

CREATE TABLE negocio.Domicilio
(
    id INT IDENTITY(1,1),
    calle VARCHAR(50) NOT NULL,
    numero INT NOT NULL,
    idCiudad INT NOT NULL,
    codigoPostal VARCHAR(8) NOT NULL,
    CONSTRAINT PK_Domicilio PRIMARY KEY (id),
    CONSTRAINT FK_Ciudad_Dom FOREIGN KEY (idCiudad) REFERENCES negocio.Ciudad(id),
	CONSTRAINT U_Domicilio UNIQUE (calle, numero, idCiudad) 
);
GO

CREATE TABLE negocio.Sucursal 
(
    id INT IDENTITY(1,1),
    idDomicilio INT UNIQUE NOT NULL,
    horario VARCHAR(100) NOT NULL,
    telefono CHAR(9) NOT NULL,
    CONSTRAINT PK_Sucursal PRIMARY KEY (id),
    CONSTRAINT FK_Domicilio_Suc FOREIGN KEY (idDomicilio) REFERENCES negocio.Domicilio(id)
);
GO

CREATE TABLE negocio.Cargo
(
    id INT IDENTITY(1,1),
    nombre VARCHAR(30) UNIQUE NOT NULL,
    CONSTRAINT PK_Cargo PRIMARY KEY (id)
);
GO

CREATE TABLE negocio.Empleado
(
    id INT IDENTITY(257020,1),
    nombre VARCHAR(20) NOT NULL,
    apellido VARCHAR(20) NOT NULL,
    dni INT UNIQUE NOT NULL,
    idDomicilio INT NOT NULL,
    emailPersonal VARCHAR(50)NOT NULL,
    emailEmpresa VARCHAR(50) NOT NULL,
    cuil BIGINT NOT NULL,
    idCargo INT NOT NULL,
    idSucursal INT NOT NULL,
    turno VARCHAR(20) NOT NULL,
    CONSTRAINT PK_Empleado PRIMARY KEY (id),
    CONSTRAINT FK_Domicilio_Empl FOREIGN KEY (idDomicilio) REFERENCES negocio.Domicilio(id),
    CONSTRAINT FK_Cargo_Empl FOREIGN KEY (idCargo) REFERENCES negocio.Cargo(id),
    CONSTRAINT FK_Sucursal_Empl FOREIGN KEY (idSucursal) REFERENCES negocio.Sucursal(id)
);
GO


--SCHEMA ventas
CREATE TABLE ventas.MedioPago (
    id INT IDENTITY(1,1),
    nombre VARCHAR(50) UNIQUE NOT NULL,
    CONSTRAINT PK_MedioPago PRIMARY KEY (id)
);
GO

CREATE TABLE ventas.Pago (
    id INT IDENTITY(1,1),
    cod VARCHAR(50) UNIQUE NOT NULL, --cod hace referencia al identificador de pago
    montoTotal DECIMAL(10,2) NOT NULL,
    idMedioPago INT NOT NULL,
    CONSTRAINT PK_Pago PRIMARY KEY (id),
    CONSTRAINT FK_Pago_MedioPago FOREIGN KEY (idMedioPago) REFERENCES ventas.MedioPago (id)
);
GO

CREATE TABLE ventas.TipoFactura (
    id INT IDENTITY(1,1),
    sigla CHAR(1) UNIQUE NOT NULL,
    CONSTRAINT PK_TipoFactura PRIMARY KEY (id)
);
GO

CREATE TABLE ventas.TipoCliente (
    id INT IDENTITY(1,1),
    nombre VARCHAR(50) UNIQUE NOT NULL,
    CONSTRAINT PK_TipoCliente PRIMARY KEY (id)
);
GO

CREATE TABLE ventas.Factura (
    id INT IDENTITY(1,1),
	idTipoFactura INT NOT NULL,
	idTipoCliente INT NOT NULL,
	genero VARCHAR(10) NOT NULL CHECK genero = 'Male' OR genero = 'Female',
	fecha DATE NOT NULL,
    hora TIME NOT NULL,
	total DECIMAL(10,2) NOT NULL,
    idPago INT UNIQUE NOT NULL,
	idEmpleado INT NOT NULL,
    idSucursal INT NOT NULL,
    CONSTRAINT PK_Factura PRIMARY KEY (id),
	CONSTRAINT FK_Factura_TipoFactura FOREIGN KEY (idTipoFactura) REFERENCES ventas.TipoFactura (id).
    CONSTRAINT FK_Factura_TipoCliente FOREIGN KEY (idTipoCliente) REFERENCES ventas.TipoCliente (id),
    CONSTRAINT FK_Factura_Pago FOREIGN KEY (idPago) REFERENCES ventas.Pago (id),
	CONSTRAINT FK_Factura_Empleado FOREIGN KEY (idEmpleado) REFERENCES negocio.Empleado(id),
	CONSTRAINT FK_Factura_idSucursal FOREIGN KEY (idSucursal) REFERENCES ventas.Sucursal (id)
);
GO

CREATE TABLE ventas.DetalleFactura(
	id INT IDENTITY(1,1),
	idFactura INT NOT NULL,
	idProducto INT NOT NULL,
	cantidad INT NOT NULL,
	precioUnitario INT NOT NULL,
	subtotal DECIMAL(10,2),
	CONSTRAINT PK_DetallFactura PRIMARY KEY (id),
	CONSTRAINT FK_DetalleFactura_Factura FOREIGN KEY (idFactura) REFERENCES ventas.Factura (id),
	CONSTRAINT FK_Factura_Producto FOREIGN KEY (idProducto) REFERENCES productos.Producto(id)
)
GO

CREATE TABLE ventas.NotaCredito (
	id INT IDENTITY(1,1),
	idFactura INT UNIQUE NOT NULL,
	fecha DATE NOT NULL,
	total DECIMAL(10,2),
	motivo VARCHAR(100),
	CONSTRAINT PK_NotaCredito PRIMARY KEY (id)
)
GO

CREATE TABLE ventas.DetalleNotaCredito (
	id INT IDENTITY(1,1),
	idNotaCredito INT UNIQUE NOT NULL,
	idDetalleFactura INT NOT NULL,
	cantidad INT NOT NULL,
	precioUnitario DECIMAL(10,2) NOT NULL,
	subtotal DECIMAL(10,2) NOT NULL,
	CONSTRAINT PK_DetalleNotaCredito PRIMARY KEY (id),
	CONSTRAINT FK_DetalleNotaCredito_idNotaCredito FOREIGN KEY (idNotaCredito) REFERENCES ventas.NotaCredito(id)
)
GO
