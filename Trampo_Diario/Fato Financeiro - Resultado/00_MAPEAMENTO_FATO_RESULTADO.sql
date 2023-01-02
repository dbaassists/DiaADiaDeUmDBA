-- ESQLT-Criar Tabelas Temporárias - Processo FatoMovContabilResultado

/****** Object:  Table [dbo].[TMP_FatoMovContabilResultado]    Script Date: 05/10/2017 11:48:56 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TMP_FatoMovContabilResultado]') AND type in (N'U'))
DROP TABLE [dbo].[TMP_FatoMovContabilResultado]
GO

CREATE TABLE [dbo].[TMP_FatoMovContabilResultado](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[Id_DimCanal] [bigint] NULL,
	[Id_DimCanal_Cliente] [bigint] NULL,
	[Id_DimCenario] [bigint] NULL,
	[Id_DimCentroCusto] [bigint] NULL,
	[Id_DimCentroLucro] [bigint] NULL,
	[Id_DimContaContabil] [bigint] NULL,
	[Id_DimMoeda] [bigint] NULL,
	[Id_DimStrOrgFiscal] [bigint] NULL,
	[Id_DimExercicio] [bigint] NULL,
	[Id_DimElementoPEP] [bigint] NULL,
	[Id_DimOrdemInterna] [bigint] NULL,
	[Id_DimCliente] [bigint] NULL,
	[Vlr_Movimento] [decimal](23, 3) NULL,
	[CodLedger] [varchar](2) NULL,
	[TipoQueryInsercao] [tinyint] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

/****** Object:  Index [x]    Script Date: 05/10/2017 11:49:10 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[TMP_FatoMovContabilResultado]') AND name = N'x')
DROP INDEX [IX_NCL_TMP_FatoMovContabilResultado_AGREGACAO] ON [dbo].[TMP_FatoMovContabilResultado] WITH ( ONLINE = OFF )
GO

/****** Object:  Index [x]    Script Date: 05/10/2017 11:49:12 ******/
CREATE NONCLUSTERED INDEX [IX_NCL_TMP_FatoMovContabilResultado_AGREGACAO] ON [dbo].[TMP_FatoMovContabilResultado] 
(
	[Id_DimCanal] ASC,
	[Id_DimCenario] ASC,
	[Id_DimCentroCusto] ASC,
	[Id_DimCentroLucro] ASC,
	[Id_DimContaContabil] ASC,
	[Id_DimMoeda] ASC,
	[Id_DimStrOrgFiscal] ASC,
	[Id_DimExercicio] ASC,
	[Id_DimElementoPEP] ASC,
	[Id_DimOrdemInterna] ASC,
	[Id_DimCliente] ASC,
	[CodLedger] ASC,
	[TipoQueryInsercao] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO


---------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- INICIO CRIAÇÃO TAABELAS DE APOIO

-- ESQL- Criar Temporaria ExercicioPeriodo Contabil Resultado - ODS

IF OBJECT_ID('tempdb..##TMP_NumExercicioPeriodo_ContabilResultado') IS NOT NULL
	DROP TABLE ##TMP_NumExercicioPeriodo_ContabilResultado
create table ##TMP_NumExercicioPeriodo_ContabilResultado (
	Id bigint identity(1, 1) not null,
	Exercicio decimal (7, 0) null,
	constraint pk_##TMP_NumExercicioPeriodo_ContabilResultado primary key clustered (Id)
)
GO

create unique nonclustered index IX_UNQ_001 on ##TMP_NumExercicioPeriodo_ContabilResultado
(Exercicio) WITH (IGNORE_DUP_KEY = ON)
GO


IF OBJECT_ID('tempdb..##TMP_NumExercicioPeriodo_ContabilResultado_DW') IS NOT NULL
 DROP TABLE ##TMP_NumExercicioPeriodo_ContabilResultado_DW
create table ##TMP_NumExercicioPeriodo_ContabilResultado_DW (
 Id bigint identity(1, 1) not null primary key,
 Exercicio decimal (7, 0) null
)
GO

create unique nonclustered index IX_UNQ_001 on ##TMP_NumExercicioPeriodo_ContabilResultado_DW
(Exercicio)
GO

IF  OBJECT_ID('tempdb..##TMP_FatoMovContabilResultado') IS NOT NULL
	DROP TABLE ##TMP_FatoMovContabilResultado;
GO
CREATE TABLE ##TMP_FatoMovContabilResultado(
	Id bigint IDENTITY(1,1) NOT NULL primary key,
	Id_DimCanal bigint NULL,
	Id_DimCenario bigint NULL,
	Id_DimCentroCusto bigint NULL,
	Id_DimCentroLucro bigint NULL,
	Id_DimContaContabil bigint NULL,
	Id_DimMoeda bigint NULL,
	Id_DimStrOrgFiscal bigint NULL,
	Id_DimExercicio bigint NULL,
	Id_DimElementoPEP bigint NULL,
	Id_DimOrdemInterna bigint NULL,
	Id_DimCliente bigint NULL,
	Vlr_Movimento decimal(23, 3) NULL,
	CodLedger varchar(2) NULL,
	TipoQueryInsercao Tinyint NULL -- 1=Lenger Principal / 2=Lenger Secundario / 3=Partida Financeira
)
GO


/***********************************tempdb..##TB_ClasseCusto**************************************************************/
IF OBJECT_ID ('TEMPDB..##TB_ClasseCusto') IS NOT NULL
DROP TABLE ##TB_ClasseCusto;

CREATE TABLE ##TB_ClasseCusto
(
Id_ClasseCusto	BIGINT NOT NULL PRIMARY KEY
,CodClasseCusto	VARCHAR(10) NOT NULL
);


INSERT INTO ##TB_ClasseCusto
(Id_ClasseCusto, CodClasseCusto)
SELECT	ClasseCusto.Id_ClasseCusto, ClasseCusto.CodClasseCusto
FROM	SCH_ODS.TB_ClasseCusto ClasseCusto  WITH(NOLOCK)
WHERE	LEFT(CAST(ClasseCusto.CodClasseCusto AS INT),1)	= '5'
ORDER BY ClasseCusto.Id_ClasseCusto;


/***********************************tempdb..##tmp_IDs_ContaContabil**************************************************************/
		
IF OBJECT_ID('tempdb..##tmp_IDs_ContaContabil') IS NOT NULL
DROP TABLE ##tmp_IDs_ContaContabil;

CREATE TABLE ##tmp_IDs_ContaContabil (
Id				BIGINT IDENTITY(1, 1) NOT NULL PRIMARY KEY CLUSTERED,
Id_ContaContabil BIGINT NULL,
LeftCodContaContabil INT
)

INSERT INTO		##tmp_IDs_ContaContabil (Id_ContaContabil, LeftCodContaContabil)

SELECT			Id_ContaContabil
,				LEFT(CAST(ContaContabil.CodContaContabil AS INT),1) LeftCodContaContabil
FROM			SCH_ODS.TB_ContaContabil ContaContabil with(nolock)
WHERE			LEFT(CAST(ContaContabil.CodContaContabil AS INT),1) in('4', '3', '5', '6')

CREATE NONCLUSTERED INDEX ix_tmp_IDs_ContaContabil on ##tmp_IDs_ContaContabil (LeftCodContaContabil ASC);


IF OBJECT_ID('tempdb..##tmp_IDs_ContaContabil_01') IS NOT NULL
DROP TABLE ##tmp_IDs_ContaContabil_01;

CREATE TABLE ##tmp_IDs_ContaContabil_01 (
Id				BIGINT IDENTITY(1, 1) NOT NULL PRIMARY KEY CLUSTERED,
Id_ContaContabil BIGINT NULL,
LeftCodContaContabil INT
)

INSERT INTO		##tmp_IDs_ContaContabil_01 (Id_ContaContabil, LeftCodContaContabil)

SELECT			Id_ContaContabil
,				LEFT(CAST(ContaContabil.CodContaContabil AS INT),1) LeftCodContaContabil
FROM			SCH_ODS.TB_ContaContabil ContaContabil with(nolock)
WHERE			LEFT(CAST(ContaContabil.CodContaContabil AS INT),1) in( '4', '3', '6' )

CREATE NONCLUSTERED INDEX ix_tmp_IDs_ContaContabil_01 on ##tmp_IDs_ContaContabil_01 (LeftCodContaContabil ASC);



IF OBJECT_ID('tempdb..##tmp_IDs_ContaContabil_02') IS NOT NULL
DROP TABLE ##tmp_IDs_ContaContabil_02;

CREATE TABLE ##tmp_IDs_ContaContabil_02 (
Id				BIGINT IDENTITY(1, 1) NOT NULL PRIMARY KEY CLUSTERED,
Id_ContaContabil BIGINT NULL,
LeftCodContaContabil INT
)

INSERT INTO		##tmp_IDs_ContaContabil_02 (Id_ContaContabil, LeftCodContaContabil)

SELECT			Id_ContaContabil
,				LEFT(CAST(ContaContabil.CodContaContabil AS INT),1) LeftCodContaContabil
FROM			SCH_ODS.TB_ContaContabil ContaContabil with(nolock)
WHERE			LEFT(CAST(ContaContabil.CodContaContabil AS INT),1) in( '5' )

CREATE NONCLUSTERED INDEX ix_tmp_IDs_ContaContabil_02 on ##tmp_IDs_ContaContabil_02 (LeftCodContaContabil ASC);



/**************************************tempdb..##TB_ElementoPEP***************************************************************/

IF OBJECT_ID('tempdb..##TB_ElementoPEP') IS NOT NULL
DROP TABLE ##TB_ElementoPEP;

CREATE TABLE ##TB_ElementoPEP (
Id				BIGINT IDENTITY(1, 1) not null PRIMARY KEY CLUSTERED,
Id_ElementoPEP	BIGINT null
);


INSERT INTO		##TB_ElementoPEP (Id_ElementoPEP)

SELECT			TB_ElementoPEP.Id_ElementoPEP 
FROM			SCH_ODS.TB_ElementoPEP TB_ElementoPEP  with(nolock) 
WHERE			RTRIM(LTRIM(TB_ElementoPEP.CodElementoPEP)) IN ('00000000','')

CREATE NONCLUSTERED INDEX IX_TMP_TB_ElementoPEP on ##TB_ElementoPEP (Id_ElementoPEP ASC);

-- FIM CRIAÇÃO TAABELAS DE APOIO


-------------------------------------------------------------------------------------------------------------------------------------------

-- ESQL- Apagar dados FatoMovContabilResultado

--DELETE		AA
--FROM		sgbdw.SCH_DW.Fato_MovContabilResultado AA
--INNER JOIN	sgbdw.SCH_DW.Dim_Exercicio BB
--ON			AA.Id_DimExercicio = BB.Id_DimExercicio 
--INNER JOIN	##_Exercicios E WITH(NOLOCK)
--ON			E.Id_DimExercicio = AA.Id_DimExercicio
--and 			E.Tipo = 1;
--GO

select * from ##_Exercicios

-------------------------------------------------------------------------------------------------------------------------------------------

-- PASSO 01 - DFT - Temporaria FatoMovContabilResultado - Lenger Principal

SELECT 
			'0L' CodLedger
,			-2 Id_DimCanal
,			-2 Id_DimCanal_Cliente
,			ISNULL(DCN.Id_DimCenario,-1) Id_DimCenario
,			ISNULL(DCC.Id_DimCentroCusto,-1) Id_DimCentroCusto 
,			-2 Id_DimCentroLucro
,			-2 Id_DimCliente
,			ISNULL(DCTCT.Id_DimContaContabil,-1) Id_DimContaContabil
,			ISNULL(DEP.Id_DimElementoPEP,-1) Id_DimElementoPEP
,			ISNULL(DE.Id_DimExercicio,-1) Id_DimExercicio
,			ISNULL(DM.Id_DimMoeda,-1) Id_DimMoeda
,			ISNULL(DOI.Id_DimOrdemInterna,-1) Id_DimOrdemInterna
,			ISNULL(DOF.Id_DimStrOrgFiscal,-1) Id_DimStrOrgFiscal
,			RealCCusto.VlrMontante

into ##teste

FROM		SCH_ODS.TB_TransacaoPartidaIndivRealCCusto_Agrd RealCCusto WITH(NOLOCK)

INNER JOIN	##TB_ClasseCusto CCusto   WITH(NOLOCK)
ON			CCusto.Id_ClasseCusto                       = RealCCusto.Id_ClasseCusto

INNER JOIN	SCH_ODS.TB_TipoMoeda TpMoeda   WITH(NOLOCK)
ON			TpMoeda.Id_TipoMoeda                        = RealCCusto.Id_TipoMoeda	

--INNER JOIN	##_Exercicios  /*##TMP_NumExercicioPeriodo_ContabilResultado*/ TMP  WITH(NOLOCK)
--ON			TMP.Exercicio = RealCCusto.NumExercicioPeriodo
--and 			TMP.Tipo = 1

LEFT JOIN	SCH_ODS.TB_CentroCusto CC

ON	CC.Id_CentroCusto = RealCCusto.Id_CentroCusto

LEFT JOIN	SGBDW.SCH_DW.Dim_CentroCusto DCC

ON			DCC.CodCentroCusto = RIGHT(CC.CodCentroCusto,3)

LEFT JOIN SGBODS.SCH_ODS.TB_ClasseCusto TCLC

ON			RealCCusto.Id_ClasseCusto = TCLC.Id_ClasseCusto

LEFT JOIN	SGBDW.SCH_DW.Dim_ContaContabil DCTCT

ON			DCTCT.CodContaContabil = RIGHT(TCLC.CodClasseCusto,6)

LEFT JOIN	SGBDW.SCH_DW.Dim_Moeda DM

ON			RealCCusto.CodMoeda = DM.CodMoeda

LEFT JOIN	SGBDW.SCH_DW.Dim_Exercicio DE

ON			RealCCusto.NumExercicioPeriodo = DE.CodExercicio

LEFT JOIN	(select a.Id_DimStrOrgFiscal, a.CodCentro, a.DthInicioVigenciaOrgFiscal, a.DthFimVigenciaOrgFiscal
				from SGBDW.SCH_DW.Dim_OrgFiscal a
				where a.DthFimVigenciaOrgFiscal is null) DOF
				
ON			DOF.CodCentro = RIGHT(SUBSTRING(CC.CodCentroCusto,1,7),4)

LEFT JOIN	SGBDW.[SCH_DW].[Dim_ElementoPEP] DEP

ON			RealCCusto.Id_ElementoPEPParc = DEP.Id_ElementoPEP

AND			DEP.DthInicioVigenciaPEP  IS NULL

LEFT JOIN	SGBDW.[SCH_DW].[Dim_OrdemInterna]  DOI 

ON			RealCCusto.Id_OrdemParc = DOI.Id_OrdemInterna

and DOI.DthFimVigenciaOrdem is null

LEFT JOIN	SGBDW.SCH_DW.Dim_Cenario DCN

ON			DCN.CodCenario = 1


WHERE		TpMoeda.CodTipoMoeda  = '10'

and RealCCusto.NumExercicioPeriodo = '2022001'


select CodLedger
,SUM(VlrMontante) VlrMontante
from ##teste
group by CodLedger
------------------------------------------------------------------------------------------------------------------------

-- PASSO 02

SELECT 

RealCCusto.CodLedger
,			-2 Id_DimCanal
,			-2 Id_DimCanal_Cliente
,			ISNULL(DCN.Id_DimCenario,-1) Id_DimCenario
,			ISNULL(DCC.Id_DimCentroCusto,-1) Id_DimCentroCusto 
,			-2 Id_DimCentroLucro
,			-2 Id_DimCliente
,			ISNULL(DCTCT.Id_DimContaContabil,-1) Id_DimContaContabil
,			ISNULL(DEP.Id_DimElementoPEP,-1) Id_DimElementoPEP
,			ISNULL(DE.Id_DimExercicio,-1) Id_DimExercicio
,			ISNULL(DM.Id_DimMoeda,-1) Id_DimMoeda
,			ISNULL(DOI.Id_DimOrdemInterna,-1) Id_DimOrdemInterna
,			ISNULL(DOF.Id_DimStrOrgFiscal,-1) Id_DimStrOrgFiscal
,			RealCCusto.VlrMontante


FROM 

(

SELECT 
RealCCusto.Id_CentroCusto
,RealCCusto.Id_ClasseCusto
,RealCCusto.CodMoeda
,RealCCusto.NumExercicioPeriodo
,RealCCusto.Id_ElementoPEPParc
,RealCCusto.Id_OrdemParc
,RealCCusto.VlrMontante
,'2L' as CodLedger
FROM		SCH_ODS.TB_TransacaoPartidaIndivRealCCusto_Agrd RealCCusto WITH(NOLOCK)

INNER JOIN	##TB_ClasseCusto CCusto WITH(NOLOCK)
ON			CCusto.Id_ClasseCusto = RealCCusto.Id_ClasseCusto 

INNER JOIN	SCH_ODS.TB_TipoMoeda TpMoeda WITH(NOLOCK)
ON			TpMoeda.Id_TipoMoeda  = RealCCusto.Id_TipoMoeda 


INNER JOIN	##_Exercicios  /*##TMP_NumExercicioPeriodo_ContabilResultado*/ TMP WITH(NOLOCK)
ON			TMP.Exercicio = RealCCusto.NumExercicioPeriodo
and 			TMP.Tipo = 1

LEFT JOIN	SCH_ODS.TB_ElementoPEP PEP   WITH(NOLOCK)
ON			PEP.Id_ElementoPEP = RealCCusto.Id_ElementoPEPParc

WHERE		1=1
AND			TpMoeda.CodTipoMoeda = '10'
AND 		(
			RealCCusto.Id_OrdemParc IS NOT NULL OR 
			(RealCCusto.Id_ElementoPEPParc  IS NOT NULL AND RTRIM(LTRIM(PEP.CodElementoPEP)) NOT IN('00000000','' )) 
			)

UNION ALL

SELECT 
RealCCusto.Id_CentroCusto
,RealCCusto.Id_ClasseCusto
,RealCCusto.CodMoeda
,RealCCusto.NumExercicioPeriodo
,RealCCusto.Id_ElementoPEPParc
,RealCCusto.Id_OrdemParc
,RealCCusto.VlrMontante
,'1L' as CodLedger
FROM		SCH_ODS.TB_TransacaoPartidaIndivRealCCusto_Agrd RealCCusto WITH(NOLOCK)

INNER JOIN	##TB_ClasseCusto CCusto WITH(NOLOCK)
ON			CCusto.Id_ClasseCusto = RealCCusto.Id_ClasseCusto 

INNER JOIN	SCH_ODS.TB_TipoMoeda TpMoeda WITH(NOLOCK)
ON			TpMoeda.Id_TipoMoeda  = RealCCusto.Id_TipoMoeda 


INNER JOIN	##_Exercicios  /*##TMP_NumExercicioPeriodo_ContabilResultado*/ TMP WITH(NOLOCK)
ON			TMP.Exercicio = RealCCusto.NumExercicioPeriodo
and 			TMP.Tipo = 1

LEFT JOIN	SCH_ODS.TB_ElementoPEP PEP   WITH(NOLOCK)
ON			PEP.Id_ElementoPEP = RealCCusto.Id_ElementoPEPParc

WHERE		1=1
AND			TpMoeda.CodTipoMoeda = '10'
AND 		(
			RealCCusto.Id_OrdemParc IS NOT NULL OR 
			(RealCCusto.Id_ElementoPEPParc  IS NOT NULL AND RTRIM(LTRIM(PEP.CodElementoPEP)) NOT IN('00000000','' )) 
			)
			
) RealCCusto

LEFT JOIN SGBODS.SCH_ODS.TB_CentroCusto TBCC

ON RealCCusto.Id_CentroCusto = TBCC.Id_CentroCusto

LEFT JOIN SGBDW.SCH_DW.Dim_CentroCusto DCC

ON RIGHT(TBCC.CodCentroCusto,3) = DCC.CodCentroCusto 

LEFT JOIN SGBODS.SCH_ODS.TB_ClasseCusto TCLCC

ON RealCCusto.Id_ClasseCusto = TCLCC.Id_ClasseCusto

LEFT JOIN SGBDW.SCH_DW.Dim_ContaContabil DCTCT 

ON RIGHT(TCLCC.CodClasseCusto,6) = DCTCT.CodContaContabil

LEFT JOIN	SGBDW.SCH_DW.Dim_Moeda DM

ON			RealCCusto.CodMoeda = DM.CodMoeda

LEFT JOIN	SGBDW.SCH_DW.Dim_Exercicio DE

ON			RealCCusto.NumExercicioPeriodo = DE.CodExercicio

LEFT JOIN	(select a.Id_DimStrOrgFiscal, a.CodCentro, a.DthInicioVigenciaOrgFiscal, a.DthFimVigenciaOrgFiscal
				from SGBDW.SCH_DW.Dim_OrgFiscal a
				where a.DthFimVigenciaOrgFiscal is null) DOF
				
ON			DOF.CodCentro = RIGHT(SUBSTRING(CC.CodCentroCusto,1,7),4)

LEFT JOIN	SGBDW.[SCH_DW].[Dim_ElementoPEP] DEP

ON			RealCCusto.Id_ElementoPEPParc = DEP.Id_ElementoPEP

AND			DEP.DthInicioVigenciaPEP  IS NULL

LEFT JOIN	SGBDW.[SCH_DW].[Dim_OrdemInterna]  DOI 

ON			RealCCusto.Id_OrdemParc = DOI.Id_OrdemInterna

LEFT JOIN	SGBDW.SCH_DW.Dim_Cenario DCN

ON			DCN.CodCenario = 1


-------------------------------------------------------------------------------------------------------------------------

-- PASSO 03

SELECT DISTINCT a.Id_Canal, a.Id_ClienteEmissorOrdem, a.CodDocVenda, Id_Canal_Cliente

INTO ##_TMP_TB_TransacaoFaturaCab

FROM SCH_ODS.TB_TransacaoFaturaCab a

LEFT JOIN 
( 
SELECT DISTINCT 
CodDocFaturamento
,CASE WHEN cn.CodCanal = 'I1' THEN 3 -- Venda Indireta
	WHEN cn.CodCanal = 'D1' THEN 1 -- Vd Direta Envasado
	WHEN cn.CodCanal = 'D2' AND MAT.CodMaterial not in ( '000000000000096809' , '000000000000000002' ) THEN 1 -- Vd Direta Envasado
	WHEN cn.CodCanal = 'D2' AND MAT.CodMaterial IN ( '000000000000096809' , '000000000000000002' ) THEN	2 -- Vd Direta Granel
	ELSE FATURA.Id_Canal
	END  Id_Canal_Cliente

FROM SGBODS.SCH_ODS.TB_TransacaoFatura_Agrd Fatura 

left join SCH_ODS.TB_Canal cn WITH(NOLOCK)
	on Fatura.Id_Canal = cn.Id_Canal
	
LEFT JOIN SCH_ODS.TB_Material mat with(nolock)	
	on Fatura.Id_Material = mat.Id_Material	
	
) 	Fatura

ON Fatura.CodDocFaturamento = A.CodDocVenda;


SELECT 		PartidaIndiv.CodLedger
,			CASE WHEN ContaContabil.LeftCodContaContabil = 3 THEN ISNULL(DCN.Id_DimCanal,-1) ELSE -2 END  Id_DimCanal
,			CASE WHEN ContaContabil.LeftCodContaContabil = 3 THEN ISNULL(DCNCLT.Id_DimCanal,-1) ELSE -2 END  Id_DimCanal_Cliente
,			ISNULL(DCEN.Id_DimCenario,-1) Id_DimCenario 
,			ISNULL(DCC.Id_DimCentroCusto,-1) Id_DimCentroCusto
,			ISNULL(DCL.Id_DimCentroLucro,-1) Id_DimCentroLucro
,			CASE WHEN ContaContabil.LeftCodContaContabil = 3 THEN ISNULL(DCLT.Id_DimCliente,-1) ELSE -2 END  Id_DimCliente
,			ISNULL(DCTCT.Id_DimContaContabil,-1) Id_DimContaContabil
,			-2 Id_DimElementoPEP 
,			ISNULL(DE.Id_DimExercicio,-1) Id_DimExercicio 
,			ISNULL(DM.Id_DimMoeda,-1) Id_DimMoeda 
,			-2 Id_DimOrdemInterna
,			ISNULL(DOF.Id_DimStrOrgFiscal,-1) Id_DimStrOrgFiscal
,			SUM(PartidaIndiv.VlrMontanteMIComSinal) VlrMontanteMIComSinal 


FROM		SCH_ODS.VW_TransacaoRazaoPartidaIndiv PartidaIndiv WITH(NOLOCK)

INNER JOIN	SCH_ODS.TB_CentroLucro TB_CentroLucro   WITH(NOLOCK)
ON			TB_CentroLucro.Id_CentroLucro = PartidaIndiv.Id_CentroLucro	

INNER JOIN	##tmp_IDs_ContaContabil ContaContabil  WITH(NOLOCK)
ON			ContaContabil.Id_ContaContabil = PartidaIndiv.Id_ContaContabil	

INNER JOIN	##_Exercicios  /*##TMP_NumExercicioPeriodo_ContabilResultado*/ TMP
ON			TMP.Exercicio = PartidaIndiv.[NumExercicio/Periodo]
and 			TMP.Tipo = 1
	
LEFT JOIN SGBODS.SCH_ODS.TB_CentroCusto TCC

ON			TCC.Id_CentroCusto = PartidaIndiv.Id_CentroCusto

LEFT JOIN	SGBDW.SCH_DW.Dim_CentroCusto DCC

ON			RIGHT(TCC.CodCentroCusto,3) = DCC.CodCentroCusto
		
LEFT JOIN	SGBDW.SCH_DW.Dim_CentroLucro DCL

ON			PartidaIndiv.Id_CentroLucro = DCL.Id_CentroLucro	

LEFT JOIN	SGBDW.SCH_DW.Dim_ContaContabil DCTCT

ON			PartidaIndiv.Id_ContaContabil = DCTCT.Id_ContaContabil

LEFT JOIN	SGBDW.SCH_DW.Dim_Moeda DM

ON			PartidaIndiv.NumMoedaInterna = DM.CodMoeda

LEFT JOIN	SGBDW.SCH_DW.Dim_Exercicio DE

ON			PartidaIndiv.[NumExercicio/Periodo] = DE.CodExercicio

LEFT JOIN	 SGBDW.[SCH_DW].[Dim_OrgFiscal] DOF

ON			RIGHT(DCL.CodCentroLucro,4) = DOF.CodCentro 

AND			DthFimVigenciaOrgFiscal IS NULL
	
LEFT JOIN	##_TMP_TB_TransacaoFaturaCab TFC

ON			TFC.CodDocVenda = PartidaIndiv.NomChaveReferencia 

LEFT JOIN	SGBDW.SCH_DW.Dim_Cliente DCLT

ON			DCLT.Id_Cliente = TFC.Id_ClienteEmissorOrdem

AND			DthFimVigenciaCliente is null

LEFT JOIN	SGBDW.SCH_DW.Dim_Canal DCN

ON			TFC.Id_Canal = DCN.Id_Canal
	
LEFT JOIN	SGBDW.SCH_DW.Dim_Canal DCNCLT

ON			TFC.Id_Canal_Cliente = DCN.Id_Canal

LEFT JOIN	SGBDW.SCH_DW.Dim_Cenario DCEN

ON			DCEN.CodCenario = 1 

WHERE		1=1
AND			ContaContabil.LeftCodContaContabil IN (3,4,6)	
AND			PartidaIndiv.CodTipoRegistro       = '0'


GROUP BY PartidaIndiv.CodLedger
,			CASE WHEN ContaContabil.LeftCodContaContabil = 3 THEN ISNULL(DCN.Id_DimCanal,-1) ELSE -2 END  
,			CASE WHEN ContaContabil.LeftCodContaContabil = 3 THEN ISNULL(DCNCLT.Id_DimCanal,-1) ELSE -2 END  
,			ISNULL(DCEN.Id_DimCenario,-1)  
,			ISNULL(DCC.Id_DimCentroCusto,-1) 
,			ISNULL(DCL.Id_DimCentroLucro,-1) 
,			CASE WHEN ContaContabil.LeftCodContaContabil = 3 THEN ISNULL(DCLT.Id_DimCliente,-1) ELSE -2 END  
,			ISNULL(DCTCT.Id_DimContaContabil,-1) 
,			ISNULL(DE.Id_DimExercicio,-1)  
,			ISNULL(DM.Id_DimMoeda,-1)  
,			ISNULL(DOF.Id_DimStrOrgFiscal,-1)


-------------------------------------------------------------------------------------------------------------------------

-- PASSO 04

SELECT		PartidaIndiv.CodLedger
,			CASE WHEN ContaContabil.LeftCodContaContabil = 3 THEN ISNULL(DCN.Id_DimCanal,-1) ELSE -2 END  Id_DimCanal
,			CASE WHEN ContaContabil.LeftCodContaContabil = 3 THEN ISNULL(DCNCLT.Id_DimCanal,-1) ELSE -2 END  Id_DimCanal_Cliente
,			ISNULL(DCEN.Id_DimCenario,-1) Id_DimCenario 
,			ISNULL(DCC.Id_DimCentroCusto,-1) Id_DimCentroCusto
,			ISNULL(DCL.Id_DimCentroLucro,-1) Id_DimCentroLucro
,			CASE WHEN ContaContabil.LeftCodContaContabil = 3 THEN ISNULL(DCLT.Id_DimCliente,-1) ELSE -2 END  Id_DimCliente
,			ISNULL(DCTCT.Id_DimContaContabil,-1) Id_DimContaContabil
,			-2 Id_DimElementoPEP 
,			ISNULL(DE.Id_DimExercicio,-1) Id_DimExercicio 
,			ISNULL(DM.Id_DimMoeda,-1) Id_DimMoeda 
,			-2 Id_DimOrdemInterna
,			ISNULL(DOF.Id_DimStrOrgFiscal,-1) Id_DimStrOrgFiscal
,			SUM(PartidaIndiv.VlrMontanteMIComSinal) VlrMontanteMIComSinal 

FROM		SCH_ODS.VW_TransacaoRazaoPartidaIndiv PartidaIndiv WITH(NOLOCK)

INNER JOIN	SCH_ODS.TB_CentroLucro CentroLucro  WITH(NOLOCK)
ON			CentroLucro.Id_CentroLucro = PartidaIndiv.Id_CentroLucro

INNER JOIN	##tmp_IDs_ContaContabil ContaContabil  WITH(NOLOCK)
ON			ContaContabil.Id_ContaContabil = PartidaIndiv.Id_ContaContabil	

INNER JOIN	##_Exercicios  /*##TMP_NumExercicioPeriodo_ContabilResultado*/ TMP
ON			TMP.Exercicio = PartidaIndiv.[NumExercicio/Periodo]
and 			TMP.Tipo = 1

LEFT JOIN	SCH_ODS.TB_ElementoPEP PEP WITH(NOLOCK)
ON			PEP.Id_ElementoPEP = PartidaIndiv.Id_ElementoPEP

LEFT JOIN	SGBODS.SCH_ODS.TB_OrdemInterna OI

ON			OI.Id_OrdemInterna = PartidaIndiv.Id_Ordem 

LEFT JOIN SGBODS.SCH_ODS.TB_CentroCusto TCC

ON			TCC.Id_CentroCusto = PartidaIndiv.Id_CentroCusto

LEFT JOIN	SGBDW.SCH_DW.Dim_CentroCusto DCC

ON			RIGHT(TCC.CodCentroCusto,3) = DCC.CodCentroCusto
		
LEFT JOIN	SGBDW.SCH_DW.Dim_CentroLucro DCL

ON			PartidaIndiv.Id_CentroLucro = DCL.Id_CentroLucro	

LEFT JOIN	SGBDW.SCH_DW.Dim_ContaContabil DCTCT

ON			PartidaIndiv.Id_ContaContabil = DCTCT.Id_ContaContabil

LEFT JOIN	SGBDW.SCH_DW.Dim_Moeda DM

ON			PartidaIndiv.NumMoedaInterna = DM.CodMoeda

LEFT JOIN	SGBDW.SCH_DW.Dim_Exercicio DE

ON			PartidaIndiv.[NumExercicio/Periodo] = DE.CodExercicio

LEFT JOIN	 SGBDW.[SCH_DW].[Dim_OrgFiscal] DOF

ON			RIGHT(DCL.CodCentroLucro,4) = DOF.CodCentro 

AND			DthFimVigenciaOrgFiscal IS NULL
	
LEFT JOIN	##_TMP_TB_TransacaoFaturaCab TFC

ON			TFC.CodDocVenda = PartidaIndiv.NomChaveReferencia 

LEFT JOIN	SGBDW.SCH_DW.Dim_Cliente DCLT

ON			DCLT.Id_Cliente = TFC.Id_ClienteEmissorOrdem

AND			DthFimVigenciaCliente is null

LEFT JOIN	SGBDW.SCH_DW.Dim_Canal DCN

ON			TFC.Id_Canal = DCN.Id_Canal
	
LEFT JOIN	SGBDW.SCH_DW.Dim_Canal DCNCLT

ON			TFC.Id_Canal_Cliente = DCN.Id_Canal

LEFT JOIN	SGBDW.SCH_DW.Dim_Cenario DCEN

ON			DCEN.CodCenario = 1 

where		1=1
AND			ContaContabil.LeftCodContaContabil	= '5'
AND			PartidaIndiv.CodTipoRegistro		= '0'
AND			PartidaIndiv.CodLedger				<> '0L'
AND			PartidaIndiv.NomOperacaoRef			<> 'AUAK'
AND			(PartidaIndiv.Id_Ordem				IS NULL OR OI.CodTpoOrdemInterna = 'ZDES')
AND			PartidaIndiv.Id_CentroCusto			IS NOT NULL
AND			(
				PartidaIndiv.Id_ElementoPEP			IS NULL 
			or	RTRIM(LTRIM(PEP.CodElementoPEP))	IN ('00000000','')
			)

GROUP BY PartidaIndiv.CodLedger
,			CASE WHEN ContaContabil.LeftCodContaContabil = 3 THEN ISNULL(DCN.Id_DimCanal,-1) ELSE -2 END  
,			CASE WHEN ContaContabil.LeftCodContaContabil = 3 THEN ISNULL(DCNCLT.Id_DimCanal,-1) ELSE -2 END  
,			ISNULL(DCEN.Id_DimCenario,-1)  
,			ISNULL(DCC.Id_DimCentroCusto,-1) 
,			ISNULL(DCL.Id_DimCentroLucro,-1) 
,			CASE WHEN ContaContabil.LeftCodContaContabil = 3 THEN ISNULL(DCLT.Id_DimCliente,-1) ELSE -2 END  
,			ISNULL(DCTCT.Id_DimContaContabil,-1) 
,			ISNULL(DE.Id_DimExercicio,-1)  
,			ISNULL(DM.Id_DimMoeda,-1)  
,			ISNULL(DOF.Id_DimStrOrgFiscal,-1)

