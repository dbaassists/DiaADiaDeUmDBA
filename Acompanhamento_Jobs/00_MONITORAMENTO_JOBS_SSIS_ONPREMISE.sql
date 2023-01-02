select *, DATEDIFF(MINUTE,DthInicio, isnull(DthFim,getdate())) tempo 
from sgblog.SCH_LOG.TB_Carga with(NOLOCK)
where 1=1
and NomPacote in (
'PKG-Carregar_STG_Dados_Transacionais01-FI',
'PKG-Carregar_ODS_Dados_Transacionais02-FI-N4',
'PKG-Carregar_ODS_Dados_Transacionais01-FI-N3'
) 

and YEAR(dthinicio)		>= 2022

and TpoExecucao = 'E'

order by DthInicio desc
go

---------------------------------------------------------------------------------------------------------------------------

DECLARE @IDCARGA INT 
SET @IDCARGA  = 470068

SELECT 

A.DscErro
,A.LinhaRegistro

FROM SGBLOG.SCH_LOG.TB_CargaErro A with(NOLOCK)

INNER JOIN SGBLOG.SCH_LOG.TB_CargaDetalhe B WITH(NOLOCK)
ON A.IdCargaDetalhe = B.IdCargaDetalhe

INNER JOIN sgblog.SCH_LOG.TB_Carga C
ON B.IdCarga = C.IdCarga

WHERE B.IdCarga = @IDCARGA

--in ( 469898 ) 

ORDER BY 	A.DscErro

