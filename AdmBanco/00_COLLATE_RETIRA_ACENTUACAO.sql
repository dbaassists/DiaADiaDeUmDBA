select Id_EscritorioVenda, 
IdtSFEEscritorioVenda, 
NomEscritorioVenda,
NomEscritorioVenda Collate SQL_Latin1_General_CP1253_CI_AI ,
UPPER(REPLACE(isnull(NomEscritorioVenda, ''), ' ', '')) Collate SQL_Latin1_General_CP1253_CI_AI  as NomEscritorioVenda
from SCH_ODS.TB_EscritorioVenda