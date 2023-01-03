if object_id('help_Table') is not null
Drop Procedure dbo.help_Table
Go


/*
DATA CREATE PROC: 18/08/2016
VERSÃO: 2 
ANALISTA: GABRIEL QUINTELLA
DBA CONSULT - CONSULTORIA EM BANCO DE DADOS
*/
                
Create procedure dbo.help_Table(@tabela varchar(100))
As

Set Nocount On

Begin

Declare @sql nvarchar(max)
Declare @coluna varchar(max)
Declare @tipo_dados varchar(max)
Declare @isNull varchar(max)
Declare @posicao_Coluna int
Declare @qtd_Colunas int
Declare @Coluna_Computada varchar(max)
Declare @PrimaryKey varchar(255)
Declare @nomePK varchar(255)
Declare @colunaPK varchar(255)
Declare @nomeUK varchar(255)
Declare @colunaUK varchar(255)
Declare @schemaTB varchar(255)
Declare @Collate varchar(255)


Set @sql = 'SET ANSI_NULLS ON ' + char(10)
Set @sql = @sql + 'GO' + char(10)
Set @sql = @sql + 'SET QUOTED_IDENTIFIER ON ' + char(10)
Set @sql = @sql + 'GO' + char(10)
Set @sql = @sql + 'SET ANSI_PADDING ON ' + char(10)
Set @sql = @sql + 'GO' + char(10)

-- Inclusão da busca do schema da tabela

SELECT		@schemaTB = s.name
FROM		SYS.tables T WITH(NOLOCK)
INNER JOIN	SYS.schemas S WITH(NOLOCK)
ON			T.schema_id = S.schema_id
where		t.name = @tabela

/*
Alteração da Linha	=> DE: Set @sql = @sql + 'If Object_id ('''+@tabela+''') is Not Null'+ char(13)
					=> PARA: Set @sql = @sql + 'If EXISTS (SELECT 1 FROM SYS.TABLES WHERE NAME = @tabela) + char(13)
Justificativa para alteração: Da forma como estava desenvolvido, caso a tabela estivesse sem registro, o script apresentará erro devido a clausula IS NOT NULL.
Não está errada a lógica, o mas correto nesse caso é verificar se o objeto existe ou não.
*/

-- Inclusão da variável @schemaTB para identificar o schema da tabela

Set @sql = @sql + 'If EXISTS (SELECT 1 FROM SYS.TABLES WHERE NAME = ''' + @tabela + ''') '+ char(13)
Set @sql = @sql + 'Drop Table '+ '[' + @schemaTB + ']' + '.' + '[' + @tabela + ']' + char(10) 
Set @sql = @sql + 'GO' + char(10)

-- Inclusão da variável @schemaTB para identificar o schema da tabela

Set @sql = @sql + 'Create Table ' + '[' +  @schemaTB + ']' + '.' + '[' + @tabela + ']' + char(13)
Set @sql = @sql + '('+ char(13)

--Identificar o total de colunas da tabela

Select @qtd_Colunas = count (*)
From information_schema.columns
Where Table_name = @tabela

--Identificar o nome da coluna que é a chave primária

Select c.name as colunaPk,  b.name as nomePK, a.object_id
into #primaryKeys 
From sys.objects a
inner Join sys.key_constraints b
On b.parent_object_id = a.object_id
inner join sys.columns c
On c.object_id = a.object_id
inner join sys.index_columns d
On d.object_id = a.object_id
And d.column_id = c.column_id
And b.unique_index_id = d.index_id
Where a.name = @tabela
And b.[type] = 'PK'

--Agrupa caso exista mais de uma coluna na PK.

Set @colunaPK =(Select distinct coalesce((Select colunaPk +' ASC'+','
From #primaryKeys
where object_id = a.object_id For xml path(''), Type).value('.[1]', 'varchar(255)'), '') as Pk
From #primaryKeys a)

Set @nomePK = (Select distinct nomePK From #primaryKeys)

--Identificar Unique key

Select @nomeUK = I.name
From sys.indexes I WITH(NOLOCK)
			INNER JOIN SYS.tables T WITH(NOLOCK)
			ON I.object_id = T.object_id 
			Where T.NAME = @tabela
And I.type_desc='NONCLUSTERED'
And is_unique_constraint = 1

Select c.name,a.object_id
Into #uniques
From sys.objects a
inner Join sys.key_constraints b
On b.parent_object_id = a.object_id
inner join sys.columns c
On c.object_id = a.object_id
inner join sys.index_columns d
On d.object_id = a.object_id
And d.column_id = c.column_id
And b.unique_index_id = d.index_id
Where a.name = @tabela
And b.[type] = 'UQ'

--Agrupa caso exista mais de uma coluna unica.

Set @colunaUK =(Select distinct coalesce((Select name+' ASC'+','
From #uniques
where object_id = a.object_id For xml path(''), Type).value('.[1]', 'varchar(255)'), '') as Uk
From #uniques a)

--Cursor para montar a estrutura da tabela

Declare cursor_colunas cursor
For

/*

Alterações realizadas: 

1 - Inclusão da criação de check_constraint

is_nullable = case when a.is_nullable = 'NO'  And ( i.[definition] is null and cc.[definition] is null ) then 'Not null'
                   When c.[definition] is not null then ''

--default_Constraint
                   when a.is_nullable = 'NO'  And i.[definition] is not null then 'Not null ' + 'Constraint '+i.name +' Default '+ i.[definition]
                   when a.is_nullable = 'YES' And i.[definition] is not null then 'Null ' + 'Constraint '+i.name +' Default '+ i.[definition]

--check_constraint 
                   when a.is_nullable = 'NO'  And cc.[definition] is not null then 'Not null ' + 'Constraint '+ cc.name +' Check '+ cc.[definition]
                   when a.is_nullable = 'YES' And cc.[definition] is not null then 'Null ' + 'Constraint '+cc.name +' Check '+ cc.[definition]

else 'Null' end

----------------------------------------------------------------

2 - Retirada da validação ( Não existe necessidade de validar por datatype )
3 - Alteração para definir quando uma computed column é definida como PERSISTED ou não.

When data_type = 'varchar' And c.[definition] is not null then 'As ' + c.[definition]
When data_type = 'char'           And c.[definition] is not null then 'As ' + c.[definition]
When data_type = 'int'            And c.[definition] is not null then 'As ' + c.[definition]
When data_type = 'bit'            And c.[definition] is not null then 'As ' + c.[definition]
When data_type = 'smalldatetime'  And c.[definition] is not null then 'As ' + c.[definition]
when data_type = 'int' and d.is_identity = 1 then 'int Identity ('+ cast(seed_value as varchar) + ',' + cast(increment_value as varchar) +')'

Por

When c.[definition] is not null then 'As ' + c.[definition] + ( CASE WHEN c.is_persisted = 1 THEN ' PERSISTED ' ELSE '' END )

----------------------------------------------------------------

*/

Select distinct
column_name,
data_type = case
When data_type = 'varchar' And c.[definition] is null then data_type +'('+case
when convert(varchar,character_maximum_Length) = -1 then 'max'
else convert(varchar,character_maximum_Length)
end+')'
When data_type = 'char' And c.[definition] is null then data_type +'('+convert(varchar,character_maximum_Length)+')'

--computed_columns
when data_type = 'int' and d.is_identity = 1 then 'int Identity ('+ cast(seed_value as varchar) + ',' + cast(increment_value as varchar) +')'
When c.[definition] is not null then 'As ' + c.[definition] + ( CASE WHEN c.is_persisted = 1 THEN ' PERSISTED ' ELSE '' END )
else data_type
end,
is_nullable = case when a.is_nullable = 'NO'  And ( i.[definition] is null and cc.[definition] is null ) then 'Not null'
                   When c.[definition] is not null then ''

--default_Constraint
                   when a.is_nullable = 'NO'  And i.[definition] is not null then 'Not null ' + 'Constraint '+ '[' + i.name + ']' +' Default '+ i.[definition]
                   when a.is_nullable = 'YES' And i.[definition] is not null then 'Null ' + 'Constraint '+ '[' + i.name + ']' +' Default '+ i.[definition]

--check_constraint 
                   when a.is_nullable = 'NO'  And cc.[definition] is not null then 'Not null ' + 'Constraint '+ '[' + cc.name + ']' +' Check '+ cc.[definition]
                   when a.is_nullable = 'YES' And cc.[definition] is not null then 'Null ' + 'Constraint '+ '[' + cc.name + ']' +' Check '+ cc.[definition]

else 'Null' end,
ordinal_position, c.[definition],  a.COLLATION_NAME collateC
From information_schema.columns a
Inner Join sys.objects b
On a.TABLE_NAME = b.name
And b.type = 'U'
Left Join sys.computed_columns c
On c.object_id = b.object_id
And c.name = a.column_name
Left Join sys.identity_columns d
On d.object_id = b.object_id
And d.name = a.column_name
Inner Join sys.columns e
On e.name = a.column_name
And e.object_id = b.object_id
Left Join sys.default_constraints  i
On i.parent_object_id = b.object_id
And i.parent_column_id = e.column_id
Left Join sys.check_constraints cc 
on cc.parent_object_id = e.object_id
and cc.parent_column_id = e.column_id
Where Table_name = @tabela
Order by ordinal_position

Open cursor_colunas

fetch next from cursor_colunas into @coluna,@tipo_dados,@isNull,@posicao_Coluna,@Coluna_Computada, @Collate

While @@FETCH_STATUS = 0

Begin

/*******************************************************************************************************
Alterações realizadas: 

- Inclusão do collate na criação da coluna
*******************************************************************************************************/

Set @sql = @sql + '[' + @coluna + ']' + ' '+ @tipo_dados + ' ' + ( case when @Collate IS NOT NULL then 'Collate ' + @Collate else ' ' end ) + ' '  + @isNull 

if(@posicao_Coluna <> @qtd_Colunas)

Set @sql = @sql + ','+ char(13)
 
else

Set @sql = @sql + char(13)

fetch next From cursor_colunas into @coluna,@tipo_dados,@isNull,@posicao_Coluna,@Coluna_Computada,@Collate

End

close cursor_colunas

deallocate cursor_colunas

Set @sql = @sql + ') ON [Primary]'+ char(10)
Set @sql = @sql + 'GO'+ char(10)

/*******************************************************************************************************
Alterações realizadas: 

- Definição de Create de Chave Estrangeira (FK)
*******************************************************************************************************/

SELECT T.object_id ,I.index_id,'CREATE ' +
       CASE 
            WHEN I.is_unique = 1 THEN 'UNIQUE '
            ELSE ''
       END +
       I.type_desc COLLATE DATABASE_DEFAULT + ' INDEX ' +
       '[' + I.name + ']' + ' ON ' +
       '[' + SCHEMA_NAME(T.schema_id) + ']' +  '.' + '[' +  T.name + ']' + '(' +
       KeyColumns + ' )  ' +
       ISNULL(' INCLUDE (' + IncludedColumns + ') ', '') +
       ISNULL(' WHERE ' + I.filter_definition, '') + 'WITH(' +
       CASE 
            WHEN I.is_padded = 1 THEN 'PAD_INDEX = ON'
            ELSE 'PAD_INDEX = OFF'
       END + ',' +
       'FILLFACTOR =' + CONVERT(
           CHAR(5),
           CASE 
                WHEN I.fill_factor = 0 THEN 100
                ELSE I.fill_factor
           END
       ) + ',' +
       -- default value 
       'SORT_IN_TEMPDB = OFF' + ',' +
       CASE 
            WHEN I.ignore_dup_key = 1 THEN 'IGNORE_DUP_KEY = ON'
            ELSE 'IGNORE_DUP_KEY = OFF'
       END + ',' +
       CASE 
            WHEN ST.no_recompute = 0 THEN 'STATISTICS_NORECOMPUTE = OFF'
            ELSE 'STATISTICS_NORECOMPUTE = ON'
       END + ',' +
       'ONLINE = OFF' + ',' +
       CASE 
            WHEN I.allow_row_locks = 1 THEN 'ALLOW_ROW_LOCKS = ON'
            ELSE 'ALLOW_ROW_LOCKS = OFF'
       END + ',' +
       CASE 
            WHEN I.allow_page_locks = 1 THEN 'ALLOW_PAGE_LOCKS = ON'
            ELSE 'ALLOW_PAGE_LOCKS = OFF'
       END + ',' +
       
	   'DATA_COMPRESSION = ' + P.data_compression_desc       
       
       + ') ON [' +
       DS.name + ']' +  CHAR(13) + CHAR(10) + 'GO' [CreateIndexScript]
       
       INTO #indices
       
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
                                                                            ' DESC'
                                                                       ELSE 
                                                                            ' ASC'
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
		INNER JOIN SYS.partitions P 			
			ON I.object_id = P.object_id
			AND I.index_id = P.index_id            
            
       JOIN sys.data_spaces DS
            ON  I.data_space_id = DS.data_space_id
       JOIN sys.filegroups FG
            ON  I.data_space_id = FG.data_space_id
       LEFT JOIN (
                SELECT *
                FROM   (
                           SELECT IC2.object_id,
                                  IC2.index_id,
                                  STUFF(
                                      (
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
                           GROUP BY
                                  IC2.object_id,
                                  IC2.index_id
                       ) tmp1
                WHERE  IncludedColumns IS NOT NULL
            ) tmp2
            ON  tmp2.object_id = I.object_id
            AND tmp2.index_id = I.index_id
WHERE  T.name = @tabela
AND I.is_primary_key = 0

/*******************************************************************************************************
Definição de Create de Chave Primária (PK)
*******************************************************************************************************/

Declare @Min int, @Max int, @sqlIndex varchar(2000), @extended_properties varchar(2000)

Select @Min = MIN(index_id), @Max =	 MAX(index_id)
from #indices

While @Min <= @Max 

begin 

	Select @sqlIndex = CreateIndexScript
	from #indices
	where index_id = @Min 
	
	Set @sql = @sql + @sqlIndex + CHAR(10)  
	
	Set @Min = @Min +1
	
end 

if Exists(Select 1 From sys.indexes I WITH(NOLOCK)
			INNER JOIN SYS.tables T WITH(NOLOCK)
			ON I.object_id = T.object_id 
			Where T.NAME = @tabela And I.type_desc <>'HEAP')

Begin

Declare		@_is_padded varchar(200), 
			@_fill_factor varchar(200), 
			@_ignore_dup_key varchar(200), 
			@_no_recompute varchar(200), 
			@_allow_row_locks varchar(200), 
			@_allow_page_locks varchar(200),
			@_data_compression varchar(200)

Select 
  @_is_padded = ( CASE WHEN I.is_padded = 1 THEN 'PAD_INDEX = ON' ELSE 'PAD_INDEX = OFF' END ) 
, @_fill_factor = ('FILLFACTOR =' + CONVERT(VARCHAR(5),CASE WHEN I.fill_factor = 0 THEN 100 ELSE I. fill_factor END ))
, @_ignore_dup_key = ( CASE WHEN I.ignore_dup_key = 1 THEN 'IGNORE_DUP_KEY = ON' ELSE 'IGNORE_DUP_KEY = OFF' END )
, @_no_recompute = ( CASE WHEN ST.no_recompute = 0 THEN 'STATISTICS_NORECOMPUTE = OFF' ELSE 'STATISTICS_NORECOMPUTE = ON' END )
, @_allow_row_locks = (CASE WHEN I.allow_row_locks = 1 THEN 'ALLOW_ROW_LOCKS = ON' ELSE 'ALLOW_ROW_LOCKS = OFF' END )
, @_allow_page_locks = ( CASE WHEN I.allow_page_locks = 1 THEN 'ALLOW_PAGE_LOCKS = ON' ELSE 'ALLOW_PAGE_LOCKS = OFF' END )
, @_data_compression = ('DATA_COMPRESSION = ' + P.data_compression_desc ) 
From sys.indexes I WITH(NOLOCK)
			INNER JOIN SYS.tables T WITH(NOLOCK)
			ON I.object_id = T.object_id 
			INNER JOIN sys.stats ST
            ON  ST.object_id = I.object_id
            AND ST.stats_id = I.index_id
			INNER JOIN SYS.partitions P 			
			ON I.object_id = P.object_id
			AND I.index_id = P.index_id
			Where T.NAME = @tabela
			And I.name = @nomePK
			


Set @sql = @sql + 'ALTER TABLE ' + '[' + @schemaTB + ']' + '.' + '[' + @tabela + ']' +  ' ADD CONSTRAINT ' + '[' + @nomePK + ']' +' PRIMARY KEY '+ '('+ left(@colunaPK, len(@colunaPK)-1) + ') WITH ( ' + @_is_padded +  ', ' + @_fill_factor + ', '  + @_no_recompute +  ' , ' + @_ignore_dup_key + ', ' + @_allow_row_locks +  ', ' + @_allow_page_locks + ', ' + @_data_compression + ') ON [Primary] '+ char(10)
Set @sql = @sql + 'GO'+ char(10)

end

/*******************************************************************************************************
Definição de Nomenclatura de Colunas
*******************************************************************************************************/

SELECT 

EP.minor_id ID
, 'EXEC sp_addextendedproperty @name = N''' + C.name + ''',' + '@value = ''' + CONVERT(VARCHAR(200),EP.value) + ''',' + '@level0type = N''Schema'', @level0name = ''' + SC.name + ''',' + '@level1type = N''Table'',  @level1name = ''' + T.NAME  + ''',' + '@level2type = N''Column'', @level2name = ''' + C.name  + '''' + CHAR(10) + 'GO' + CHAR(10) _SQL 

INTO #extended_properties

FROM		SYS.extended_properties EP WITH(NOLOCK)
INNER JOIN	SYS.tables T WITH(NOLOCK)
ON			EP.major_id = T.object_id
INNER JOIN	sys.schemas SC WITH(NOLOCK)
ON			T.schema_id = SC.schema_id
INNER JOIN	SYS.columns C WITH(NOLOCK)
ON			C.object_id = EP.major_id
AND			C.column_id = EP.minor_id

WHERE		T.name = @tabela

ORDER BY	EP.minor_id

Set @Min = null
Set @Max = null

Select @Min = MIN(id), @Max =	 MAX(id)
from #extended_properties

While @Min <= @Max 

begin 

	Select @extended_properties = _SQL
	from #extended_properties
	where id = @Min 
	
	Set @sql = @sql + @extended_properties  
	
	Set @Min = @Min +1
	
end 

Set @sql = @sql + 'SET ANSI_PADDING OFF'+ char(10)
Set @sql = @sql + 'GO'+ char(10)

print @sql

End

Go