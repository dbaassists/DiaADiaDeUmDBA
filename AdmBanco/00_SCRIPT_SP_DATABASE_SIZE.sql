EXEC sp_Database_size 'SGBdw'

CREATE PROC sp_Database_size @DATABASE_NAME SYSNAME = NULL, @TABLE SYSNAME = NULL
AS

/**
CREATE PROC VERSÃO 1 : 17/08/2016
THIAGO CRUZ
GUIA DBA - O SEU GUIA DE BANCO DE DADOS
DBA ACADEMY - SEU PORTAL DE TREINAMENTO SQL SERVER
WWW.DBAACADEMY.COM.BR
**/

IF @DATABASE_NAME IS NULL AND @TABLE IS NOT NULL
BEGIN
PRINT 'FAVOR INFORMAR O NOME DO BANCO DE DADOS'
END 
ELSE 
BEGIN
DECLARE @DATABASE_ID INT 
DECLARE @SQL_STRING VARCHAR(6000) 

IF @TABLE IS NULL 
BEGIN
DECLARE @FILE_SIZE TABLE 
    ( 
    [DATABASE_NAME] [SYSNAME] NULL, 
    [GROUPID] [SMALLINT] NULL, 
    [GROUPNAME] [VARCHAR](80) NULL, 
    [FILEID] [SMALLINT] NULL, 
    [FILE_SIZE] [DECIMAL](12, 2) NULL, 
    [SPACE_USED] [DECIMAL](12, 2) NULL, 
    [FREE_SPACE] [DECIMAL](12, 2) NULL, 
    [PERCE_FREE] [DECIMAL] (12,2) NULL,
    [NAME] [SYSNAME] NOT NULL, 
    [FILENAME] [VARCHAR](260) NOT NULL,
    [RECOVERY_MODEL] [VARCHAR] (40) NULL,
    [LAST_FULL_BACKUP]       [DATETIME] NULL,
    [TYPE] [VARCHAR] (40) NULL,
    [NAME_BACKUP] [VARCHAR] (400) NULL
    )
END

IF @TABLE IS NOT NULL
BEGIN
DECLARE @FILE_SIZE2 TABLE 
    ( 
    [DATABASE_NAME] [SYSNAME] NULL, 
    [GROUPID] [SMALLINT] NULL, 
    [GROUPNAME] [VARCHAR](80) NULL, 
    [FILEID] [SMALLINT] NULL, 
    [FILE_SIZE] [DECIMAL](12, 2) NULL, 
    [SPACE_USED] [DECIMAL](12, 2) NULL, 
    [FREE_SPACE] [DECIMAL](12, 2) NULL, 
    [PERCE_FREE] [DECIMAL] (12,2) NULL,
    [NAME] [SYSNAME] NOT NULL, 
    [FILENAME] [VARCHAR](260) NOT NULL,
    [INDEX]     [VARCHAR] (200) NULL,
    [PAGES]            [INT] NULL,
    [TABLE_KB]   [BIGINT] NULL,
    [ROWCNT] [BIGINT] NULL
    )
END

IF @DATABASE_NAME IS NOT NULL AND @TABLE IS NOT NULL
BEGIN

    SET @SQL_STRING = 'USE ' + QUOTENAME(@DATABASE_NAME) + CHAR(10) 
    SET @SQL_STRING = @SQL_STRING + 'SELECT DISTINCT
                                        DB_NAME() 
                                        ,ISNULL(SYSFILEGROUPS.GROUPID,0) 
                                        ,ISNULL(SYSFILEGROUPS.GROUPNAME, ''TLOG'') 
                                        ,FILEID 
                                        ,CONVERT(DECIMAL(12,2),ROUND(SYSFILES.SIZE/128.000,2)) AS FILE_SIZE 
                                        ,CONVERT(DECIMAL(12,2),ROUND(FILEPROPERTY(SYSFILES.NAME,''SPACEUSED'')/128.000,2)) AS SPACE_USED 
                                        ,CONVERT(DECIMAL(12,2),ROUND((SYSFILES.SIZE-FILEPROPERTY(SYSFILES.NAME,''SPACEUSED''))/128.000,2)) AS FREE_SPACE
                                        ,(CONVERT(DECIMAL(12,2),ROUND((SYSFILES.SIZE-FILEPROPERTY(SYSFILES.NAME,''SPACEUSED''))/128.000,2))/CONVERT(DECIMAL(12,2),ROUND(SYSFILES.SIZE/128.000,2))*100) 
                                        ,SYSFILES.NAME 
                                        ,SYSFILES.FILENAME 
                                        ' + CASE WHEN @TABLE IS NOT NULL THEN
                                        ',SYS.SYSINDEXES.NAME
                                        ,SYS.SYSINDEXES.DPAGES
                                        ,(SYS.SYSINDEXES.DPAGES*8) [TABLE KB]
                                        ,SYS.SYSINDEXES.ROWCNT'
                                        ELSE '' END +'
                                    FROM SYS.SYSFILES 
                                    LEFT OUTER JOIN SYS.SYSFILEGROUPS 
                                        ON SYSFILES.GROUPID = SYSFILEGROUPS.GROUPID
                                    ' + CASE WHEN @TABLE IS NOT NULL THEN
                                                                           'INNER JOIN SYS.SYSINDEXES
                                                                                  ON SYSFILES.GROUPID = SYS.SYSINDEXES.GROUPID
                                                                             AND OBJECT_ID(''' + @TABLE + ''') = ID
                                                                               AND SYS.SYSINDEXES.ROOT IS NOT NULL'
                                                                             ELSE '' END +'                                                            
                                   WHERE DB_NAME() = ''' + @DATABASE_NAME + ''''

IF @TABLE IS NULL
BEGIN
    INSERT INTO @FILE_SIZE 
        EXEC (@SQL_STRING)
END  
ELSE 
BEGIN
    INSERT INTO @FILE_SIZE2 
        EXEC (@SQL_STRING)  
END
END



IF @DATABASE_NAME IS NULL
BEGIN
SELECT TOP 1 @DATABASE_ID = DATABASE_ID 
    ,@DATABASE_NAME = NAME 
FROM SYS.DATABASES 
WHERE DATABASE_ID > 0 
ORDER BY DATABASE_ID


WHILE @DATABASE_NAME IS NOT NULL 
BEGIN

    SET @SQL_STRING = 'USE ' + QUOTENAME(@DATABASE_NAME) + CHAR(10) 
    SET @SQL_STRING = @SQL_STRING + 'SELECT 
                                        DB_NAME() 
                                        ,ISNULL(SYSFILEGROUPS.GROUPID,0)  
                                        ,ISNULL(SYSFILEGROUPS.GROUPNAME, ''TLOG'') 
                                        ,FILEID 
                                        ,CONVERT(DECIMAL(12,2),ROUND(SYSFILES.SIZE/128.000,2)) AS FILE_SIZE 
                                        ,CONVERT(DECIMAL(12,2),ROUND(FILEPROPERTY(SYSFILES.NAME,''SPACEUSED'')/128.000,2)) AS SPACE_USED 
                                        ,CONVERT(DECIMAL(12,2),ROUND((SYSFILES.SIZE-FILEPROPERTY(SYSFILES.NAME,''SPACEUSED''))/128.000,2)) AS FREE_SPACE
                                        ,(CONVERT(DECIMAL(12,2),ROUND((SYSFILES.SIZE-FILEPROPERTY(SYSFILES.NAME,''SPACEUSED''))/128.000,2))/CONVERT(DECIMAL(12,2),ROUND(SYSFILES.SIZE/128.000,2))*100) 
                                        ,SYSFILES.NAME 
                                        ,SYSFILES.FILENAME 
                                        ,BACKUPSET.RECOVERY_MODEL
                                        ,BACKUPSET.LAST_FULL_BACKUP
                                        ,CASE WHEN BACKUPSET.TYPE  = ''D'' THEN ''Database'' 
                                              WHEN  BACKUPSET.TYPE = ''I'' THEN ''Differential database'' 
                                              WHEN BACKUPSET.TYPE = ''L'' THEN ''LOG''
                                                                                    WHEN    BACKUPSET.TYPE = ''F'' THEN ''File or filegroup'' 
                                                                                       WHEN  BACKUPSET.TYPE = ''G'' THEN ''Differential file'' 
                                                                                        WHEN     BACKUPSET.TYPE = ''P'' THEN ''PARTIAL''
                                                                                        ELSE ''Differential partial'' END
                                                                         ,BACKUPSET.LOCAL
                                    FROM SYS.SYSFILES 
                                    LEFT OUTER JOIN SYS.SYSFILEGROUPS 
                                      ON SYSFILES.GROUPID = SYSFILEGROUPS.GROUPID
                                                                     CROSS APPLY (SELECT TOP 1 NAME AS LOCAL, RECOVERY_MODEL, BACKUP_FINISH_DATE AS LAST_FULL_BACKUP, TYPE
                                                                                            FROM MSDB.DBO.BACKUPSET 
                                                                                             WHERE MSDB.DBO.BACKUPSET.DATABASE_NAME =  '''+ @DATABASE_NAME +''' 
                                                                                             ORDER BY BACKUP_FINISH_DATE DESC) AS BACKUPSET        
                                   WHERE DB_NAME() = ''' + @DATABASE_NAME + ''''


        INSERT INTO @FILE_SIZE 
        EXEC (@SQL_STRING)  


 
    SET @DATABASE_NAME = NULL 
    SELECT TOP 1 @DATABASE_ID = DATABASE_ID 
        ,@DATABASE_NAME = NAME 
    FROM SYS.DATABASES 
    WHERE DATABASE_ID > @DATABASE_ID
    ORDER BY DATABASE_ID 
END
END

IF @DATABASE_NAME IS NOT NULL
BEGIN

WHILE @DATABASE_NAME IS NOT NULL 
BEGIN

    SET @SQL_STRING = 'USE ' + QUOTENAME(@DATABASE_NAME) + CHAR(10) 
    SET @SQL_STRING = @SQL_STRING + 'SELECT 
                                        DB_NAME() 
                                        ,ISNULL(SYSFILEGROUPS.GROUPID,0)  
                                        ,ISNULL(SYSFILEGROUPS.GROUPNAME, ''TLOG'') 
                                        ,FILEID 
                                        ,CONVERT(DECIMAL(12,2),ROUND(SYSFILES.SIZE/128.000,2)) AS FILE_SIZE 
                                        ,CONVERT(DECIMAL(12,2),ROUND(FILEPROPERTY(SYSFILES.NAME,''SPACEUSED'')/128.000,2)) AS SPACE_USED 
                                        ,CONVERT(DECIMAL(12,2),ROUND((SYSFILES.SIZE-FILEPROPERTY(SYSFILES.NAME,''SPACEUSED''))/128.000,2)) AS FREE_SPACE
                                        ,(CONVERT(DECIMAL(12,2),ROUND((SYSFILES.SIZE-FILEPROPERTY(SYSFILES.NAME,''SPACEUSED''))/128.000,2))/CONVERT(DECIMAL(12,2),ROUND(SYSFILES.SIZE/128.000,2))*100) 
                                        ,SYSFILES.NAME 
                                        ,SYSFILES.FILENAME 
                                        ,BACKUPSET.RECOVERY_MODEL
                                        ,BACKUPSET.LAST_FULL_BACKUP
                                        ,CASE WHEN BACKUPSET.TYPE  = ''D'' THEN ''Database'' 
                                              WHEN  BACKUPSET.TYPE = ''I'' THEN ''Differential database'' 
                                              WHEN BACKUPSET.TYPE = ''L'' THEN ''LOG''
                                                                                          WHEN    BACKUPSET.TYPE = ''F'' THEN ''File or filegroup'' 
                                                                                     WHEN  BACKUPSET.TYPE = ''G'' THEN ''Differential file'' 
                                                                                      WHEN     BACKUPSET.TYPE = ''P'' THEN ''PARTIAL''
                                                                                      ELSE ''Differential partial'' END
                                                                       ,BACKUPSET.LOCAL
                                    FROM SYS.SYSFILES 
                                    LEFT OUTER JOIN SYS.SYSFILEGROUPS 
                                      ON SYSFILES.GROUPID = SYSFILEGROUPS.GROUPID
                                                                   CROSS APPLY (SELECT TOP 1 NAME AS LOCAL, RECOVERY_MODEL, BACKUP_FINISH_DATE AS LAST_FULL_BACKUP, TYPE
                                                                                                  FROM MSDB.DBO.BACKUPSET 
                                                                                           WHERE MSDB.DBO.BACKUPSET.DATABASE_NAME =  '''+ @DATABASE_NAME +''' 
                                                                                           ORDER BY BACKUP_FINISH_DATE DESC) AS BACKUPSET        
                                   WHERE DB_NAME() = ''' + @DATABASE_NAME + ''''


        INSERT INTO @FILE_SIZE 
        EXEC (@SQL_STRING)  

 
    SET @DATABASE_NAME = NULL 
    SELECT TOP 1 @DATABASE_ID = DATABASE_ID 
        ,@DATABASE_NAME = NAME 
    FROM SYS.DATABASES 
    WHERE DATABASE_ID > @DATABASE_ID
    ORDER BY DATABASE_ID 
END
END

IF @TABLE IS NULL
BEGIN
SELECT *
FROM @FILE_SIZE 
END
ELSE 
BEGIN 
SELECT *
FROM @FILE_SIZE2
END
END