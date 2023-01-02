select * 
from 
(
SELECT

'35 - Marketing Department Salary Cost' Description,
d.ano AS Year, 
d.AnoMes YearMonth,
(round(Sum(a.Vlr_Movimento), 2) * 0.023) + 1700 AS Value,
'Actual' Scenario

FROM 
           sgbconvmis..Fato_ResultadoGerencial  a  
INNER JOIN sgbdw.sch_dw.dim_centrocusto b on a.id_dimcentrocusto=b.id_dimcentrocusto 
INNER JOIN sgbdw.sch_dw.dim_contacontabil c  on a.id_dimcontacontabil=c.id_dimcontacontabil 
INNER JOIN sgbdw.sch_dw.dim_exercicio d ON a.id_dimexercicio=d.id_dimexercicio
INNER JOIN sgbdw.sch_dw.dim_cenario e on a.id_dimcenario = e.id_dimcenario and left(e.nomcenario,3) = 'RC_'

WHERE
   1=1
AND a.codledger = '2L' 
and d.ano >= 2018
AND RIGHT(b.Codcentrocusto, 3) in (640) 
GROUP BY
    d.ano,d.AnoMes

union all

SELECT

'35 - Marketing Department Salary Cost' Description,
d.ano AS Year, 
d.AnoMes YearMonth,
(round(Sum(a.Vlr_Movimento), 2) * 0.023) + 1700 AS Value,
'Budget' Scenario

FROM 
           sgbconvmis..Fato_ResultadoGerencial  a  
INNER JOIN sgbdw.sch_dw.dim_centrocusto b on a.id_dimcentrocusto=b.id_dimcentrocusto 
INNER JOIN sgbdw.sch_dw.dim_contacontabil c  on a.id_dimcontacontabil=c.id_dimcontacontabil 
INNER JOIN sgbdw.sch_dw.dim_exercicio d ON a.id_dimexercicio=d.id_dimexercicio
INNER JOIN sgbdw.sch_dw.dim_cenario e on a.id_dimcenario = e.id_dimcenario and left(e.nomcenario,3) = 'RCO'

WHERE
   1=1
AND a.codledger = '2L' 
and d.ano >= 2018
AND RIGHT(b.Codcentrocusto, 3) in (640) 
GROUP BY
    d.ano,d.AnoMes

) a

where a.YearMonth = 201906


select * 
from 
(


SELECT

'36 - Marketing Department overhead' Description,
d.ano AS Year, 
d.AnoMes YearMonth,
round(Sum(a.Vlr_Movimento), 2) - (round(Sum(a.Vlr_Movimento), 2) * 1.028) AS Value,
'Actual' Scenario

FROM 
           sgbconvmis..Fato_ResultadoGerencial  a  
INNER JOIN sgbdw.sch_dw.dim_centrocusto b on a.id_dimcentrocusto=b.id_dimcentrocusto 
INNER JOIN sgbdw.sch_dw.dim_contacontabil c  on a.id_dimcontacontabil=c.id_dimcontacontabil 
INNER JOIN sgbdw.sch_dw.dim_exercicio d ON a.id_dimexercicio=d.id_dimexercicio
INNER JOIN sgbdw.sch_dw.dim_cenario e on a.id_dimcenario = e.id_dimcenario and left(e.nomcenario,3) = 'RC_'

WHERE
   1=1
AND a.codledger = '2L' 
and d.ano >= 2018
AND RIGHT(b.Codcentrocusto, 3) in (640) 
GROUP BY
    d.ano,d.AnoMes

union all

SELECT

'36 - Marketing Department overhead' Description,
d.ano AS Year, 
d.AnoMes YearMonth,
round(Sum(a.Vlr_Movimento), 2) - (round(Sum(a.Vlr_Movimento), 2) * 1.028) AS Value,
'Budget' Scenario

FROM 
           sgbconvmis..Fato_ResultadoGerencial  a  
INNER JOIN sgbdw.sch_dw.dim_centrocusto b on a.id_dimcentrocusto=b.id_dimcentrocusto 
INNER JOIN sgbdw.sch_dw.dim_contacontabil c  on a.id_dimcontacontabil=c.id_dimcontacontabil 
INNER JOIN sgbdw.sch_dw.dim_exercicio d ON a.id_dimexercicio=d.id_dimexercicio
INNER JOIN sgbdw.sch_dw.dim_cenario e on a.id_dimcenario = e.id_dimcenario and left(e.nomcenario,3) = 'RCO'

WHERE
   1=1
AND a.codledger = '2L' 
and d.ano >= 2018
AND RIGHT(b.Codcentrocusto, 3) in (640) 
GROUP BY
    d.ano,d.AnoMes

) a

where a.YearMonth = 201906