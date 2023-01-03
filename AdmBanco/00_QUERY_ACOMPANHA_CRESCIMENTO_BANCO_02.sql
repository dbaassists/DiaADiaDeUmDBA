USE SGBODS
GO

SELECT type_desc, name, physical_name, state_desc, size/1024 TAMANHO ,(size/1024) - ( max_size /1024) TAMANHO_RESTANTE, max_size /1024 TAMANHO_TOTAL
FROM SYS.database_files 


