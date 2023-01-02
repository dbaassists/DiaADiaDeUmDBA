DROP TABLE dbo.Cliente

CREATE TABLE dbo.Cliente
(
IdCliente INT NOT NULL IDENTITY(1,1)
,NomeCliente VARCHAR(100)
)
GO

ALTER TABLE dbo.Cliente ADD CONSTRAINT [PK_Cliente] PRIMARY KEY (IdCliente)
GO

INSERT INTO dbo.Cliente (NomeCliente) VALUES ('GABRIEL QUINTELLA');
INSERT INTO dbo.Cliente (NomeCliente) VALUES ('EDMAGNO SANTOS');
INSERT INTO dbo.Cliente (NomeCliente) VALUES ('IGOR ALVES');

DROP TABLE dbo.Produto

CREATE TABLE dbo.Produto
(
IdProduto INT NOT NULL IDENTITY(1,1)
,NomeProduto VARCHAR(100) NOT NULL
,ValorProduto DECIMAL(23,4) NOT NULL
)
GO

ALTER TABLE dbo.Produto ADD CONSTRAINT [PK_Produto] PRIMARY KEY (IdProduto)
GO

INSERT INTO dbo.Produto (NomeProduto,ValorProduto) VALUES ('TV','4157.99');
INSERT INTO dbo.Produto (NomeProduto,ValorProduto) VALUES ('CELULAR','8541.99');
INSERT INTO dbo.Produto (NomeProduto,ValorProduto) VALUES ('NOTEBOOK','6900.00');
INSERT INTO dbo.Produto (NomeProduto,ValorProduto) VALUES ('BICICLETA','1500.00');

DROP TABLE dbo.Venda

CREATE TABLE dbo.Venda
(
IdVenda INT NOT NULL IDENTITY(1,1)
,IdCliente INT NOT NULL
,DataVenda DATETIME NOT NULL
)
GO

ALTER TABLE dbo.Venda ADD CONSTRAINT [PK_Venda] PRIMARY KEY (IdVenda)
GO

INSERT INTO  dbo.Venda (IdCliente, DataVenda) VALUES (1, '20210114');
INSERT INTO  dbo.Venda (IdCliente, DataVenda) VALUES (2, '20210121');
INSERT INTO  dbo.Venda (IdCliente, DataVenda) VALUES (3, '20210109');

DROP TABLE dbo.ItemVenda

CREATE TABLE dbo.ItemVenda
(
IdVenda INT NOT NULL 
,IdProduto INT NOT NULL 
,QtdProduto INT NOT NULL
,ValorProduto DECIMAL(23,3) NOT NULL
)
GO

ALTER TABLE dbo.ItemVenda ADD CONSTRAINT [PK_ItemVenda] PRIMARY KEY (IdVenda,IdProduto)
GO

INSERT INTO dbo.ItemVenda (IdVenda, IdProduto, QtdProduto,ValorProduto ) VALUES (1,1,1,'4157.99')
INSERT INTO dbo.ItemVenda (IdVenda, IdProduto, QtdProduto,ValorProduto ) VALUES (2,2,2,'8541.99')
INSERT INTO dbo.ItemVenda (IdVenda, IdProduto, QtdProduto,ValorProduto ) VALUES (2,4,1,'1500.00')
INSERT INTO dbo.ItemVenda (IdVenda, IdProduto, QtdProduto,ValorProduto ) VALUES (3,3,1,'6900.00')


SELECT * FROM dbo.Cliente
SELECT * FROM dbo.Produto
SELECT * FROM dbo.Venda
SELECT * FROM dbo.ItemVenda

SELECT V.IdVenda
, C.NomeCliente
, P.NomeProduto
, IV.QtdProduto 
, IV.ValorProduto ValorUnitario
, IV.QtdProduto * IV.ValorProduto ValorTotalProduto
, v.DataVenda 

FROM dbo.Venda V

INNER JOIN dbo.ItemVenda IV 

ON V.IdVenda = IV.IdVenda

INNER JOIN dbo.Cliente C

ON V.IdCliente = C.IdCliente

INNER JOIN dbo.Produto P

ON IV.IdProduto = P.IdProduto

--------------------------------------------------------------------

DROP TABLE dbo.DimCliente

CREATE TABLE dbo.DimCliente
(
IdDimCliente INT NOT NULL IDENTITY(1,1)
,IdCliente INT NOT NULL
,NomeCliente VARCHAR(100)
)
GO

ALTER TABLE dbo.DimCliente ADD CONSTRAINT [PK_DimCliente] PRIMARY KEY (IdDimCliente)
GO

INSERT INTO dbo.DimCliente (IdCliente, NomeCliente)
SELECT IdCliente, NomeCliente
FROM dbo.Cliente



DROP TABLE dbo.DimProduto

CREATE TABLE dbo.DimProduto
(
IdDimProduto INT NOT NULL IDENTITY(1,1)
,IdProduto INT NOT NULL
,NomeProduto VARCHAR(100) NOT NULL
)
GO

ALTER TABLE dbo.DimProduto ADD CONSTRAINT [PK_DimProduto] PRIMARY KEY (IdDimProduto)
GO

INSERT INTO dbo.DimProduto (IdProduto, NomeProduto)
SELECT IdProduto, NomeProduto 
FROM dbo.Produto


CREATE TABLE [dbo].[Dim_Tempo](
	[IdDimTempo] [bigint] NOT NULL identity(1,1),
	[Dta] [date] NULL,
	[AnoMesDia] [int] NULL,
	[Ano] [int] NULL,
	[Mes] [int] NULL,
	[Dia] [int] NULL,
	[AnoMes] [int] NULL,
	[NomAnoMes] [varchar](15) NULL,
	[NomAnoMesAbrev] [varchar](8) NULL,
	[NomMes] [varchar](9) NULL,
	[NomMesAbrev] [varchar](3) NULL,
	[DiaDaSemana] [int] NULL,
	[NomDiaDaSemana] [varchar](7) NULL,
	[DiaDoAno] [int] NULL,
	[Bimestre] [int] NULL,
	[Trimestre] [int] NULL,
	[Semestre] [int] NULL,
	[SemanaMes] [int] NULL,
	[SemanaAno] [int] NULL,
	[AnoBimestre] [int] NULL,
	[AnoTrimestre] [int] NULL,
	[AnoSemestre] [int] NULL,
	[DiaUtil] [int] NULL,
	[FinalSemana] [int] NULL,
	[DataPorExtenso] [varchar](50) NULL,
	[AnoOBIEE] [varchar](4) NULL,
	[AnoMESOBIEE] [varchar](50) NULL,
 CONSTRAINT [Pk_IdDimTempo] PRIMARY KEY CLUSTERED 
(
	[IdDimTempo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

--------------------------------------------------------------------------------

DROP TABLE dbo.FatoVenda

CREATE TABLE dbo.FatoVenda
(
IdFatoVenda INT NOT NULL IDENTITY(1,1)
,IdVenda	INT NOT NULL 
,IdDimCliente	INT NOT NULL 
,IdDimProduto	INT NOT NULL 
,IdDimTempo	BIGINT NOT NULL 
,QtdProduto	INT NOT NULL 
,ValorUnitario	DECIMAL(23,3) NOT NULL
,ValorTotalProduto	DECIMAL(23,3) NOT NULL
)

ALTER TABLE dbo.FatoVenda ADD CONSTRAINT [PK_FatoVenda] PRIMARY KEY (IdFatoVenda)
GO

INSERT INTO dbo.FatoVenda

(
IdVenda
, IdDimCliente
, IdDimProduto
, IdDimTempo
, QtdProduto 
, ValorUnitario
, ValorTotalProduto
)

SELECT V.IdVenda
, DCLT.IdDimCliente
, DPRD.IdDimProduto
, DTMP.IdDimTempo
, IV.QtdProduto 
, IV.ValorProduto ValorUnitario
, IV.QtdProduto * IV.ValorProduto ValorTotalProduto

----------------------- DADOS TRANSACIONAIS -----------------------

FROM dbo.Venda V

INNER JOIN dbo.ItemVenda IV 

ON V.IdVenda = IV.IdVenda

INNER JOIN dbo.Cliente C

ON V.IdCliente = C.IdCliente

INNER JOIN dbo.Produto P

ON IV.IdProduto = P.IdProduto

----------------------- DADOS DIMENSIONAIS -----------------------

INNER JOIN dbo.DimCliente DCLT

ON C.IdCliente = DCLT.IdCliente

INNER JOIN dbo.DimProduto DPRD

ON P.IdProduto = DPRD.IdProduto

INNER JOIN DBO.Dim_Tempo DTMP

ON V.DataVenda = DTMP.Dta

ALTER TABLE dbo.FatoVenda ADD CONSTRAINT [FK_DimCliente] FOREIGN KEY (IdDimCliente) REFERENCES dbo.DimCliente(IdDimCliente)
ALTER TABLE dbo.FatoVenda ADD CONSTRAINT [FK_DimProduto] FOREIGN KEY (IdDimProduto) REFERENCES dbo.DimProduto(IdDimProduto)
ALTER TABLE dbo.FatoVenda ADD CONSTRAINT [FK_DimTempo] FOREIGN KEY (IdDimTempo) REFERENCES DBO.Dim_Tempo(IdDimTempo)

SELECT * 
FROM dbo.FatoVenda