select	T.text, R.Status, R.Command, DatabaseName = db_name(R.database_id)
		, R.cpu_time, 
		R.total_elapsed_time 
		, case when (R.total_elapsed_time / 3600000) < 10 then '0' + cast((R.total_elapsed_time / 3600000) as varchar(2)) + ':'   
		  else cast((R.total_elapsed_time / 3600000) as varchar(2)) + ':' end 
		+
		 case when (( R.total_elapsed_time) - ((R.total_elapsed_time / 3600000) * 3600000 )) / 60000 < 10 then 
		'0' + cast((( R.total_elapsed_time) - ((R.total_elapsed_time / 3600000) * 3600000 )) / 60000 as varchar(2))
		else 
		cast((( R.total_elapsed_time) - ((R.total_elapsed_time / 3600000) * 3600000 )) / 60000 as varchar(2))
		end TP_Hora_Minutos
		, R.percent_complete
		, r.session_id
from	sys.dm_exec_requests R
		cross apply sys.dm_exec_sql_text(R.sql_handle) T
		
