USE SGBODS
GO

SELECT			O.name Tabela
				, I.name Indice
				, i.type_desc TipoIndice 
				, p.data_compression_desc  
FROM			SYS.partitions P WITH(NOLOCK)

INNER JOIN		SYS.indexes I WITH(NOLOCK)
ON				P.object_id = I.object_id
AND				P.index_id = I.index_id

INNER JOIN		SYS.objects O WITH(NOLOCK)
ON				P.object_id = O.object_id

WHERE			1=1
and				P.data_compression > 0

ORDER BY		Tabela