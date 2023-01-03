use SGBods
GO

drop table #temp
/*

SELECT * FROM SYSINDEXES WHERE NAME = 'Ak_CodSilo'
 SELECT * FROM SYS.OBJECTS WHERE NAME = 'Ak_CodParceiroNegocio'
select * from sys.dm_db_index_physical_stats(DB_ID(), null, null, null, null) as IPS
*/
--select top 10 * from sys.indexes _columns 
-- SELECT * from sys.dm_db_index_physical_stats(DB_ID(), null, null, null, null) as IPS
select 

OBJECT_SCHEMA_NAME(IPS.[object_id])+'.'+object_name(IPS.[object_id]) as [Tabela_Indice]
,ips.index_id Seq_Index
,si.name Nome_Index
, case	when  so.type_desc = 'PRIMARY_KEY_CONSTRAINT' then 'PK'
		when  so.type_desc = 'UNIQUE_CONSTRAINT' then 'UQ'
		when  so.type_desc IS NULL then 'IX'
END Tipo_Constraint
,' (' + ISNULL(SUBSTRING(c.[indexed], 0, LEN(c.[indexed])), '') + 
(CASE WHEN c.[included] IS NOT NULL 
THEN ') INCLUDE (' + ISNULL(SUBSTRING(c.[included], 0, LEN(c.[included])), '') + ')' ELSE ')' END) [Composicao_Indice]
, ips.index_type_desc Tipo_Index
, ips.avg_fragmentation_in_percent [%_Fragmentacao]
, ips.avg_fragment_size_in_pages
, ips.fragment_count
, ips.page_count
, ips.alloc_unit_type_desc
, si.rowcnt

into #temp
from sys.dm_db_index_physical_stats(DB_ID(), null, null, null, null) as IPS
inner join sysindexes as SI with (nolock) on IPS.[object_id] = SI.[id] and IPS.index_id = SI.indid
inner join sys.tables as T with (nolock) on IPS.[object_id] = T.[object_id]
left JOIN SYS.objects so with(nolock) on si.id = so.parent_object_id and si.name = so.name

-- Relação de colunas que formam o índice
CROSS APPLY (
    SELECT (
        SELECT c.name + ', '
        FROM sys.columns c
        INNER JOIN sys.index_columns ic
        ON c.[object_id] = ic.[object_id]
        AND c.[column_id] = ic.[column_id]
        WHERE t.[object_id] = c.[object_id]
        AND ic.[index_id] = SI.[indid]
        AND ic.[is_included_column] = 0
        ORDER BY [key_ordinal]
        FOR XML PATH('')
    ) AS [indexed]
    ,(
        SELECT c.name + ', '
        FROM sys.columns c
        INNER JOIN sys.index_columns ic
        ON c.[object_id] = ic.[object_id]
        AND c.[column_id] = ic.[column_id]
        WHERE t.[object_id] = c.[object_id]
        AND ic.[index_id] = si.[indid]
        AND ic.[is_included_column] = 1
        ORDER BY [key_ordinal]
        FOR XML PATH('')
    ) AS [included]
) AS c



where T.is_ms_shipped = 0
and IPS.avg_fragmentation_in_percent < 10 
and IPS.page_count>25 
--and IPS.index_type_desc<>'heap' 
and IPS.index_level=0 
order by [Tabela_Indice] ASC , [Composicao_Indice] ASC --, [%_Fragmentacao] desc

--select * from #temp

DECLARE @TableName VARCHAR(255)
DECLARE @sql NVARCHAR(500)
DECLARE @fillfactor INT
SET @fillfactor = 70
DECLARE TableCursor CURSOR FOR
select Tabela_Indice  from (
SELECT Tabela_Indice , rowcnt FROM #temp group by Tabela_Indice , rowcnt  
) a
order by rowcnt asc
OPEN TableCursor
FETCH NEXT FROM TableCursor INTO @TableName
WHILE @@FETCH_STATUS = 0
BEGIN
	SET @sql = 'ALTER INDEX ALL ON ' + @TableName +' REBUILD WITH (FILLFACTOR = ' + CONVERT(VARCHAR(3),@fillfactor) + ')'
	print (@sql)
FETCH NEXT FROM TableCursor INTO @TableName
END
CLOSE TableCursor
DEALLOCATE TableCursor

--drop table #temp 
-- select * from #temp order by 1 desc

