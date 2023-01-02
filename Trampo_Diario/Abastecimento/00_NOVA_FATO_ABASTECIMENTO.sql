/*

IF OBJECT_ID ('tempdb..##FATURA_ESTORNO') IS NOT NULL
DROP TABLE ##FATURA_ESTORNO

select FATURA_ESTORNO.SFAKN CodDFEstornado 
INTO ##FATURA_ESTORNO
from SGBODS.SCH_ODS.TB_VBRK FATURA_ESTORNO 
where FATURA_ESTORNO.SFAKN <> '' 

---------------------------------------------------------------

*/

drop table ##result_dados_DCR

SELECT distinct     
-- d.CodRelatorio 
d.BERNR CodRelatorio
--,d.coditem
,d.POSNR coditem
--,d.CodDocumentoSD 
,d.VBELN CodDocumentoSD
--,d.CodItemSD  
,d.VPOSN CodItemSD
--, c.Id_Cliente  
,cltsilo.KUNNR Id_Cliente
--, c.Id_ClienteSilo  
--, c.CodOrdenacao  
,cltsilo.SEQNR CodOrdenacao
--, c.CodSilo 
,cltsilo.SOCNR CodSilo
,ov.erdat
into ##result_dados_DCR 
--select count( distinct d.BERNR , d.POSNR)

--SELECT COUNT(1) 

FROM SGBODS.SCH_ODS.TB_MO_RUP d --SGBODS.SCH_ODS.TB_TransacaoDataCollationItem_Agrd d

inner join SGBODS.SCH_ODS.TB_MO_RUK f --SCH_ODS.TB_TransacaoDataCollationCabecalho_Agrd f with(nolock)  

on f.BERNR = d.BERNR and VBKZ in ('D', 'E') 

inner join SGBODS.SCH_ODS.TB_VBAP ov

on d.VBELN = ov.VBELN

and d.POSNR = ov.POSNR

--------------------------------------

left join SGBODS.SCH_ODS.OIISOCIKN cltsilo

on d.KUNWE = cltsilo.KUNNR

AND d.OII_TANKID = cltsilo.SEQNR 

left join SGBODS.SCH_ODS.TB_OIISOCK silocap

ON silocap.SOCNR = cltsilo.SOCNR

order by ov.erdat desc

--left join SCH_ODS.TB_ClienteSilo c WITH(NOLOCK)  

--on c.Id_ClienteSilo = ov.Id_ClienteSiloRecProduto

--create nonclustered index [IX_NCL_01] ON ##result_dados_DCR (CodRelatorio, CodDocumentoSD, CodItemSD);


--AND PSTYV in ('ZGRA','ZGAA', 'ZLP3', 'ZLP4', 'ZGON', 'ZLON')
--AND MATNR = '000000000000096809'

select VBELN , POSNR
from SGBODS.SCH_ODS.TB_VBAP ov

except

select ov.CodDocVenda , ov.NumItemDocVenda
from sgbods.sch_ods.tb_transacaoordemvenda_agrd  ov



select ov.CodDocVenda , ov.NumItemDocVenda
from sgbods.sch_ods.tb_transacaoordemvenda_agrd  ov
where convert(varchar(6),DthIndiceFat,112) = 202205 
except
select VBELN , POSNR
from SGBODS.SCH_ODS.TB_VBAP ov

select *
from sgbods.sch_ods.tb_transacaoordemvenda_agrd  ov
WHERE CodDocVenda = '0031575710'

-------------------------------------------------------------------------------------------------------------------



SELECT DISTINCT

OV_AGRD.VBELN CodDocVenda
,OV_AGRD.POSNR NumItemDocVenda
--,OV_AGRD.NomStatusRecusa

,OV_AGRD.ROUTE Id_Itinerario
,OV_AGRD.SPART Id_SetorAtividade
,OV_AGRD.PSTYV Id_CategoriaDocItem
,OV_AGRD.ERNAM NomResp

,OVC_Agrd.VDATU DthDivisaoRemessa
--,OVC_Agrd.NomStatusOrdemVenda 
,OVC_Agrd.KUNNR Id_ClienteEmissorOrdem


,DCI_Agrd.BERNR CodRelatorio
,DCI_Agrd.POSNR CodItem
,DCI_Agrd.GAUGE_QTY QtdEstoque
,cast((CAST(DCI_Agrd.GAUGE_QTY AS float) * 100)/ NULLIF(CAST(silocap.KAPAZ AS float),0) as decimal(23,3)) PercNivelTanque
--,DCI_Agrd.WERKS Id_OrgFiscalCentro
--,DCI_Agrd.KUNNR Id_Cliente
,DCI_Agrd.OII_TANKID CodTanque
,DCI_Agrd.SZEIT HrAbastecimento


--,z.Id_ClienteSilo Id_ClienteSiloRecProduto

--,FATURA.FKDAT DthAbastecimento
,FATURA.NTGEW QtdAbastecida

,fat_agrd.VBELN CodDocFaturamento
,fat_agrd.POSNR CodItemDocFat
--,fat_agrd.FKDAT DthIndiceFat
--,fat_agrd.SFAKN CodDFEstornado
--,fat_agrd.Id_ClienteRecebFatura Id_ClienteRecebFaturaFat 

--,tipo_doc.Id_TipoDocFat

--,isnull(dataBaixa.DthBaixaColetor,dataBaixa2.DthBaixaColetor) DthBaixaColetor

,dataBaixa2.DthBaixaColetor DthBaixaColetor

--SELECT * -- COUNT(1)

FROM	SGBODS.SCH_ODS.TB_VBAP	OV_AGRD

-- SCH_ODS.TB_TransacaoOrdemVenda_Agrd OV_AGRD with(nolock)

INNER JOIN	SGBODS.SCH_ODS.TB_VBRP FATURA --SCH_ODS.TB_TransacaoFatura_Agrd FATURA WITH(NOLOCK)

ON			FATURA.AUBEL = OV_AGRD.VBELN
AND			FATURA.AUPOS = OV_AGRD.POSNR


INNER JOIN	SGBODS.SCH_ODS.TB_VBRK FATURA_ESTORNO --SCH_ODS.TB_TransacaoFatura_Agrd FATURA WITH(NOLOCK)

ON			FATURA_ESTORNO.VBELN = FATURA.VBELN
and			FATURA_ESTORNO.SFAKN = ''

	
INNER JOIN	SGBODS.SCH_ODS.TB_MO_RUP DCI_Agrd WITH(NOLOCK)  -- TB_TransacaoDataCollationItem_Agrd DCI_Agrd WITH(NOLOCK) 
ON			OV_AGRD.VBELN = DCI_Agrd.VBELN 
AND			OV_AGRD.POSNR = DCI_Agrd.VPOSN

INNER Join	SGBODS.SCH_ODS.TB_MO_RUK DCR WITH(NOLOCK) -- SCH_ODS.TB_TransacaoDataCollationCabecalho_Agrd DCR WITH(NOLOCK)
ON			DCR.BERNR			= DCI_Agrd.BERNR
--and			DCR.Id_PlacaVeiculo is not null -- => FALTA COLOCAR NO EXTRATOR

left join SGBODS.SCH_ODS.OIISOCIKN cltsilo

on DCI_Agrd.KUNWE = cltsilo.KUNNR

AND DCI_Agrd.OII_TANKID = cltsilo.SEQNR 

left join SGBODS.SCH_ODS.TB_OIISOCK silocap

ON silocap.SOCNR = cltsilo.SOCNR

LEFT JOIN	( 

select 

DCI_Agrd.BERNR CodRelatorio
,DCI_Agrd.POSNR CodItem
,dataBaixa2.SOCNR CodTanque
,DCI_Agrd.KUNWE Id_Cliente
,max(CONVERT(DATETIME, CAST(YEAR(ERDAT) AS VARCHAR) + '-' + RIGHT('00'+CAST(MONTH(ERDAT) AS VARCHAR),2) + '-' + RIGHT('00'+CAST(DAY(ERDAT) AS VARCHAR),2)
      + ' ' + ISNULL((SUBSTRING(ERZET, 1, 2) + ':' + SUBSTRING(ERZET, 3, 2) + ':' + RIGHT(ERZET, 2) + '.000'), '00:00:00.000')) ) DthBaixaColetor
 
from 

SGBODS.SCH_ODS.TB_MO_PR_CFTH dataBaixa2 --SCH_ODS.TB_TransacaoDataCollationColetor dataBaixa2

INNER JOIN SGBODS.SCH_ODS.TB_MO_RUP DCI_Agrd WITH(NOLOCK)  -- TB_TransacaoDataCollationItem_Agrd DCI_Agrd WITH(NOLOCK) 
ON			dataBaixa2.VBELN = DCI_Agrd.VBELN 
AND			dataBaixa2.POSNR = DCI_Agrd.VPOSN

group by DCI_Agrd.BERNR 
,DCI_Agrd.POSNR 
,dataBaixa2.SOCNR 
,DCI_Agrd.KUNWE 

)dataBaixa2

on			DCI_Agrd.BERNR = dataBaixa2.CodRelatorio
AND			DCI_Agrd.POSNR =		dataBaixa2.CodItem
AND			silocap.SOCNR =	dataBaixa2.CodTanque
AND			DCI_Agrd.KUNWE =	dataBaixa2.Id_Cliente

----------------------------------------------------------------------------

INNER JOIN	##result_dados_DCR z

on DCI_Agrd.BERNR = z.CodRelatorio
and  DCI_Agrd.VBELN  = z.CodDocumentoSD
and DCI_Agrd.VPOSN = z.CodItemSD

inner join SGBODS.SCH_ODS.TB_VBAK OVC_Agrd  WITH(NOLOCK) -- SCH_ODS.TB_TransacaoOrdemVendaCab_AGRD OVC_Agrd  WITH(NOLOCK)

on OV_AGRD.VBELN = OVC_Agrd.VBELN

--and NomStatusOrdemVenda = 'Atendida'

inner join SGBODS.SCH_ODS.TB_VBRP fat_agrd -- SCH_ODS.TB_TransacaoFatura_Agrd fat_agrd

on OV_AGRD.VBELN = fat_agrd.AUBEL

and  OV_AGRD.POSNR = fat_agrd.AUPOS

inner join (

	SELECT FKART Id_TipoDocFat, VBELN CodDocVenda 
	FROM SGBODS.SCH_ODS.TB_VBRK cabfatura -- SCH_ODS.TB_TransacaoFaturaCab_Agrd cabfatura

	WHERE FKART not in ('FAS','IGS','IVS','LGS','LRS','S1','S2','S3','SHR','S4','S5')

) tipo_doc

on fat_agrd.VBELN = tipo_doc.CodDocVenda

inner join (

SELECT Nota.REFKEY NomRefDocOrigem, Nota.DOCNUM CodDoc,Nota.REFITM CodItemRefOrigem,CabNota.CANCEL FlagEstornado 
FROM SGBODS.SCH_ODS.TB_J_1BNFLIN Nota -- SCH_ODS.TB_TransacaoNotaFiscal_Agrd Nota

INNER Join	SGBODS.SCH_ODS.TB_J_1BNFDOC CabNota -- sgbods.SCH_ODS.TB_TransacaoNotaFiscalCab_Agrd CabNota			
on			Nota.DOCNUM				= CabNota.DOCNUM

) nota_fiscal

on nota_fiscal.NomRefDocOrigem = fat_agrd.VBELN

and nota_fiscal.CodItemRefOrigem = fat_agrd.POSNR

inner join ( 

select CabNota.DOCNUM CodDoc
from SGBODS.SCH_ODS.TB_J_1BNFDOC  CabNota -- sgbods.SCH_ODS.TB_TransacaoNotaFiscalCab CabNota	
WHERE		1=1
--and			DCR.Id_PlacaVeiculo is not null
and			CabNota.CANCEL  <> 'X'

) nota_fiscal_cab

on nota_fiscal.CodDoc = nota_fiscal_cab.CodDoc

WHERE		1=1
--AND LEFT(CONVERT(VARCHAR(10), FATURA.DthIndiceFat ,112),6) >= ( SELECT AnoMes FROM ##_ExerciciosAbastecimento )
and CAST(FATURA.NTGEW AS float) <> 0
and nota_fiscal.FlagEstornado <> 'X'
and	not EXISTS ( select * from ##FATURA_ESTORNO FATURA_ESTORNO where FATURA_ESTORNO.CodDFEstornado = FATURA.VBELN )
AND			OV_AGRD.MATNR = '000000000000096809'
and			OV_AGRD.PSTYV in ('ZGRA','ZGAA', 'ZLP3', 'ZLP4', 'ZGON', 'ZLON')