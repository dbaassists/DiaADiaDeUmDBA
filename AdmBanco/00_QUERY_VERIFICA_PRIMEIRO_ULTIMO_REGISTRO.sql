/*
Query a database to determine the earliest and latest dates recorded in the tables.
Executes in the current database. Useful when evaluating the age of a database,
and also as an indicator of current usage. If only old dates are found, perhaps
the database is no longer in use?

Returns 2 recordsets - 1 lists earliest and latest dates for each DATETIME or DATETIME2 column,
the 2nd returns the min and max dates found in the entire database. 

As written, the query runs in SQL 2008 and later; switch the comment and "where" clause on line 21 to run in SQL 2005 and earlier.

History:
20160621 Steve Armistead - initial

*/

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

-- get database creation date if wanted (uncomment the next line)
--select crdate as createDate from sys.sysdatabases where dbid = db_id()

-- build table of table and column names for all datetime(2) columns

select '[' + t.TABLE_SCHEMA + '].[' + t.TABLE_NAME + ']' as TblName, c.COLUMN_NAME as ColName, c.DATA_TYPE as ColType, t.TABLE_TYPE 
into #ColNames
from INFORMATION_SCHEMA.COLUMNS c 
join INFORMATION_SCHEMA.TABLES t on c.TABLE_SCHEMA = t.TABLE_SCHEMA and c.TABLE_NAME = t.TABLE_NAME
--where c.DATA_TYPE in('DATETIME') -- for SQL SERVER 2005 and earlier
where c.DATA_TYPE in('DATETIME','DATETIME2')
and t.TABLE_TYPE = 'BASE TABLE'

create table #tblSQL (#strSQL varchar(500))
create table #tblDates (TblName varchar(100), ColName varchar(150), MinDate datetime, MaxDate datetime)

-- SELECT * FROM #ColNames

declare @SQL2 varchar(1000)

-- Build a table of executable strings

INSERT #tblSQL
select 'select ' + char(39) + TblName + char(39) + ' as TblName, ' + char(39) + Colname + char(39) + ' as ColName, MIN([' + ColName + ']) as MinDate, MAX([' + ColName + ']) as MaxDate from ' + TblName from #ColNames

--select * from #tblSQL
-- execute each string in succession, recording results to #tblDates. 

while exists (select top 1 #strSQL from #tblSQL) 
begin
select top 1 @SQL2 = #strSQL from #tblSQL order by 1

-- select @SQL2

insert into #TblDates EXEC (@SQL2)
delete from #tblSQL where #strSQL = (select top 1 #strSQL from #tblSQL order by 1) 
End


--select * from #tblDates 
select * from #tblDates order by MaxDate desc

--select * from #tblDates order by MinDate desc
select min(MinDate) as OldestDate, max(MaxDate) as NewestDate
from #tblDates


--cleanup
--select * from #ColNames
--select * from #tblDates

drop table #tblDates
drop table #ColNames
drop table #tblSQL