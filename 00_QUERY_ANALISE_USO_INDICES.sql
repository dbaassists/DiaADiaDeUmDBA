/*

PERMISSÃO NECESSÁRIA: GRANT VIEW SERVER STATE TO [DOMAIN\USER] 

    */

use SGBODS
go    
    
Declare @TABELA VARCHAR(50) 
SET @TABELA  =  'tb_transacaoordemvendacab'

-- FRAGMENTACAO DE INDICES

SELECT OBJECT_NAME(ind.OBJECT_ID) AS TableName,
ind.name AS IndexName, indexstats.index_type_desc AS IndexType,
indexstats.avg_fragmentation_in_percent, indexstats.page_count
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) indexstats
LEFT JOIN sys.indexes ind
ON ind.object_id = indexstats.object_id
AND ind.index_id = indexstats.index_id
WHERE OBJECT_NAME(ind.OBJECT_ID) = @TABELA

ORDER BY indexstats.avg_fragmentation_in_percent DESC    
    
-- LISTA TAMANHO DE INDICES 
    
SELECT 
OBJECT_NAME(ID) As Objeto, 
I.Name As Indice, 
I.Rows As Linhas,
I.Reserved * 8 As Reservado, 
I.DPages * 8 As Dados, 
I.Used * 8 As Utilizado
FROM SYSindexes I
INNER JOIN sys.tables T
on i.id = T.object_id
    
WHERE T.name = @TABELA
--AND I.IndID IN (0,1) 
AND (I.NAME NOT LIKE '_WA%')

-- CRIA SCRIPT INDEX

IF OBJECT_ID ( 'TEMPDB..##TB_CREATE_INDEX' ) IS NOT NULL
DROP TABLE ##TB_CREATE_INDEX

SELECT T.object_id ,I.index_id,' CREATE ' +
       CASE 
            WHEN I.is_unique = 1 THEN ' UNIQUE '
            ELSE ''
       END +
       I.type_desc COLLATE DATABASE_DEFAULT + ' INDEX ' +
       I.name + ' ON ' +
       SCHEMA_NAME(T.schema_id) + '.' + T.name + ' ( ' +
       KeyColumns + ' )  ' +
       ISNULL(' INCLUDE (' + IncludedColumns + ' ) ', '') +
       ISNULL(' WHERE  ' + I.filter_definition, '') + ' WITH ( ' +
       CASE 
            WHEN I.is_padded = 1 THEN ' PAD_INDEX = ON '
            ELSE ' PAD_INDEX = OFF '
       END + ',' +
       'FILLFACTOR = ' + CONVERT(
           CHAR(5),
           CASE 
                WHEN I.fill_factor = 0 THEN 100
                ELSE I.fill_factor
           END
       ) + ',' +

       'SORT_IN_TEMPDB = OFF ' + ',' +
       CASE 
            WHEN I.ignore_dup_key = 1 THEN ' IGNORE_DUP_KEY = ON '
            ELSE ' IGNORE_DUP_KEY = OFF '
       END + ',' +
       CASE 
            WHEN ST.no_recompute = 0 THEN ' STATISTICS_NORECOMPUTE = OFF '
            ELSE ' STATISTICS_NORECOMPUTE = ON '
       END + ',' +
       ' ONLINE = OFF ' + ',' +
       CASE 
            WHEN I.allow_row_locks = 1 THEN ' ALLOW_ROW_LOCKS = ON '
            ELSE ' ALLOW_ROW_LOCKS = OFF '
       END + ',' +
       CASE 
            WHEN I.allow_page_locks = 1 THEN ' ALLOW_PAGE_LOCKS = ON '
            ELSE ' ALLOW_PAGE_LOCKS = OFF '
       END + ' ) ON [' +
       DS.name + ' ] ' +  CHAR(13) + CHAR(10) + ' GO' QueryCreateIndex
       
INTO ##TB_CREATE_INDEX       

FROM   sys.indexes I
       JOIN sys.tables T
            ON  T.object_id = I.object_id
       JOIN sys.sysindexes SI
            ON  I.object_id = SI.id
            AND I.index_id = SI.indid
       JOIN (
                SELECT *
                FROM   (
                           SELECT IC2.object_id,
                                  IC2.index_id,
                                  STUFF(
                                      (
                                          SELECT ' , ' + C.name + CASE 
                                                                       WHEN MAX(CONVERT(INT, IC1.is_descending_key)) 
                                                                            = 1 THEN 
                                                                            ' DESC '
                                                                       ELSE 
                                                                            ' ASC '
                                                                  END
                                          FROM   sys.index_columns IC1
                                                 JOIN sys.columns C
                                                      ON  C.object_id = IC1.object_id
                                                      AND C.column_id = IC1.column_id
                                                      AND IC1.is_included_column = 
                                                          0
                                          WHERE  IC1.object_id = IC2.object_id
                                                 AND IC1.index_id = IC2.index_id
                                          GROUP BY
                                                 IC1.object_id,
                                                 C.name,
                                                 index_id
                                          ORDER BY
                                                 MAX(IC1.key_ordinal) 
                                                 FOR XML PATH('')
                                      ),
                                      1,
                                      2,
                                      ''
                                  ) KeyColumns
                           FROM   sys.index_columns IC2 
                                  --WHERE IC2.Object_id = object_id('Person.Address') --Comment for all tables
                           GROUP BY
                                  IC2.object_id,
                                  IC2.index_id
                       ) tmp3
            )tmp4
            ON  I.object_id = tmp4.object_id
            AND I.Index_id = tmp4.index_id
       JOIN sys.stats ST
            ON  ST.object_id = I.object_id
            AND ST.stats_id = I.index_id
       JOIN sys.data_spaces DS
            ON  I.data_space_id = DS.data_space_id
       JOIN sys.filegroups FG
            ON  I.data_space_id = FG.data_space_id
       LEFT JOIN (
                SELECT *
                FROM   ( SELECT IC2.object_id,
                                  IC2.index_id,
                                  STUFF((
                                          SELECT ' , ' + C.name
                                          FROM   sys.index_columns IC1
                                                 JOIN sys.columns C
                                                      ON  C.object_id = IC1.object_id
                                                      AND C.column_id = IC1.column_id
                                                      AND IC1.is_included_column = 
                                                          1
                                          WHERE  IC1.object_id = IC2.object_id
                                                 AND IC1.index_id = IC2.index_id
                                          GROUP BY
                                                 IC1.object_id,
                                                 C.name,
                                                 index_id 
                                                 FOR XML PATH('')
                                      ),
                                      1,
                                      2,
                                      ''
                                  ) IncludedColumns
                           FROM   sys.index_columns IC2 
                           GROUP BY IC2.object_id,IC2.index_id
                       ) tmp1
                WHERE  IncludedColumns IS NOT NULL
            ) tmp2
            ON  tmp2.object_id = I.object_id
            AND tmp2.index_id = I.index_id
WHERE  t.name = @TABELA
           
           
           
    
   
-- LISTA INDICES NAO USADOS   
   
;WITH IndicesNaoUtilizados As (
SELECT distinct
    DB_NAME() As Banco,  OBJECT_NAME(I.object_id) As Tabela, I.Name As Indice,
    isnull(U.User_Seeks,0) As Pesquisas, isnull(U.User_Scans,0) As Varreduras, isnull(U.User_Lookups,0) As LookUps,
    U.Last_User_Seek As UltimaPesquisa, U.Last_User_Scan As UltimaVarredura,
    U.Last_User_LookUp As UltimoLookUp, U.Last_User_Update As UltimaAtualizacao,
	case when (isnull(U.User_Seeks,0) + isnull(U.User_Scans,0) + isnull(U.User_Lookups,0)) > 0 then 'Sim' 
    else 'Não' 
    end Indice_Usado
    , 'DROP INDEX [' + I.Name + '] ON [' + DB_NAME() + '].[' + SC.name + '].[' + OBJECT_NAME(I.object_id) + '];' QueryDropIndex
    , QueryCreateIndex

FROM
    sys.indexes As I WITH(NOLOCK)
    left outer JOIN sys.dm_db_index_usage_stats As U WITH(NOLOCK)
    ON I.object_id = U.object_id 
    AND I.index_id = U.index_id
    inner join sys.objects o WITH(NOLOCK)
    on i.object_id = o.object_id
    AND O.type = 'U'
    INNER JOIN SYS.schemas SC WITH(NOLOCK)
    ON O.schema_id = SC.schema_id
    
    INNER JOIN ##TB_CREATE_INDEX TCI WITH(NOLOCK)
    ON I.index_id = TCI.index_id
    AND O.object_id = TCI.object_id
    
	where U.Last_User_Update is not null
)

SELECT
    Banco, Tabela, Indice, Pesquisas, Varreduras, LookUps,
    UltimaPesquisa, UltimaVarredura, UltimoLookUp, Indice_Usado, QueryDropIndex, QueryCreateIndex
FROM IndicesNaoUtilizados
WHERE Tabela = @TABELA
and  (Pesquisas + Varreduras + LookUps) = 0  

-- LISTA INDICES USADOS   
   
;WITH IndicesNaoUtilizados As (
SELECT distinct
    DB_NAME() As Banco,  OBJECT_NAME(I.object_id) As Tabela, I.Name As Indice,
    isnull(U.User_Seeks,0) As Pesquisas, isnull(U.User_Scans,0) As Varreduras, isnull(U.User_Lookups,0) As LookUps,
    U.Last_User_Seek As UltimaPesquisa, U.Last_User_Scan As UltimaVarredura,
    U.Last_User_LookUp As UltimoLookUp, U.Last_User_Update As UltimaAtualizacao,
 case when (isnull(U.User_Seeks,0) + isnull(U.User_Scans,0) + isnull(U.User_Lookups,0)) > 0 then 'Sim' 
    else 'Não' 
    end Indice_Usado

FROM
    sys.indexes As I
    LEFT OUTER JOIN sys.dm_db_index_usage_stats As U
    ON I.object_id = U.object_id 
    AND I.index_id = U.index_id
    inner join sys.objects o
    on i.object_id = o.object_id
    
    where U.Last_User_Update is not null

)

SELECT
    Banco, Tabela, Indice, Pesquisas, Varreduras, LookUps,
    UltimaPesquisa, UltimaVarredura, UltimoLookUp, Indice_Usado
FROM IndicesNaoUtilizados
WHERE Tabela = @TABELA
and  (Pesquisas + Varreduras + LookUps) > 0 

