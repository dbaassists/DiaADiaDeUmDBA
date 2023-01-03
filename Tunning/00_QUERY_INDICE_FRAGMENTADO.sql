
SELECT OBJECT_NAME(ind.OBJECT_ID) AS TableName
,ind.name AS IndexName, indexstats.index_type_desc AS IndexType,
indexstats.avg_fragmentation_in_percent, indexstats.page_count
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) indexstats
INNER JOIN sys.indexes ind
ON ind.object_id = indexstats.object_id
AND ind.index_id = indexstats.index_id

WHERE 1=1 
AND indexstats.avg_fragmentation_in_percent > 74
--AND OBJECT_NAME(ind.OBJECT_ID) = 'TB_TransacaoPedido'
--indexstats.index_type_desc NOT IN('HEAP') --Desconsidera HEAP
--AND indexstats.page_count > 1000--Desconsidera índices com menos de 1000 páginas
ORDER BY indexstats.avg_fragmentation_in_percent DESC