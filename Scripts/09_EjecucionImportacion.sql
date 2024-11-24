USE Com2900G18
GO

DECLARE @rutaInfoComplementaria VARCHAR(256)
DECLARE @rutaCatalogoCsv VARCHAR(256)
DECLARE @rutaCatalogoElectronica VARCHAR(256)
DECLARE @rutaCatalogoImportados VARCHAR(256)

SET @rutaInfoComplementaria = 'C:\TP\TP_integrador_Archivos\Informacion_complementaria.xlsx'
SET @rutaCatalogoCsv = 'C:\TP\TP_integrador_Archivos\Productos\catalogo.csv'
SET @rutaCatalogoElectronica = 'C:\TP\TP_integrador_Archivos\Productos\Electronic accessories.xlsx'
SET @rutaCatalogoImportados = 'C:\TP\TP_integrador_Archivos\Productos\Productos_importados.xlsx'

EXEC importacion.ImportarInformacionComplementaria @ruta=@rutaInfoComplementaria
EXEC importacion.ImportarCatalogoCsv @ruta=@rutaCatalogoCsv
EXEC importacion.ImportarAccesoriosElectronicos @ruta=@rutaCatalogoElectronica
EXEC importacion.ImportarProductosImportados @ruta=@rutaCatalogoImportados