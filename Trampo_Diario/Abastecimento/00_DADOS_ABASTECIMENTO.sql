IF OBJECT_ID ('tempdb..##FATURA_ESTORNO') IS NOT NULL
DROP TABLE ##FATURA_ESTORNO

select FATURA_ESTORNO.CodDFEstornado 
INTO ##FATURA_ESTORNO
from SCH_ODS.TB_TransacaoFatura_Agrd FATURA_ESTORNO 
where FATURA_ESTORNO.CodDFEstornado <> '' 

CREATE NONCLUSTERED INDEX [IXNCL_FATURA_ESTORNO] ON ##FATURA_ESTORNO (CodDFEstornado);

declare @meses int = -1

IF OBJECT_ID('tempdb..##_ExerciciosAbastecimento') IS NOT NULL
DROP TABLE ##_ExerciciosAbastecimento;

CREATE TABLE ##_ExerciciosAbastecimento
(
AnoMes int 
);

INSERT INTO ##_ExerciciosAbastecimento (AnoMes)

SELECT AnoMes
FROM SGBDW.SCH_DW.Dim_Exercicio
WHERE AnoMes = LEFT(CONVERT(VARCHAR(10), DATEADD(MONTH,@meses,GETDATE()),112),6);

if OBJECT_ID ('tempdb..##result_dados_DCR') is not null  
drop table ##result_dados_DCR;    

SELECT distinct     d.CodRelatorio ,d.coditem, c.Id_Cliente  , d.CodDocumentoSD  , d.CodItemSD  , c.Id_ClienteSilo  , c.CodOrdenacao  , c.CodSilo   

into ##result_dados_DCR    

FROM SGBODS.SCH_ODS.TB_TransacaoDataCollationItem_Agrd d

inner join SCH_ODS.TB_TransacaoDataCollationCabecalho_Agrd f with(nolock)  

on f.codrelatorio = d.codrelatorio  and CodStatusAtualizacao in ('D', 'E')   

inner join sgbods.sch_ods.tb_transacaoordemvenda_agrd ov 

on d.CodDocumentoSD = ov.CodDocVenda

and d.CodItemSD = ov.NumItemDocVenda

left join SCH_ODS.TB_ClienteSilo c WITH(NOLOCK)  on c.Id_ClienteSilo = ov.Id_ClienteSiloRecProduto

create nonclustered index [IX_NCL_01] ON ##result_dados_DCR (CodRelatorio, CodDocumentoSD, CodItemSD);

------------------------------------------------------------------------------------------------------------------------

SELECT DISTINCT

OV_AGRD.CodDocVenda
,OV_AGRD.NumItemDocVenda
,OV_AGRD.NomStatusRecusa
,DCI_Agrd.CodRelatorio
,DCI_Agrd.CodItem
,FATURA.DthIndiceFat DthAbastecimento
,FATURA.VlrPesoLiquido QtdAbastecida
,OVC_Agrd.NomStatusOrdemVenda 
,dataBaixa2.DthBaixaColetor DthBaixaColetor

FROM		SCH_ODS.TB_TransacaoOrdemVenda_Agrd OV_AGRD with(nolock)

INNER JOIN	SCH_ODS.TB_TransacaoFatura_Agrd FATURA WITH(NOLOCK)

ON			FATURA.CodDocVenda = OV_AGRD.CodDocVenda
AND			FATURA.CodItemDocVenda = OV_AGRD.NumItemDocVenda
and			FATURA.CodDFEstornado = ''

INNER JOIN	SCH_ODS.TB_Material MAT WITH(NOLOCK)
ON			OV_AGRD.Id_Material = MAT.Id_Material
AND			MAT.CodMaterial = '000000000000096809'

INNER Join	SCH_ODS.TB_CategoriaDocItemVenda Item				
on			OV_AGRD.Id_CategoriaDocItem = Item.Id_CategoriaDocItemVenda
and			Item.CodCategoriaDocItemVenda in ('ZGRA','ZGAA', 'ZLP3', 'ZLP4', 'ZGON', 'ZLON')

INNER JOIN	SCH_ODS.TB_TransacaoDataCollationItem_Agrd DCI_Agrd WITH(NOLOCK) 
ON			OV_AGRD.CodDocVenda = DCI_Agrd.CodDocumentoSD 
AND			OV_AGRD.NumItemDocVenda = DCI_Agrd.CodItemSD

INNER Join	SCH_ODS.TB_TransacaoDataCollationCabecalho_Agrd DCR WITH(NOLOCK)
ON			DCR.CodRelatorio			= DCI_Agrd.CodRelatorio
and			DCR.Id_PlacaVeiculo is not null

LEFT JOIN	( select 

dataBaixa2.CodRelatorio
,dataBaixa2.CodItem
,dataBaixa2.CodTanque
,dataBaixa2.Id_Cliente
,max(dataBaixa2.DthBaixaColetor) DthBaixaColetor
from 

SCH_ODS.TB_TransacaoDataCollationColetor dataBaixa2

group by dataBaixa2.CodRelatorio
,dataBaixa2.CodItem
,dataBaixa2.CodTanque
,dataBaixa2.Id_Cliente

)dataBaixa2

on			DCI_Agrd.CodRelatorio = dataBaixa2.CodRelatorio
AND			DCI_Agrd.CodItem =		dataBaixa2.CodItem
AND			DCI_Agrd.CodTanque =	dataBaixa2.CodTanque
AND			DCI_Agrd.Id_Cliente =	dataBaixa2.Id_Cliente

----------------------------------------------------------------------------

INNER JOIN	##result_dados_DCR z

on DCI_Agrd.CodRelatorio = z.CodRelatorio
and  DCI_Agrd.CodDocumentoSD  = z.CodDocumentoSD
and DCI_Agrd.CodItemSD = z.CodItemSD

inner join SCH_ODS.TB_TransacaoOrdemVendaCab_AGRD OVC_Agrd  WITH(NOLOCK)

on OV_AGRD.CodDocVenda = OVC_Agrd.CodDocVenda

inner join SCH_ODS.TB_TransacaoFatura_Agrd fat_agrd

on OV_AGRD.CodDocVenda = fat_agrd.CodDocVenda

and  OV_AGRD.NumItemDocVenda = fat_agrd.CodItemDocVenda

inner join (

	SELECT Id_TipoDocFat, CodDocVenda 
	FROM SCH_ODS.TB_TransacaoFaturaCab_Agrd cabfatura

	INNER join	sgbods.SCH_ODS.TB_TipoDocFaturamento TipoEstorno			
	on			cabfatura.Id_TipoDocFat	= TipoEstorno.Id_TipoDocFaturamento

	WHERE TipoEstorno.CodTipoDocFaturamento not in('FAS','IGS','IVS','LGS','LRS','S1','S2','S3','SHR','S4','S5')

) tipo_doc

on fat_agrd.CodDocFaturamento = tipo_doc.CodDocVenda

inner join (

SELECT Nota.NomRefDocOrigem, Nota.CodDoc,CodItemRefOrigem,CabNota.FlagEstornado 
FROM SCH_ODS.TB_TransacaoNotaFiscal_Agrd Nota

INNER Join	sgbods.SCH_ODS.TB_TransacaoNotaFiscalCab_Agrd CabNota			
on			Nota.CodDoc				= CabNota.CodDoc

) nota_fiscal

on nota_fiscal.NomRefDocOrigem = fat_agrd.CodDocFaturamento

and nota_fiscal.CodItemRefOrigem = REPLICATE('0',6-LEN(fat_agrd.CodItemDocFat)) + CONVERT(VARCHAR(6),fat_agrd.CodItemDocFat)

inner join ( 

select CabNota.CodDoc
from sgbods.SCH_ODS.TB_TransacaoNotaFiscalCab CabNota	
WHERE		1=1
and			CabNota.FlagEstornado <> 'X'

) nota_fiscal_cab

on nota_fiscal.CodDoc = nota_fiscal_cab.CodDoc

WHERE		1=1
AND LEFT(CONVERT(VARCHAR(10), FATURA.DthIndiceFat ,112),6) >= ( SELECT AnoMes FROM ##_ExerciciosAbastecimento )
and DCI_Agrd.Qtd <> 0
and FlagEstornado <> 'X'
and	not EXISTS ( select * from ##FATURA_ESTORNO FATURA_ESTORNO where FATURA_ESTORNO.CodDFEstornado = FATURA.CodDocFaturamento )