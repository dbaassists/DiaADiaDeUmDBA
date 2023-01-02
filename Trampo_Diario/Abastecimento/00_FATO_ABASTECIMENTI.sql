
IF object_id ( 'tempdb..##TMP_Fato_Abastecimento' ) IS NOT NULL
DROP TABLE ##TMP_Fato_Abastecimento
GO

CREATE TABLE [##TMP_Fato_Abastecimento](
	[Id_FatoAbastecimento] [bigint] IDENTITY(1,1) NOT NULL,
	[Id_Silo] [bigint] NULL,
	[Id_DimSilo] [bigint] NULL,	
	[Id_DimItinerario] [bigint] NULL,
	[Id_DimSetorAtividade] [bigint] NULL,
	[Id_DimStrOrgFiscal] [bigint] NULL,
	[Id_OrgFiscalCentro] [bigint] NULL,
	[Id_DimTempoPrevisaoEntrega] [bigint] NULL,	
	[Id_ClienteRecebMercadoria] [bigint] NULL,		
	[Id_DimClienteRecebedor] [bigint] NULL,	
	[Id_ClienteEmissorOrdem] [bigint] NULL,		
	[Id_DimClienteEmissor] [bigint] NULL,		
	[Id_DimTempoAbastecimento] [bigint] NULL,
	[CodDocVenda] [varchar](10) NOT NULL,
	[NumItemDocVenda] [decimal](6, 0) NULL,
	[CodRelatorio] [varchar](10) NULL,
	[CodItemRelatorio] VARCHAR(10),
	[FlgElegivelOTIF] [char](1) NULL,
	[NomResp] [varchar](12) NULL,
	[FlgOTIF] [int] NULL,
	[QtdEstoque] [decimal](23, 3) NULL,
	[QtdAbastecida] [decimal](23, 3) NULL,
	[PercNivelTanque] [decimal](23, 3) NULL,
	[DthBaixaColetor] [datetime] NULL,
	[DthAlteracaoDW] [datetime] NOT NULL,
	[DthInclusaoDW] [datetime] NOT NULL,
	[HrAbastecimento] [varchar](10) NULL,
 CONSTRAINT [PK_TEMP_Fato_Abastecimento] PRIMARY KEY CLUSTERED 
(
	[Id_FatoAbastecimento] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 95) ON [PRIMARY]
) ON [PRIMARY]


------------------------------------------------------------------------------

IF object_id ( 'tempdb..##TMP_TB_Fato_Abastecimento' ) IS NOT NULL
DROP TABLE ##TMP_TB_Fato_Abastecimento
GO

CREATE TABLE ##TMP_TB_Fato_Abastecimento
(
	[Id_DimSilo] [bigint] NULL,
	[Id_DimItinerario] [bigint] NULL,
	[Id_DimSetorAtividade] [bigint] NULL,
	[Id_DimStrOrgFiscal] [bigint] NULL,		
	[Id_DimTempoPrevisaoEntrega] [bigint] NULL,
	[Id_DimTempoAbastecimento] [bigint] NULL,
	[CodDocVenda] [varchar](10) NOT NULL,
	[NumItemDocVenda] [decimal](6, 0) NULL,
	[CodRelatorio] [varchar](10) NULL,
	[CodItemRelatorio] VARCHAR(10),
	[FlgOTIF] [int] NULL,
	[QtdEstoque] [decimal](23, 3) NULL,
	[QtdAbastecida] [decimal](23, 3) NULL,
	[PercNivelTanque] [decimal](23, 3) NULL,
	[DthAlteracaoDW] [datetime] NOT NULL
)
GO

CREATE NONCLUSTERED INDEX [IX_TMP_TB_Fato_Abastecimento] ON ##TMP_TB_Fato_Abastecimento (CodDocVenda, NumItemDocVenda, CodRelatorio)
GO

----------------------------------------------------------------------------------

IF OBJECT_ID ('tempdb..##FATURA_ESTORNO') IS NOT NULL
DROP TABLE ##FATURA_ESTORNO

select FATURA_ESTORNO.CodDFEstornado 
INTO ##FATURA_ESTORNO
from SCH_ODS.TB_TransacaoFatura_Agrd FATURA_ESTORNO 
where FATURA_ESTORNO.CodDFEstornado <> '' 

CREATE NONCLUSTERED INDEX [IXNCL_FATURA_ESTORNO] ON ##FATURA_ESTORNO (CodDFEstornado);



IF OBJECT_ID('tempdb..##_ExerciciosAbastecimento') IS NOT NULL
DROP TABLE ##_ExerciciosAbastecimento;

CREATE TABLE ##_ExerciciosAbastecimento
(
AnoMes int 
);

INSERT INTO ##_ExerciciosAbastecimento (AnoMes)

SELECT AnoMes
FROM SGBDW.SCH_DW.Dim_Exercicio
WHERE AnoMes = LEFT(CONVERT(VARCHAR(10), DATEADD(MONTH,-?,GETDATE()),112),6);

if OBJECT_ID ('tempdb..##result_dados_DCR') is not null  
drop table ##result_dados_DCR;    

SELECT distinct     
 d.CodRelatorio 
,d.coditem
,d.CodDocumentoSD  
,d.CodItemSD  

, c.Id_Cliente  
, c.Id_ClienteSilo  
, c.CodOrdenacao  
, c.CodSilo   

into ##result_dados_DCR    

FROM SGBODS.SCH_ODS.TB_TransacaoDataCollationItem_Agrd d

inner join SCH_ODS.TB_TransacaoDataCollationCabecalho_Agrd f with(nolock)  

on f.codrelatorio = d.codrelatorio  and CodStatusAtualizacao in ('D', 'E')   

inner join sgbods.sch_ods.tb_transacaoordemvenda_agrd ov 

on d.CodDocumentoSD = ov.CodDocVenda

and d.CodItemSD = ov.NumItemDocVenda

left join SCH_ODS.TB_ClienteSilo c WITH(NOLOCK)  on c.Id_ClienteSilo = ov.Id_ClienteSiloRecProduto

create nonclustered index [IX_NCL_01] ON ##result_dados_DCR (CodRelatorio, CodDocumentoSD, CodItemSD);


------------------------------------------------------------------------

DELETE		FATO 
FROM		[SCH_DW].[Fato_Abastecimento] FATO WITH(NOLOCK) 
INNER JOIN	[SCH_DW].[Dim_Tempo] DT WITH(NOLOCK) 
on			FATO.Id_DimTempoAbastecimento = DT.Id_DimTempo 
WHERE		DT.AnoMes >= (SELECT AnoMes FROM ##_ExerciciosAbastecimento EXERABAST WITH(NOLOCK))


------------------------------------------------------------------------


SELECT DISTINCT

OV_AGRD.CodDocVenda
,OV_AGRD.NumItemDocVenda
,OV_AGRD.NomStatusRecusa
,OV_AGRD.Id_Itinerario
,z.Id_ClienteSilo Id_ClienteSiloRecProduto
,OV_AGRD.Id_SetorAtividade
,OV_AGRD.Id_CategoriaDocItem
,OV_AGRD.NomResp
,DCI_Agrd.CodRelatorio
,DCI_Agrd.CodItem
,FATURA.DthIndiceFat DthAbastecimento
,DCI_Agrd.QtdEstque QtdEstoque
,FATURA.VlrPesoLiquido QtdAbastecida
,DCI_Agrd.QtdPerc PercNivelTanque
,DCI_Agrd.Id_OrgFiscalCentro
,DCI_Agrd.Id_Cliente
,DCI_Agrd.CodTanque
,DCI_Agrd.HraIniciar HrAbastecimento


,OVC_Agrd.DthDivisaoRemessa
,OVC_Agrd.NomStatusOrdemVenda 
,OVC_Agrd.Id_ClienteEmissorOrdem

,fat_agrd.CodDocFaturamento
,fat_agrd.CodItemDocFat
,fat_agrd.DthIndiceFat
,fat_agrd.CodDFEstornado
,fat_agrd.Id_ClienteRecebFatura Id_ClienteRecebFaturaFat 

,tipo_doc.Id_TipoDocFat

--,isnull(dataBaixa.DthBaixaColetor,dataBaixa2.DthBaixaColetor) DthBaixaColetor

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

--LEFT JOIN	SCH_ODS.TB_TransacaoDataCollationColetor dataBaixa
--on			DCI_Agrd.CodDocumentoSD = dataBaixa.CodRelatorio
--AND			DCI_Agrd.CodItemSD = dataBaixa.CodItem

LEFT JOIN	( select 

dataBaixa2.CodRelatorio
,dataBaixa2.CodItem
,dataBaixa2.CodTanque
,dataBaixa2.Id_Cliente
,max(dataBaixa2.DthBaixaColetor) DthBaixaColetor

from SCH_ODS.TB_TransacaoDataCollationColetor dataBaixa2

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

--and NomStatusOrdemVenda = 'Atendida'

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
--and			DCR.Id_PlacaVeiculo is not null
and			CabNota.FlagEstornado <> 'X'

) nota_fiscal_cab

on nota_fiscal.CodDoc = nota_fiscal_cab.CodDoc

WHERE		1=1
AND LEFT(CONVERT(VARCHAR(10), FATURA.DthIndiceFat ,112),6) >= ( SELECT AnoMes FROM ##_ExerciciosAbastecimento )
and DCI_Agrd.Qtd <> 0
and FlagEstornado <> 'X'
and	not EXISTS ( select * from ##FATURA_ESTORNO FATURA_ESTORNO where FATURA_ESTORNO.CodDFEstornado = FATURA.CodDocFaturamento )

---------------------------------------------------------------------

DELETE A FROM SGBDW.SCH_DW.Fato_Abastecimento a
WHERE Id_FatoAbastecimento IN (

select a.Id_FatoAbastecimento

from SGBDW.SCH_DW.Fato_Abastecimento a
inner join SGBDW.SCH_DW.Dim_Tempo b
on a.Id_DimTempoAbastecimento = b.Id_DimTempo

left join SGBDW.SCH_DW.Dim_Cliente c
on a.Id_DimClienteRecebedor = c.Id_DimCliente
left join SGBDW.SCH_DW.Dim_Silo d
on a.Id_DimSilo = d.Id_DimSilo
left join SGBDW.SCH_DW.Dim_OrgFiscal e
on a.Id_DimStrOrgFiscal = e.Id_DimStrOrgFiscal

where  1=1

and a.DthBaixaColetor is null

and (a.QtdEstoque = cast( 0  as decimal(23,3)) and a.PercNivelTanque = cast( 0  as decimal(23,3)))

) 


------------------------------------------------------------------------------------------------------------------------------------------------------------------

delete fato

from sgbdw.sch_dw.fato_abastecimento fato

where exists (

select ori.CodRelatorio, ori.CodDocVenda
from sgbdw.sch_dw.fato_abastecimento ori
where 1=1
and (fato.CodRelatorio= ori.CodRelatorio
and fato.CodDocVenda = ori.CodDocVenda)
group by ori.CodRelatorio, ori.CodDocVenda
having count(1) > 1

)

and DthBaixaColetor is null
