USE Com2900G18
GO

DECLARE @rutaInfoComplementaria VARCHAR(256) = 'C:\TP\TP_integrador_Archivos\Informacion_complementaria.xlsx'
DECLARE @rutaCatalogoCsv VARCHAR(256) = 'C:\TP\TP_integrador_Archivos\Productos\catalogo.csv'
DECLARE @rutaCatalogoElectronica VARCHAR(256) = 'C:\TP\TP_integrador_Archivos\Productos\Electronic accessories.xlsx'
DECLARE @rutaCatalogoImportados VARCHAR(256) = 'C:\TP\TP_integrador_Archivos\Productos\Productos_importados.xlsx'
DECLARE @rutaVentas VARCHAR(256) = 'C:\TP\TP_integrador_Archivos\Ventas_registradas.csv'

EXEC importacion.InsertarDatosFaltantes
EXEC importacion.ImportarInformacionComplementaria @ruta=@rutaInfoComplementaria
EXEC importacion.ImportarCatalogoCsv @ruta=@rutaCatalogoCsv
EXEC importacion.ImportarAccesoriosElectronicos @ruta=@rutaCatalogoElectronica
EXEC importacion.ImportarProductosImportados @ruta=@rutaCatalogoImportados
EXEC importacion.ImportarVentas @ruta=@rutaVentas