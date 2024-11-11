/*
	Pautas generales para el desarrollo del TP

	� Documente las correcciones que haga indicando n�mero de l�nea, contenido previo y
	contenido nuevo. Esto se cotejar� para constatar que cumpla correctamente la
	consigna.
	� El c�digo fuente no debe incluir referencias hardcodeadas a nombres o ubicaciones
	de archivo. Esto debe permitirse ser provisto por par�metro en la invocaci�n. En el
	c�digo de ejemplo el grupo decidir� d�nde se ubicar�an los archivos. Esto debe
	aparecer en comentarios del m�dulo.
	� Adicionalmente se requiere que el sistema sea capaz de generar un archivo XML
	detallando XXXXX. El mismo debe constar de los datos del XXXX.
	� Deber� presentar un archivo .sql con el script de creaci�n de los objetos
	correspondientes. En el mismo incluya un comentario donde conste este enunciado,
	la fecha de entrega, n�mero de grupo, nombre de la materia, nombres y DNI de los
	alumnos. El mismo archivo SQL debe permitir la generaci�n de los objetos
	consignados en esta entrega (debe admitir una ejecuci�n completa sin fallos).
	� Cada archivo SQL que contiene el c�digo de creaci�n de objetos debe comenzar su
	nombre con dos d�gitos indicando el orden en que deben ejecutarse. Por ejemplo
	�00_CreacionSPImportacionCatalogo�. Estos archivos deben entregarse (como todos
	los scripts) dentro de un proyecto/soluci�n. Todos deben estar en el repositorio git del
	grupo
	� Tambi�n debe presentar un archivo .sql que consista en las invocaciones a los SP
	creados para generar la importaci�n. Este archivo (que puede considerarse de testing)
	debe contener comentarios para indicar el orden de ejecuci�n.
	� Entregar todo en un zip cuyo nombre sea Grupo_XX.zip mediante la secci�n de
	pr�cticas de MIEL. Solo uno de los miembros del grupo debe hacer la entrega.
	� Se recomienda revisar peri�dicamente el foro en Miel de la materia. En el mismo se
	informar� el agregado de informaci�n, pautas o dudas respecto al TP
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

	Cree la base de datos, entidades y relaciones. Incluya restricciones y claves. Deber� entregar
	un archivo .sql con el script completo de creaci�n (debe funcionar si se lo ejecuta �tal cual� es
	entregado). Incluya comentarios para indicar qu� hace cada m�dulo de c�digo.
	Genere esquemas para organizar de forma l�gica los componentes del sistema y aplique esto
	en la creaci�n de objetos. NO use el esquema �dbo�.
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
    nombre VARCHAR(50) NOT NULL UNIQUE,
    precioUnitario DECIMAL(10,2) NOT NULL,
    cantidadPorUnidad VARCHAR(30),
	idLineaProd INT NOT NULL,
    idProveedor INT NOT NULL,
	estado CHAR(1) DEFAULT 'A' CHECK(estado IN ('A','I')), -- La columna estado se coloca para un borrado l�gico, donde A es Activo e I es Inactivo.
	catalogo CHAR(3) NOT NULL, CHECK(catalogo IN('IMP','ELE','CSV')),
    CONSTRAINT PK_Productos PRIMARY KEY (id),
    CONSTRAINT FK_LineaProd_Prod FOREIGN KEY (idLineaProd) REFERENCES productos.LineaProducto(id),
    CONSTRAINT FK_Proveedor_Prod FOREIGN KEY (idProveedor) REFERENCES productos.Proveedor(id),
);
GO

-- SCHEMA negocio

CREATE TABLE negocio.Provincia
(
    id INT IDENTITY(1,1),
    nombre VARCHAR(50) UNIQUE NOT NULL,
    CONSTRAINT PK_Provincia PRIMARY KEY (id)
);
GO

CREATE TABLE negocio.Ciudad
(
    id INT IDENTITY(1,1),
    nombre VARCHAR(50) UNIQUE NOT NULL,
	reemplazaPor VARCHAR (50) NULL,
    idProvincia INT NOT NULL,
    CONSTRAINT PK_Ciudad PRIMARY KEY (id),
    CONSTRAINT FK_Ciudad_Provincia FOREIGN KEY (idProvincia) REFERENCES negocio.Provincia(id)
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
	genero VARCHAR(10) NOT NULL CHECK (genero = 'Male' OR genero = 'Female'),
	fecha DATE NOT NULL,
    hora TIME NOT NULL,
	total DECIMAL(10,2) NOT NULL,
    idPago INT UNIQUE NOT NULL,
	idEmpleado INT NOT NULL,
    idSucursal INT NOT NULL,
    CONSTRAINT PK_Factura PRIMARY KEY (id),
	CONSTRAINT FK_Factura_TipoFactura FOREIGN KEY (idTipoFactura) REFERENCES ventas.TipoFactura (id),
    CONSTRAINT FK_Factura_TipoCliente FOREIGN KEY (idTipoCliente) REFERENCES ventas.TipoCliente (id),
    CONSTRAINT FK_Factura_Pago FOREIGN KEY (idPago) REFERENCES ventas.Pago (id),
	CONSTRAINT FK_Factura_Empleado FOREIGN KEY (idEmpleado) REFERENCES negocio.Empleado(id),
	CONSTRAINT FK_Factura_idSucursal FOREIGN KEY (idSucursal) REFERENCES negocio.Sucursal (id)
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
	subtotal DECIMAL(10,2) NOT NULL,
	CONSTRAINT PK_DetalleNotaCredito PRIMARY KEY (id),
	CONSTRAINT FK_DetalleNotaCredito_idNotaCredito FOREIGN KEY (idNotaCredito) REFERENCES ventas.NotaCredito(id)
)
GO

use master
go
drop database Com2900G18
