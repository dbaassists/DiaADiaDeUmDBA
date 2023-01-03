-- Indicados para databases pequenas, para databases maiores deve ser realizada uma análise devido ao grande crescimento do Log

      declare @Id int,@SQLString nvarchar(4000)

     
      select identity(int,1,1) Id, 'ALTER INDEX ' + B.Name + ' ON ' + C.Name +
            case when Avg_Fragmentation_In_Percent < 20 then ' REORGANIZE' else ' REBUILD' end Comando
      INTO #Indices_Fragmentados
      from sys.dm_db_index_physical_stats(db_id(),null,null,null,null) A
            join sys.indexes B on a.object_id = B.Object_id and A.index_id = B.index_id
            join sys.sysobjects C on C.id = B.Object_id
      where avg_fragmentation_in_percent > 5
            and Page_Count > 1000
           
      WHILE exists (SELECT Id FROM #Indices_Fragmentados)
      BEGIN
            SELECT TOP 1 @Id = Id , @SQLString = Comando
           FROM #Indices_Fragmentados
     
            -- Realiza o REORGANIZE OU O REBUILD
            EXECUTE sp_executesql @SQLString
            
            DELETE FROM #Indices_Fragmentados
            WHERE Id = @Id
      

      END