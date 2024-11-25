/*
	Pautas generales para el desarrollo del TP

	• Documente las correcciones que haga indicando número de línea, contenido previo y
	contenido nuevo. Esto se cotejará para constatar que cumpla correctamente la
	consigna.
	• El código fuente no debe incluir referencias hardcodeadas a nombres o ubicaciones
	de archivo. Esto debe permitirse ser provisto por parámetro en la invocación. En el
	código de ejemplo el grupo decidirá dónde se ubicarían los archivos. Esto debe
	aparecer en comentarios del módulo.
	• Adicionalmente se requiere que el sistema sea capaz de generar un archivo XML
	detallando XXXXX. El mismo debe constar de los datos del XXXX.
	• Deberá presentar un archivo .sql con el script de creación de los objetos
	correspondientes. En el mismo incluya un comentario donde conste este enunciado,
	la fecha de entrega, número de grupo, nombre de la materia, nombres y DNI de los
	alumnos. El mismo archivo SQL debe permitir la generación de los objetos
	consignados en esta entrega (debe admitir una ejecución completa sin fallos).
	• Cada archivo SQL que contiene el código de creación de objetos debe comenzar su
	nombre con dos dígitos indicando el orden en que deben ejecutarse. Por ejemplo
	“00_CreacionSPImportacionCatalogo”. Estos archivos deben entregarse (como todos
	los scripts) dentro de un proyecto/solución. Todos deben estar en el repositorio git del
	grupo
	• También debe presentar un archivo .sql que consista en las invocaciones a los SP
	creados para generar la importación. Este archivo (que puede considerarse de testing)
	debe contener comentarios para indicar el orden de ejecución.
	• Entregar todo en un zip cuyo nombre sea Grupo_XX.zip mediante la sección de
	prácticas de MIEL. Solo uno de los miembros del grupo debe hacer la entrega.
	• Se recomienda revisar periódicamente el foro en Miel de la materia. En el mismo se
	informará el agregado de información, pautas o dudas respecto al TP
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

/*
	Entrega 3

	Cree la base de datos, entidades y relaciones. Incluya restricciones y claves. Deberá entregar
	un archivo .sql con el script completo de creación (debe funcionar si se lo ejecuta “tal cual” es
	entregado). Incluya comentarios para indicar qué hace cada módulo de código.
	Genere esquemas para organizar de forma lógica los componentes del sistema y aplique esto
	en la creación de objetos. NO use el esquema “dbo”.
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

CREATE SCHEMA importacion
GO

CREATE SCHEMA reportes
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
    nombre VARCHAR(100) NOT NULL UNIQUE,
    idLineaProd INT NOT NULL,
	idProveedor INT,
	precioUnitario DECIMAL(10,2) NOT NULL,
    cantidadPorUnidad VARCHAR(30),
	estado CHAR(1) DEFAULT 'A' CHECK(estado IN ('A','I')), -- La columna estado se coloca para un borrado lógico, donde A es Activo e I es Inactivo.
	catalogo CHAR(3) CHECK(catalogo = 'ELE' OR catalogo = 'IMP' OR catalogo = 'CSV')
    CONSTRAINT PK_Productos PRIMARY KEY (id),
    CONSTRAINT FK_LineaProd_Prod FOREIGN KEY (idLineaProd) REFERENCES productos.LineaProducto(id),
    CONSTRAINT FK_Proveedor_Prod FOREIGN KEY (idProveedor) REFERENCES productos.Proveedor(id),
);
GO

-- SCHEMA negocio

CREATE TABLE negocio.Sucursal 
(
    id INT IDENTITY(1,1),
	nombre VARCHAR (50),
    direccion VARCHAR (100) UNIQUE NOT NULL,
    horario VARCHAR(100) NOT NULL,
    telefono CHAR(9) NOT NULL,
	ciudad VARCHAR (50),
    CONSTRAINT PK_Sucursal PRIMARY KEY (id)
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
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    dni INT UNIQUE NOT NULL,
    domicilio VARCHAR (100) NOT NULL,
    emailPersonal VARCHAR(100)NOT NULL,
    emailEmpresa VARCHAR(100) NOT NULL,
    cuil BIGINT,
    idCargo INT NOT NULL,
    idSucursal INT NOT NULL,
    turno VARCHAR(20) NOT NULL CHECK (turno = 'TM' OR turno = 'TT' OR turno = 'Jornada completa'),
    CONSTRAINT PK_Empleado PRIMARY KEY (id),
    CONSTRAINT FK_Cargo_Empl FOREIGN KEY (idCargo) REFERENCES negocio.Cargo(id),
    CONSTRAINT FK_Sucursal_Empl FOREIGN KEY (idSucursal) REFERENCES negocio.Sucursal(id)
);
GO


--SCHEMA ventas
CREATE TABLE ventas.MedioPago (
    id INT IDENTITY(1,1),
    nombre VARCHAR(50) UNIQUE NOT NULL,
    reemplazaPor VARCHAR (50) NULL,
    CONSTRAINT PK_MedioPago PRIMARY KEY (id)
);
GO

CREATE TABLE ventas.Pago (
    id INT IDENTITY(1,1),
    cod VARCHAR(50) UNIQUE NOT NULL, --cod hace referencia al identificador de pago
    montoTotal DECIMAL(10,2),
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

CREATE TABLE ventas.Cliente (
    id INT IDENTITY(1,1),
    nombre VARCHAR(50) NOT NULL,
	apellido VARCHAR(50) NOT NULL,
	dni INT NOT NULL,
	genero VARCHAR(20) NOT NULL CHECK (genero = 'Male' OR genero = 'Female'),
	tipoCliente VARCHAR(20) NOT NULL CHECK (tipoCliente = 'Member' OR tipoCliente = 'Normal'),
    CONSTRAINT PK_Cliente PRIMARY KEY (id)
);
GO

CREATE TABLE ventas.Venta (
	id INT IDENTITY(1,1),
	idCliente INT NOT NULL,
	idEmpleado INT NOT NULL,
	idSucursal INT NOT NULL,
	fecha DATE,
	hora TIME,
	totalSinIVA DECIMAL(10,2),
	CONSTRAINT PK_Venta PRIMARY KEY (id),
	CONSTRAINT FK_Venta_Cliente FOREIGN KEY (idCliente) REFERENCES ventas.Cliente (id),
	CONSTRAINT FK_Venta_Empleado FOREIGN KEY (idEmpleado) REFERENCES negocio.Empleado (id),
	CONSTRAINT FK_Venta_Sucursal FOREIGN KEY (idSucursal) REFERENCES negocio.Sucursal (id)
);
GO

CREATE TABLE ventas.DetalleVenta (
	id INT IDENTITY(1,1),
	idVenta INT NOT NULL,
	idProducto INT NOT NULL,
	cantidad INT NOT NULL,
	precioUnitario DECIMAL (10,2) NOT NULL,
	subtotal DECIMAL(10,2) NOT NULL,
	CONSTRAINT PK_DetalleVenta PRIMARY KEY (id),
	CONSTRAINT FK_DetalleVenta_Venta FOREIGN KEY (idVenta) REFERENCES ventas.Venta (id),
	CONSTRAINT FK_DetalleVenta_Producto FOREIGN KEY (idProducto) REFERENCES productos.Producto (id)
);
GO

CREATE TABLE ventas.Factura (
    id INT IDENTITY(1,1),
	idTipoFactura INT NOT NULL,
	idVenta INT UNIQUE NOT NULL,
	CUIT VARCHAR(10) NOT NULL,
	total DECIMAL(10,2) NOT NULL,
    IVA DECIMAL(3,2) NOT NULL,
	totalConIVA DECIMAL(10,2),
	idPago INT,
	estado VARCHAR(20) DEFAULT 'Pendiente' CHECK(estado = 'Pendiente' OR estado = 'Pagada' OR estado = 'Anulada')
    CONSTRAINT PK_Factura PRIMARY KEY (id),
	CONSTRAINT FK_Factura_TipoFactura FOREIGN KEY (idTipoFactura) REFERENCES ventas.TipoFactura (id),
    CONSTRAINT FK_Factura_Venta FOREIGN KEY (idVenta) REFERENCES ventas.Venta (id),
    CONSTRAINT FK_Factura_Pago FOREIGN KEY (idPago) REFERENCES ventas.Pago (id)
);
GO

CREATE TABLE ventas.NotaCredito (
	id INT IDENTITY(1,1),
	idFactura INT UNIQUE NOT NULL,
	fecha DATE NOT NULL,
	total DECIMAL(10,2),
	motivo VARCHAR(100),
	CONSTRAINT PK_NotaCredito PRIMARY KEY (id),
	CONSTRAINT FK_NotaCredito_Factura FOREIGN KEY (idFactura) REFERENCES ventas.Factura (id)
);
GO

CREATE TABLE ventas.DetalleNotaCredito (
	id INT IDENTITY(1,1),
	idNotaCredito INT UNIQUE NOT NULL,
	cantidad INT NOT NULL,
	subtotal DECIMAL(10,2) NOT NULL,
	CONSTRAINT PK_DetalleNotaCredito PRIMARY KEY (id),
	CONSTRAINT FK_DetalleNotaCredito_idNotaCredito FOREIGN KEY (idNotaCredito) REFERENCES ventas.NotaCredito(id)
);
GO

-- SCHEMA importacion

CREATE TABLE importacion.ErroresCatalogoProductosImportados(
	productId INT IDENTITY(1,1) PRIMARY KEY,
	IdProducto VARCHAR(30),
	NombreProducto VARCHAR(50),
	Proveedor VARCHAR(50),
	Categoría VARCHAR(30),
	CantidadPorUnidad VARCHAR(30),
	PrecioUnidad VARCHAR(30),
	fechaHoraError DATETIME
);

CREATE TABLE importacion.ErroresCatalogoAccesoriosElectronicos(
	productId INT IDENTITY(1,1) PRIMARY KEY,
	Product VARCHAR(30),
	PrecioUnitarioEnDolares VARCHAR(50),
	fechaHoraError DATETIME
);

CREATE TABLE importacion.ErroresCatalogoCsv (
	productId INT IDENTITY(1,1) PRIMARY KEY,
	id VARCHAR(30),
	category VARCHAR(50),
	name VARCHAR(100),
	price VARCHAR(30),
	reference_price VARCHAR(30),
	reference_unit VARCHAR(30),
	date VARCHAR(30),
	fechaHoraError DATETIME
);
