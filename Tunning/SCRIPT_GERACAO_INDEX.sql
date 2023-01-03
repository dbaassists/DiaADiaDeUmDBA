--CREATE NONCLUSTERED INDEX [IX_NCL_MUNICIPIO_COD_MUNICIPIO_SK_02] ON dbo.DIM_MUNICIPIO (SK_MUNICIPIO ASC, CD_MUNICIPIO ASC)

SELECT 'CREATE ' + i.[type_desc] +  ' INDEX [' + ISNULL(i.name, '') COLLATE database_default + ']' + ' ON ' + s.name + '.' + t.name + ' (' + ISNULL(SUBSTRING(c.[indexed], 0, LEN(c.[indexed])), '') + 
(CASE WHEN c.[included] IS NOT NULL 
THEN ') INCLUDE (' + ISNULL(SUBSTRING(c.[included], 0, LEN(c.[included])), '') + ')' ELSE ')' END) +

';' SCRIPT ,
s.name as [schema], t.name as [table]
 
-- Detalhes do índice
, i.[type_desc], i.[is_primary_key], i.[is_unique], i.[is_unique_constraint]
, ISNULL(i.name, '') AS [index]
, ISNULL(SUBSTRING(c.[indexed], 0, LEN(c.[indexed])), '') AS [indexed]
, ISNULL(SUBSTRING(c.[included], 0, LEN(c.[included])), '') AS [included]
 
-- Filtro utilizado pelo índice
, ISNULL(i.filter_definition, '') AS [filtered]
 
FROM sys.schemas s
INNER JOIN sys.tables t
ON s.[schema_id] = t.[schema_id]
INNER JOIN sys.indexes i
ON t.[object_id] = i.[object_id]
 
-- Relação de colunas que formam o índice
CROSS APPLY (
    SELECT (
        SELECT c.name + ', '
        FROM sys.columns c
        INNER JOIN sys.index_columns ic
        ON c.[object_id] = ic.[object_id]
        AND c.[column_id] = ic.[column_id]
        WHERE t.[object_id] = c.[object_id]
        AND ic.[index_id] = i.[index_id]
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
        AND ic.[index_id] = i.[index_id]
        AND ic.[is_included_column] = 1
        ORDER BY [key_ordinal]
        FOR XML PATH('')
    ) AS [included]
) AS c
WHERE i.[type_desc] <> 'HEAP'
ORDER BY 4, [schema], [table], 8, 9
