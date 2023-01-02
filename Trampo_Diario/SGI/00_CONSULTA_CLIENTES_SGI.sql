SELECT 

A.CodLocalInstalacao CodClienteSAP_Condominio
,A.NomeCondominio
,B.CodLocInstalacaoSup CodigoPLD
,CodClienteSAP_Instalacao
,b.UnidadeLeitura
,b.CodInstalacao
,b.ParceiroNegocio
,cli_sap.CodCPF
,cli_sap.CodCNPJ
,B.CodigoContaContrato
,B.DataInicioContrato
,B.DataFimContrato
,B.Contrato CodContrato
,B.NumBloco
,B.NumApartamento
,B.FlgAtivo
,ModalidadePagamento
,CodBloqAdvertencia
,MtvBloqAdvertencia
,ProcedimentoCorte
,b.NomeParceiro
,b.EnderStandart	
,b.NumRes	
,b.AptoSalaEnder	
,b.BlLojaEnderStandart
,b.CodPostalStandart	
,b.CidadeEndStandart	
,b.PaisEndStandart	
,b.RegiaoEndStandart
,CAST( REPLACE(AA.NumTelefone,'+55','' ) AS VARCHAR(10)) AS NumTelefoneFixo
,CAST( REPLACE(AA3.NumTelefone,'+55','') AS VARCHAR(10)) AS NumTelefoneCelular
,Email.NomEmail
,CASE WHEN B.FlgAtivo = 'A' THEN 'Ativo' ELSE 'Inativo' END NomStatusCliente
,gc.NomGrupoConta
,cli_sap.FlgCorporativo
,DimClt.CodCentro
,DimClt.NomCentro


FROM 


(

	SELECT			distinct
					CASE WHEN LEN(a.CodInstalacao) < 10 THEN 
					REPLICATE('0', 10-LEN(a.CodInstalacao)) + CAST(a.CodInstalacao AS VARCHAR(10)) ELSE a.CodInstalacao
					END CodInstalacao , C.CodLocalInstalacao, NomeCondominio
					FROM			SGBDW.SCH_MIS.TB_SGI_Condominio C WITH(NOLOCK) 
					INNER JOIN		SGBDW.SCH_MIS.TB_SGI_Instalacao a WITH(NOLOCK)
					ON			c.CodLocalInstalacao = a.CodLocInstalacaoSup
					WHERE			A.TipoInstalacao = 'PLD'

 ) A
INNER JOIN 
(
	SELECT
	X.CodLocInstalacaoSup
	,X.Contrato
	,X.NumBloco
	,X.NumApartamento
	,X.FlgAtivo
	,x.id
	,x.CodClienteSAP_Instalacao
	,x.CodInstalacao
	,x.CodigoContaContrato
	,x.DataInicioContrato
	,x.DataFimContrato
	,X.ModalidadePagamento
	,X.CodBloqAdvertencia
	,X.MtvBloqAdvertencia
	,X.ProcedimentoCorte
	,x.ParceiroNegocio
	,x.UnidadeLeitura
	,x.NomeParceiro
	,x.EnderStandart	
	,x.NumRes	
	,x.AptoSalaEnder	
	,x.BlLojaEnderStandart
	,x.CodPostalStandart	
	,x.CidadeEndStandart	
	,x.PaisEndStandart	
	,x.RegiaoEndStandart

	FROM (
		SELECT  
		A.CodLocInstalacaoSup, B.CodCliDataSul CodClienteSAP_Instalacao
		,ROW_NUMBER() over( partition by A.CodLocInstalacaoSup,A.BlLojaLocalConsumo , A.AptoSalaLocalConsumo ORDER BY A.BlLojaLocalConsumo , A.AptoSalaLocalConsumo, B.DataInicioContrato DESC) ID
		,b.Contrato
		,b.CodigoCC CodigoContaContrato
		,b.DataInicioContrato
		,b.DataFimContrato
		,b.ParceiroNegocio
		,a.UnidadeLeitura
		,A.BlLojaLocalConsumo NumBloco
		,A.AptoSalaLocalConsumo NumApartamento
		,CASE WHEN 
				
						A.CodBloqueio = 1 AND A.DthBloqueio <> '1900-01-01 00:00:00.000' 
						THEN 'I'
						ELSE 'A'
						END FlgAtivo
		, A.CodInstalacao
		,ModalidadePagamento
		,CodBloqAdvertencia
		,MtvBloqAdvertencia
		,ProcedimentoCorte
		,b.NomeParceiro
		,pn.EnderStandart	
		,pn.NumRes	
		,pn.AptoSalaEnder	
		,pn.BlLojaEnderStandart	
		,pn.CodPostalStandart	
		,pn.CidadeEndStandart	
		,pn.PaisEndStandart	
		,pn.RegiaoEndStandart

		From SGBDW.SCH_MIS.TB_SGI_INSTALACAO A WITH(NOLOCK)

		LEFT JOIN SGBDW.SCH_MIS.TB_SGI_ContaContrato B WITH(NOLOCK)

		ON A.codinstalacao = B.codinstalacao

		left join sgbdw.SCH_MIS.TB_SGI_ParceiroNegocio pn

		on b.ParceiroNegocio = pn.CodParcNegocio

		WHERE			A.TipoInstalacao = 'IND'

		) X 

		WHERE 1=1 
		and X.ID = 1
) B

ON A.CodInstalacao = B.CodLocInstalacaoSup

left join sgbods.sch_ods.tb_cliente cli_sap

on CodClienteSAP_Instalacao = cli_sap.CodCliente

LEFT JOIN SGBODS.SCH_ODS.TB_GrupoConta gc

ON cli_sap.CodGrupoConta = GC.CodGrupoConta

INNER JOIN SGBODS.SCH_ODS.TB_Cliente Cli2 WITH(NOLOCK)

ON CodClienteSAP_Instalacao = Cli2.CodCliente

left join SGBDW.SCH_DW.Dim_Cliente DimClt 

ON cli_sap.CodCliente = DimClt.CodCliente 
AND DimClt.DthFimVigenciaCliente is null

left join SGBODS.SCH_ODS.TB_Telefone AA WITH(NOLOCK)
on Cli2.Id_Cliente = AA.Id_Cliente
AND  Cli2.CodGrupoConta in ('ZPCC', 'ZPCR', 'ZVMC')
AND AA.FlgTelefoneExcluido IS NULL
and LTRIM(RTRIM(AA.TpoTelefone)) = '1'

left join SGBODS.SCH_ODS.TB_Telefone AA3 WITH(NOLOCK)
on Cli2.Id_Cliente = AA3.Id_Cliente
AND  Cli2.CodGrupoConta in ('ZPCC', 'ZPCR', 'ZVMC')
AND AA3.FlgTelefoneExcluido IS NULL
and LTRIM(RTRIM(AA3.TpoTelefone)) = '3'

left join SGBODS.SCH_ODS.TB_Email Email WITH(NOLOCK)

on Email.Id_Cliente = Cli2.Id_Cliente
AND Cli2.CodGrupoConta in ('ZPCC', 'ZPCR', 'ZVMC')
AND Email.FlgEmailExcluido is null
and Email.FlgEndStandard = 'X'

WHERE A.CodLocalInstalacao = '3982438'


SELECT * 
FROM SGBODS.SCH_ODS.TB_Cliente
WHERE CODCLIENTE = '0003982438'


