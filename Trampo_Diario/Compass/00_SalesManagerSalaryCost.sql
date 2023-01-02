select * 
from 

(

SELECT

'4 - Sales Manager Salary Cost' Description,
'Actual' Scenario,
d.ano AS Year,  
d.AnoMes YearMonth,
round(Sum(a.Vlr_Movimento), 2)/4 AS Value

FROM 
           sgbconvmis..Fato_ResultadoGerencial    a 
INNER JOIN sgbdw.sch_dw.dim_centrocusto b on a.id_dimcentrocusto=b.id_dimcentrocusto 
INNER JOIN sgbdw.sch_dw.dim_contacontabil c  on a.id_dimcontacontabil=c.id_dimcontacontabil 
INNER JOIN sgbdw.sch_dw.dim_exercicio d ON a.id_dimexercicio=d.id_dimexercicio
INNER JOIN sgbdw.sch_dw.dim_cenario e on a.id_dimcenario = e.id_dimcenario and left(e.nomcenario,3) = 'RC_'

WHERE
   1=1
   AND c.codcontacontabil IN (
'511000','511002','511003','511004','511005','511006','511007','511008','511000','511101','511102','511100','511201','511202','511204','511205',
'511206','511200','511301','511302','511303','511305','511306','511307','511308','511309','511310','511300','512000','512003','512004','512005',
'512006','512007','512008','512010','512011','512015','512018','512000','516000','516002','516004','516000','517000','517005','517000','523000',
'523001','523002','523003','523000','530000','530001','530009','530000','531000','531001','531003','531005','531006','531007','531010','531000'
)
AND a.codledger = '2L' 
AND b.Codcentrocusto in (921) 
and d.ano >= 2018

GROUP BY
    d.ano
    ,d.AnoMes
    
union all    
    
SELECT

'4 - Sales Manager Salary Cost' Description,
'Budget' Scenario,
d.ano AS Year,  
d.AnoMes YearMonth,
round(Sum(a.Vlr_Movimento), 2)/4 AS Value

FROM 
           sgbconvmis..Fato_ResultadoGerencial    a 
INNER JOIN sgbdw.sch_dw.dim_centrocusto b on a.id_dimcentrocusto=b.id_dimcentrocusto 
INNER JOIN sgbdw.sch_dw.dim_contacontabil c  on a.id_dimcontacontabil=c.id_dimcontacontabil 
INNER JOIN sgbdw.sch_dw.dim_exercicio d ON a.id_dimexercicio=d.id_dimexercicio
INNER JOIN sgbdw.sch_dw.dim_cenario e on a.id_dimcenario = e.id_dimcenario and left(e.nomcenario,3) = 'RCO'

WHERE
   1=1
   AND c.codcontacontabil IN (
'511000','511002','511003','511004','511005','511006','511007','511008','511000','511101','511102','511100','511201','511202','511204','511205',
'511206','511200','511301','511302','511303','511305','511306','511307','511308','511309','511310','511300','512000','512003','512004','512005',
'512006','512007','512008','512010','512011','512015','512018','512000','516000','516002','516004','516000','517000','517005','517000','523000',
'523001','523002','523003','523000','530000','530001','530009','530000','531000','531001','531003','531005','531006','531007','531010','531000'
)
AND a.codledger = '2L' 
AND b.Codcentrocusto in (921) 
and d.ano >= 2018

GROUP BY
    d.ano
    ,d.AnoMes  
    
union all
    
SELECT

'4 - Sales Manager Salary Cost CC960' Description,
'Actual' Scenario,
d.ano AS Year,  
d.AnoMes YearMonth,
round(Sum(a.Vlr_Movimento), 2) * 0.132 AS Value

FROM 
           sgbconvmis..Fato_ResultadoGerencial    a 
INNER JOIN sgbdw.sch_dw.dim_centrocusto b on a.id_dimcentrocusto=b.id_dimcentrocusto 
INNER JOIN sgbdw.sch_dw.dim_contacontabil c  on a.id_dimcontacontabil=c.id_dimcontacontabil 
INNER JOIN sgbdw.sch_dw.dim_exercicio d ON a.id_dimexercicio=d.id_dimexercicio
INNER JOIN sgbdw.sch_dw.dim_cenario e on a.id_dimcenario = e.id_dimcenario and left(e.nomcenario,3) = 'RC_'

WHERE
   1=1
   AND c.codcontacontabil IN (
'511000','511002','511003','511004','511005','511006','511007','511008','511000','511101','511102','511100','511201','511202','511204','511205',
'511206','511200','511301','511302','511303','511305','511306','511307','511308','511309','511310','511300','512000','512003','512004','512005',
'512006','512007','512008','512010','512011','512015','512018','512000','516000','516002','516004','516000','517000','517005','517000','523000',
'523001','523002','523003','523000','530000','530001','530009','530000','531000','531001','531003','531005','531006','531007','531010','531000'
)
AND a.codledger = '2L' 
AND b.Codcentrocusto in (960) 
and d.anomes >= 202107

GROUP BY
    d.ano
    ,d.AnoMes
    
union all    
    
SELECT

'4 - Sales Manager Salary Cost CC960' Description,
'Budget' Scenario,
d.ano AS Year,  
d.AnoMes YearMonth,
round(Sum(a.Vlr_Movimento), 2) * 0.132 AS Value

FROM 
           sgbconvmis..Fato_ResultadoGerencial    a 
INNER JOIN sgbdw.sch_dw.dim_centrocusto b on a.id_dimcentrocusto=b.id_dimcentrocusto 
INNER JOIN sgbdw.sch_dw.dim_contacontabil c  on a.id_dimcontacontabil=c.id_dimcontacontabil 
INNER JOIN sgbdw.sch_dw.dim_exercicio d ON a.id_dimexercicio=d.id_dimexercicio
INNER JOIN sgbdw.sch_dw.dim_cenario e on a.id_dimcenario = e.id_dimcenario and left(e.nomcenario,3) = 'RCO'

WHERE
   1=1
   AND c.codcontacontabil IN (
'511000','511002','511003','511004','511005','511006','511007','511008','511000','511101','511102','511100','511201','511202','511204','511205',
'511206','511200','511301','511302','511303','511305','511306','511307','511308','511309','511310','511300','512000','512003','512004','512005',
'512006','512007','512008','512010','512011','512015','512018','512000','516000','516002','516004','516000','517000','517005','517000','523000',
'523001','523002','523003','523000','530000','530001','530009','530000','531000','531001','531003','531005','531006','531007','531010','531000'
)
AND a.codledger = '2L' 
AND b.Codcentrocusto in (960) 
and d.anomes >= 202107

GROUP BY
    d.ano
    ,d.AnoMes   

) a

where a.YearMonth  = 202003