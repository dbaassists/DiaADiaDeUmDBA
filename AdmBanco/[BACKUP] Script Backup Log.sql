SQL Server BACKUP LOG command     
(BACKUP LOG)	  
Overview
There are only two commands for backup, the primary is BACKUP DATABASE which backs up the entire database and BACKUP LOG which backs up the transaction log.  The following will show different options for doing transaction log backups.

Explanation
The BACKUP LOG command gives you many options for creating transaction log backups.  Following are different examples.

Create a simple transaction log backup to disk
The command is BACKUP LOG databaseName.  The "TO DISK" option specifies that the backup should be written to disk and the location and filename to create the backup is specified.  The file extension is "TRN".  This helps me know it is a transaction log backup, but it could be any extension you like.  Also, the database has to be in the FULL or Bulk-Logged recovery model and at least one Full backup has to have occurred.

BACKUP LOG AdventureWorks 
TO DISK = 'C:\AdventureWorks.TRN'
GO
Create a log backup with a password
This command creates a log backup with a password that will need to be supplied when restoring the database.

BACKUP LOG AdventureWorks 
TO DISK = 'C:\AdventureWorks.TRN'
WITH PASSWORD = 'Q!W@E#R$'
GO
Create a log backup with progress stats
This command creates a log backup and also displays the progress of the backup.  The default is to show progress after every 10%.

BACKUP LOG AdventureWorks 
TO DISK = 'C:\AdventureWorks.TRN'
WITH STATS
GO
Here is another option showing stats after every 1%.

BACKUP LOG AdventureWorks 
TO DISK = 'C:\AdventureWorks.TRN'
WITH STATS = 1
GO
Create a backup and give it a description
This command uses the description option to give the backup a name.  This can later be used with some of the restore commands to see what is contained with the backup.  The maximum size is 255 characters.

BACKUP LOG AdventureWorks 
TO DISK = 'C:\AdventureWorks.TRN'
WITH DESCRIPTION = 'Log backup for AdventureWorks'
GO
Create a mirrored backup
This option allows you to create multiple copies of the backups, preferably to different locations.

BACKUP LOG AdventureWorks 
TO DISK = 'C:\AdventureWorks.TRN'
MIRROR TO DISK =  'D:\AdventureWorks_mirror.TRN'
WITH FORMAT
GO
Specifying multiple options
This example shows how you can use multiple options at the same time.

BACKUP LOG AdventureWorks 
TO DISK = 'C:\AdventureWorks.TRN'
MIRROR TO DISK =  'D:\AdventureWorks_mirror.TRN'
WITH FORMAT, STATS, PASSWORD = 'Q!W@E#R$'
GO