select DB.log_reuse_wait_desc, DB.* 
from sys.databases DB WITH(NOLOCK) 
--INNER JOIN sys.database_files DBF WITH(NOLOCK)
--ON DBF.

where DB.name in ( 'SGBDW' , 'SGBODS' )


SELECT * FROM sys.database_files 