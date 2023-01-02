--SELECT 'truncate table '+ s.name + '.' + t.name 
--FROM SYS.TABLES T, SYS.SCHEMAS S 
--WHERE T.SCHEMA_ID = S.SCHEMA_ID
--AND S.name = 'COMPASS'

truncate table compass.TB_ChannelFromTo
truncate table compass.tb_DespesaSalarialProspeccaoRetencao
truncate table compass.TB_Param_Inflation
truncate table compass.tb_TempoInvestidoProspeccaoRetencao
truncate table compass.tb_SalesChannelsCost
truncate table compass.tb_MarketingDepartment
truncate table compass.tb_IncentiveFees
truncate table compass.TB_Costs
truncate table compass.tb_TotalColaboradores
truncate table compass.tb_SourceCostGroup
truncate table compass.tb_ChannelGroup
truncate table compass.tb_HeadofficeSalesCost
truncate table compass.Fact_Capex
truncate table compass.Dim_ClientCompass
truncate table compass.TB_CreationForecast
truncate table compass.TB_Param_LifeTime
truncate table compass.TB_ParamTimeSpend
truncate table compass.tb_SalesRepsCost
truncate table compass.tb_SalesManagerSalaryCost
truncate table compass.tb_CentralSalesDepartment
truncate table compass.TB_AnualPremisses
truncate table compass.TB_CapexValores
truncate table compass.tb_CargoDepara
truncate table compass.tb_CargoSalario