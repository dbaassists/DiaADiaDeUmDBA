SELECT * 
FROM SGBODS.SCH_ODS.TB_MO_RUP dcritem



SELECT 
dcritem.BERNR	CodRelatorio
,dcritem.POSNR	NumItemRelatorio
,dcritem.GBSTA	NumStatusItem
,dcritem.VBELN	CodDocVenda
,dcritem.VPOSN  NumItemDocVenda
,dcritem.KUNWE CodClienteReceb
,dcritem.GAUGE_QTY QtdEstoque	
,dcritem.MENGE Qtd
, cast((CAST(dcritem.GAUGE_QTY AS float) * 100)/ NULLIF(CAST(silocap.KAPAZ AS float),0) as decimal(23,3)) QtdPerc
, dcritem.PSTYV CodTpoDocVenda
, cltsilo.SOCNR CodSilo
, cltsilo.SEQNR CodOrdenacao
, silocap.KAPAZ NumCapacMaxSilo

FROM SGBODS.SCH_ODS.TB_MO_RUP dcritem

left join SGBODS.SCH_ODS.OIISOCIKN cltsilo

on dcritem.KUNWE = cltsilo.KUNNR

AND dcritem.OII_TANKID = cltsilo.SEQNR 

left join SGBODS.SCH_ODS.TB_OIISOCK silocap

ON silocap.SOCNR = cltsilo.SOCNR

WHERE 1=1

AND dcritem.PSTYV in ('ZGRA','ZGAA', 'ZLP3', 'ZLP4', 'ZGON', 'ZLON')

AND  dcritem.BERNR = '1009175759'

AND dcritem.VBELN = '0031156437'

ORDER BY 1, 2

--656759
--SELECT * 
--FROM SGBODS.SCH_ODS.TB_MO_RUP dcritem
--WHERE KUNWE = '0003901451'
--VBELN = '0032095124'

--select * from SGBODS.SCH_ODS.OIISOCIKN cltsilo
--INNER JOIN SGBODS.SCH_ODS.TB_OIISOCK silocap
--ON silocap.SOCNR = cltsilo.SOCNR
--WHERE KUNNR = '0003901451'


SELECT * 
from SGBODS.SCH_ODS.TB_TransacaoDataCollationItem_Agrd item
WHERE 1=1
AND CodDocumentoSD = '0031156437'
and CodRelatorio = '1009175759'
-- SELECT * FROM SGBODS.SCH_ODS.TB_MO_RUP dcritem

--select * 
--from SGBODS.SCH_ODS.TB_ClienteSilo