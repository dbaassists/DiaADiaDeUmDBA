-- select count(1) FROM _TMP_FatoMovContabilResultado a WITH(NOLOCK)

/*

2016	40741127
2017	15206263
2015	6581219

*/

/*

SELECT COUNT(1) TOTAL -- 13653761
FROM SGBDW.SCH_DW.Fato_MovContabilResultado WITH(NOLOCK)


SELECT		CONTACONTABIL.CodContaContabil
,			FATO.CodLedger 
,			SUM(FATO.Vlr_Movimento) Vlr_Movimento
,			'INSERT INTO ##TMP_Fato_MovContabilResultado (CodContaContabil, CodLedger, Vlr_Movimento) VALUES (' + CHAR(39) + 
CONTACONTABIL.CodContaContabil + CHAR(39) + ',' + CHAR(39) + FATO.CodLedger + CHAR(39) +  ',' + CHAR(39) +  CONVERT(VARCHAR(50),ISNULL(SUM(FATO.Vlr_Movimento),0)) + CHAR(39) + ');'

FROM		SGBDW.SCH_DW.Fato_MovContabilResultado FATO WITH(NOLOCK)
INNER JOIN	SGBDW.SCH_DW.Dim_ContaContabil CONTACONTABIL WITH(NOLOCK)
ON			FATO.Id_DimContaContabil = CONTACONTABIL.Id_ContaContabil
GROUP BY	CONTACONTABIL.CodContaContabil
,			FATO.CodLedger 

ORDER BY	CONTACONTABIL.CodContaContabil
,			FATO.CodLedger 

*/

/***************************** CHECK POR CONTA ***************************************************/

select anomes, 
SUM(case when codledger = '0L' THEN TOTAL ELSE 0 END) '0L'
,SUM(case when codledger = '1L' THEN TOTAL ELSE 0 END) '1L'
,SUM(case when codledger = '2L' THEN TOTAL ELSE 0 END) '2L'
, CASE WHEN SUM(case when codledger = '0L' THEN TOTAL ELSE 0 END) = SUM(case when codledger = '1L' THEN TOTAL ELSE 0 END)
AND  SUM(case when codledger = '0L' THEN TOTAL ELSE 0 END) = SUM(case when codledger = '2L' THEN TOTAL ELSE 0 END)  THEN 'VERDADEIRO'
ELSE 'FALSO' END COMPARACAO
from (

select b.AnoMes, a.CodLedger, SUM(vlr_movimento) TOTAL FROM _TMP_FatoMovContabilResultado a WITH(NOLOCK)
inner join SGBDW.SCH_DW.Dim_Exercicio b
on a.Id_DimExercicio = b.Id_DimExercicio

where Id_DimContaContabil = 495

group by b.AnoMes, a.CodLedger

)A

GROUP BY ANOMES
--order by 1 --,2

/***************************** CHECK POR CONTA ***************************************************/

select a.CodLedger, SUM(vlr_movimento) TOTAL FROM TMP_FatoMovContabilResultado a WITH(NOLOCK)
inner join SGBDW.SCH_DW.Dim_Exercicio b
on a.Id_DimExercicio = b.Id_DimExercicio

where Id_DimContaContabil = 495


group by a.CodLedger


/***************************** CHECK GERAL *******************************************************/

select b.AnoMes,a.Id_DimContaContabil,c.CodContaContabil, a.CodLedger,a.Vlr_Movimento Total
from sgbdw.SCH_DW.Fato_MovContabilResultado  a with(nolock)
inner join SGBDW.SCH_DW.Dim_Exercicio b  with(nolock)
on a.Id_DimExercicio = b.Id_DimExercicio

inner join sgbdw.SCH_DW.Dim_ContaContabil c  with(nolock)
on a.Id_DimContaContabil = c.Id_DimContaContabil
and CodContaContabil = 555017
--where a.Id_DimContaContabil = 966

--group by a.Id_DimContaContabil,c.CodContaContabil, CodLedger, b.AnoMes  
order by c.CodContaContabil, CodLedger, b.AnoMes 

select * 
from sgbdw.SCH_DW.Fato_MovContabilResultado  a with(nolock)