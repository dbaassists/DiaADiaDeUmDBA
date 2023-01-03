USE SHV_TMP
GO

DECLARE @DB VARCHAR(100), @TABELA VARCHAR(100)
SET @DB = 'SHV_TMP'
SET @TABELA = 'TMP_TAB_CCS_MEDIDOR_ATIVO' -- TMP_FATO_CCS_CONTACONTRATO_ATIVOS TMP_TAB_CCS_MEDIDOR_ATIVO


SELECT		a.index_id, 
			name, 
			avg_fragmentation_in_percent  
FROM		sys.dm_db_index_physical_stats (DB_ID(@DB), OBJECT_ID(@TABELA), NULL, NULL, NULL) AS a  
INNER JOIN	sys.indexes AS b 
ON			a.object_id = b.object_id 
AND			a.index_id = b.index_id; 
GO

USE SHV_DW
GO

DECLARE @DB VARCHAR(100), @TABELA VARCHAR(100)
SET @DB = 'SHV_DW'
SET @TABELA = 'TB_SGI_CONTACONTRATO' -- TB_SGI_MEDIDOR TB_SGI_CONTACONTRATO TB_SGI_Instalacao


SELECT		a.index_id, 
			name, 
			avg_fragmentation_in_percent  
FROM		sys.dm_db_index_physical_stats (DB_ID(@DB), OBJECT_ID(@TABELA), NULL, NULL, NULL) AS a  
INNER JOIN	sys.indexes AS b 
ON			a.object_id = b.object_id 
AND			a.index_id = b.index_id; 




