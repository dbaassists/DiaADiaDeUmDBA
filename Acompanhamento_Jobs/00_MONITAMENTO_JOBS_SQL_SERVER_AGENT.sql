
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
