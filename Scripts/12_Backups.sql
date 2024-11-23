USE Com2900G18;
GO

ALTER DATABASE Com2900G18
SET RECOVERY FULL;
GO

-- Backup completo
--INIT: Sobrescribe cualquier archivo existente en la ubicaci�n especificada. Permite conservar historico


BACKUP DATABASE Com2900G18 TO DISK = 'D:\Documentos\UNLaM\Materias 2024\Base de Datos Aplicada\TP-Integrador-Grupo18\Backups\AuroraSA_BackupCompleto.bak'
WITH INIT, NAME = 'Respaldo Completo'; 
GO

--Backup Diferencial

BACKUP DATABASE Com2900G18 TO DISK = 'D:\Documentos\UNLaM\Materias 2024\Base de Datos Aplicada\TP-Integrador-Grupo18\Backups\AuroraSA_BackupDiferencial.bak'
WITH DIFFERENTIAL, INIT, NAME = 'Respaldo Diferencial';
GO

--Backup de Transacciones

BACKUP LOG Com2900G18 TO DISK = 'D:\Documentos\UNLaM\Materias 2024\Base de Datos Aplicada\TP-Integrador-Grupo18\Backups\AuroraSA_BackupTransaccional.trn'
WITH INIT, NAME = 'Respaldo de Transacciones';
GO
