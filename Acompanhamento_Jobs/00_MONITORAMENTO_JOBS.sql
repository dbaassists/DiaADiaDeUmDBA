
IF OBJECT_ID ('TeMPDB..##TMP_STATUSJOBS') is not null 
DROP TABLE ##TMP_STATUSJOBS ;
CREATE TABLE ##TMP_STATUSJOBS 
(run_status VARCHAR(1)
, dscstatus  VARCHAR(20)) 

INSERT INTO ##TMP_STATUSJOBS (run_status, dscstatus) VALUES ('0','falha')
INSERT INTO ##TMP_STATUSJOBS (run_status, dscstatus) VALUES ('1','com êxito')
INSERT INTO ##TMP_STATUSJOBS (run_status, dscstatus) VALUES ('2','repetir')
INSERT INTO ##TMP_STATUSJOBS (run_status, dscstatus) VALUES ('3','cancelado')
INSERT INTO ##TMP_STATUSJOBS (run_status, dscstatus) VALUES ('4','em andamento' )

;with cte_jobs as
(
	SELECT 
	CASE	WHEN sj.name = 'SHV_MIS_CARGA_SRCC_PEDIDO' 
	THEN	'SRCC_PEDIDO'
			WHEN sj.name = 'SHV_MIS_Wiseit_RCC' 
	THEN	'Wiseit_RCC'
			WHEN sj.name = 'SHV- PKG-Carregar_DW_Fatos_Abastecimento04' 
	THEN	'Fato_Abastecimento'
	END JobName ,
	sh.run_date dataexec, 
	CASE	WHEN sh.message like '%Failure sending mail%' then 1 
			ELSE sh.run_status 
	END run_status

	FROM	msdb.dbo.sysjobs sj

	JOIN	msdb.dbo.sysjobhistory sh
	
	ON		sj.job_id = sh.job_id
	
	where	sj.name in 
	(
		'SHV_MIS_CARGA_SRCC_PEDIDO',
		'SHV_MIS_Wiseit_RCC',
		'SHV- PKG-Carregar_DW_Fatos_Abastecimento04'
	)
	
	and step_name <> '(Job outcome)'

)
select	convert(varchar(10),cast(convert(varchar(10),dataexec) as datetime) ,103) dataexec 
,		srccstatus.dscstatus 'SRCC_PEDIDO'
,		wiseitstatus.dscstatus 'Wiseit_RCC' 
,		fatabstatus.dscstatus 'Fato_Abastecimento'
from (
	select 

	dataexec
	,[SRCC_PEDIDO]
	,[Wiseit_RCC]
	,[Fato_Abastecimento]


	from 

	(
		SELECT 
 
		dataexec
		,[JobName]
		,run_status
 
		FROM cte_jobs 

	) src

	PIVOT

	(
		sum(run_status) FOR [JobName] IN (
			[SRCC_PEDIDO]
			, [Wiseit_RCC]
			, [Fato_Abastecimento]
		)
	) pvt

) z

left join	##TMP_STATUSJOBS srccstatus

on			z.SRCC_PEDIDO = srccstatus.run_status

left join	##TMP_STATUSJOBS wiseitstatus

on			z.[Wiseit_RCC] = wiseitstatus.run_status

left join	##TMP_STATUSJOBS fatabstatus

on			z.[Fato_Abastecimento] = fatabstatus.run_status

order by	cast(dataexec as int) desc

-----------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------


SELECT 
convert(varchar(10),cast(convert(varchar(10),sh.run_date) as datetime) ,103) dataexec, 
STUFF(STUFF(RIGHT(REPLICATE('0', 6) +  CAST(sh.run_time as varchar(6)), 6), 3, 0, ':'), 6, 0, ':') 'hr_inicio',
STUFF(STUFF(STUFF(RIGHT(REPLICATE('0', 8) + CAST(sh.run_duration as varchar(8)), 8), 3, 0, ':'), 6, 0, ':'), 9, 0, ':') 'duracao_exec (DD:HH:MM:SS)',
CASE WHEN sj.name = 'SHV_MIS_CARGA_SRCC_PEDIDO' THEN 'SHV_MIS_CARGA_SRCC_PEDIDO'
WHEN sj.name = 'SHV_MIS_Wiseit_RCC' THEN 'SHV_MIS_Wiseit_RCC'
WHEN sj.name = 'SHV- PKG-Carregar_DW_Fatos_Abastecimento04' THEN 'Carregar_DW_Fatos_Abastecimento04'
END Job ,
sh.step_name Step,
sh.message LogExecucao,
case 
when sh.message like '%Failure sending mail%' then 'com êxito'
when sh.run_status = '0' then 'falha'
when sh.run_status = '1' then 'com êxito'
when sh.run_status = '2' then 'repetir'
when sh.run_status = '3' then 'cancelado'
when sh.run_status = '4' then 'em andamento' 
else 'Não Identificado'
end status_exec
FROM msdb.dbo.sysjobs sj
JOIN msdb.dbo.sysjobhistory sh
ON sj.job_id = sh.job_id
where sj.name in 
(
'SHV_MIS_CARGA_SRCC_PEDIDO',
'SHV_MIS_Wiseit_RCC',
'SHV- PKG-Carregar_DW_Fatos_Abastecimento04'
)
and step_name <> '(Job outcome)'

order by cast(sh.run_date as int) desc, cast(sh.run_time as int) desc

