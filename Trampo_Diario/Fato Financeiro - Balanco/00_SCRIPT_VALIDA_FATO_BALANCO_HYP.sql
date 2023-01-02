	SELECT		'HYP' ORIGEM
,			exercicio.AnoMes
,            contaContabil.CodContaContabil 
,			fato.CodLedger 
,			cast( exercicio.AnoMes  as varchar(10)) + '_' + cast(contaContabil.CodContaContabil as varchar(10)) + '_' + fato.CodLedger  ANOMES_CONTA
,            CAST(SUM(fato.VlrSaldoInicial) AS DECIMAL(23,3)) VlrSaldoInicial 

,            CAST(SUM(fato.Vlr_Movimento_Saldo) AS DECIMAL(23,3)) Vlr_Movimento_Saldo

,            CAST(SUM(fato.VlrSaldoFinal) AS DECIMAL(23,3)) VlrSaldoFinal

FROM         SGBDW.SCH_DW.Fato_MovContabilBalancoSaldo fato

INNER JOIN   SGBDW.SCH_DW.Dim_ContaContabil contaContabil
ON                  fato.Id_DimContaContabil = contaContabil.Id_DimContaContabil 
and CodContaContabil in (
223001,
223003,
123001,
123002
)

INNER JOIN   SGBDW.SCH_DW.Dim_Exercicio exercicio 
ON                  fato.Id_DimExercicio = exercicio.Id_DimExercicio 

WHERE        1=1

AND          (exercicio.AnoMes >= '201501') -- and C.AnoMes <= '202006')

and CodLedger = '2L'

GROUP BY     exercicio.AnoMes
,            contaContabil.CodContaContabil 
,			cast( exercicio.AnoMes  as varchar(10)) + '_' + cast(contaContabil.CodContaContabil as varchar(10)) + '_' + fato.CodLedger
,			fato.CodLedger 

ORDER BY 3,2


SELECT B.CodContaContabil 
,A.[NumExercicio/Periodo]
,A.CodLedger
,SUM(A.VlrMontanteMIComSinal)  VlrMontanteMIComSinal
FROM SGBODS.SCH_ODS.VW_TransacaoRazaoPartidaIndiv A

INNER JOIN SGBODS.SCH_ODS.TB_ContaContabil B

ON A.Id_ContaContabil = B.Id_ContaContabil 

AND B.CodContaContabil IN (
'0000223001',
'0000223003',
'0000123001',
'0000123002'
)

AND A.[NumExercicio/Periodo] = 2021013

GROUP BY B.CodContaContabil 
,A.[NumExercicio/Periodo]
,A.CodLedger

/*

SELECT * 
FROM SGBODS.SCH_ODS.TB_ContaContabil
WHERE CodContaContabil IN (
'0000223001',
'0000223003',
'0000123001',
'0000123002'
)

*/