
---------------------------------------------------------------------------------------------------------------------------------------

-- PASSO 01 - CREATE TABLE

CREATE TABLE dbo.Futebol
(Pos int
,Estado varchar(100)
,Equipes varchar(100)
,P int
,J int
,V int
,E int
,D int
,GP  int 
,GC	 int 
,SG	 int 
,Per int );


-- PASSO 01 - INSERT TABLE

INSERT INTO dbo.Futebol (Pos,Estado,Equipes,P,J,V,E,D,GP,GC,SG,Per) VALUES ('1','São Paulo ','Palmeiras',31,13,10,1,2,25,12,13,79);
INSERT INTO dbo.Futebol (Pos,Estado,Equipes,P,J,V,E,D,GP,GC,SG,Per) VALUES ('2','Minas Gerais ','Atlético Mineiro',28,13,9,1,3,19,10,9,72);
INSERT INTO dbo.Futebol (Pos,Estado,Equipes,P,J,V,E,D,GP,GC,SG,Per) VALUES ('3','Ceará ','Fortaleza',27,13,8,3,2,21,9,12,69);
INSERT INTO dbo.Futebol (Pos,Estado,Equipes,P,J,V,E,D,GP,GC,SG,Per) VALUES ('4','São Paulo ','Red Bull Bragantino',24,13,6,6,1,24,16,8,61);
INSERT INTO dbo.Futebol (Pos,Estado,Equipes,P,J,V,E,D,GP,GC,SG,Per) VALUES ('5','Paraná ','Athletico Paranaense',23,12,7,2,3,21,13,8,64);
INSERT INTO dbo.Futebol (Pos,Estado,Equipes,P,J,V,E,D,GP,GC,SG,Per) VALUES ('6','Rio de Janeiro ','Flamengo',21,11,7,0,4,22,10,12,64);
INSERT INTO dbo.Futebol (Pos,Estado,Equipes,P,J,V,E,D,GP,GC,SG,Per) VALUES ('7','Goiás ','Atlético Goianiense',18,13,5,3,5,11,14,-3,46);
INSERT INTO dbo.Futebol (Pos,Estado,Equipes,P,J,V,E,D,GP,GC,SG,Per) VALUES ('8','Ceará ','Ceará',18,12,4,6,2,14,12,2,50);
INSERT INTO dbo.Futebol (Pos,Estado,Equipes,P,J,V,E,D,GP,GC,SG,Per) VALUES ('9','Bahia ','Bahia',17,13,5,2,6,18,22,-4,44);
INSERT INTO dbo.Futebol (Pos,Estado,Equipes,P,J,V,E,D,GP,GC,SG,Per) VALUES ('10','Rio de Janeiro ','Fluminense',17,13,4,5,4,10,12,-2,44);
INSERT INTO dbo.Futebol (Pos,Estado,Equipes,P,J,V,E,D,GP,GC,SG,Per) VALUES ('11','São Paulo ','Santos',16,13,4,4,5,15,16,-1,41);
INSERT INTO dbo.Futebol (Pos,Estado,Equipes,P,J,V,E,D,GP,GC,SG,Per) VALUES ('12','São Paulo ','Corinthians',14,12,3,5,4,9,10,-1,39);
INSERT INTO dbo.Futebol (Pos,Estado,Equipes,P,J,V,E,D,GP,GC,SG,Per) VALUES ('13','Rio Grande do Sul ','Internacional',14,13,3,5,5,12,18,-6,36);
INSERT INTO dbo.Futebol (Pos,Estado,Equipes,P,J,V,E,D,GP,GC,SG,Per) VALUES ('14','Rio Grande do Sul ','Juventude',13,12,3,4,5,8,14,-6,36);
INSERT INTO dbo.Futebol (Pos,Estado,Equipes,P,J,V,E,D,GP,GC,SG,Per) VALUES ('15','Mato Grosso ','Cuiabá',12,11,2,6,3,12,14,-2,36);
INSERT INTO dbo.Futebol (Pos,Estado,Equipes,P,J,V,E,D,GP,GC,SG,Per) VALUES ('16','São Paulo ','São Paulo',11,13,2,5,6,9,17,-8,28);
INSERT INTO dbo.Futebol (Pos,Estado,Equipes,P,J,V,E,D,GP,GC,SG,Per) VALUES ('17','Pernambuco ','Sport',10,12,2,4,6,7,11,-4,28);
INSERT INTO dbo.Futebol (Pos,Estado,Equipes,P,J,V,E,D,GP,GC,SG,Per) VALUES ('18','Minas Gerais ','América Mineiro',10,13,2,4,7,10,18,-8,26);
INSERT INTO dbo.Futebol (Pos,Estado,Equipes,P,J,V,E,D,GP,GC,SG,Per) VALUES ('19','Rio Grande do Sul ','Grêmio',7,11,1,4,6,6,13,-7,21);
INSERT INTO dbo.Futebol (Pos,Estado,Equipes,P,J,V,E,D,GP,GC,SG,Per) VALUES ('20','Santa Catarina ','Chapecoense',4,12,0,4,8,11,23,-12,11);


------------------------------------------------------------------------------------------------------------------------------------------

-- 00 - EXECUTAR OS PASSOS "PASSO 01 - CREATE TABLE" E "PASSO 01 - INSERT TABLE"

-- ESSE PASSO MONTA O SEU AMBIENTE

-- 01 - CRIAR COMANDO PARA CONSULTAR TODOS OS TIMES


SELECT * FROM dbo.Futebol  -- para a tabela inteira ou
SELECT Equipes FROM dbo.Futebol -- para listar apenas os times participantes


-- 02 - CRIAR COMANDO PARA CONSULTAR TODOS OS TIMES DO RIO DE JANEIRO 

SELECT Equipes AS TimesRJ FROM dbo.Futebol
WHERE Estado = 'Rio de Janeiro'


-- 03 - CRIAR COMANDO PARA ELIMINAR OS TIMES DE SÃO PAULO

DELETE FROM dbo.Futebol
WHERE Estado = 'São Paulo'


-- 04 - CRIAR COMANDO PARA ATUALIZAR A POSIÇÃO DO FLUMINENSE PARA PRIMEIRO LUGAR (TROCAR A POSIÇÃO COM O PRIMEIRO COLOCADO)

UPDATE dbo.Futebol 
SET Pos = 1  
WHERE Equipes = 'Fluminense'

UPDATE dbo.Futebol 
SET Pos = '10'
WHERE Equipes = 'Palmeiras'

SELECT * FROM dbo.Futebol ORDER BY pos -- pra ser sincero nessa aqui eu empaquei mas ai fiz uma gambiarra pra colocar 
										-- o fluminense em primeiro e te deixar feliz com essa ilusão =))


-- 05 - CRIAR COMANDO PARA ELIMINAR A TABELA

DROP TABLE dbo.Futebol

-- 06 - EXECUTAR O COMANDO ACIMA PARA RECRIAR A TABELA E INSERIR TODOS OS REGISTROS

-- NÃO PRECISA CRAIR COMANDO, BASTA EXECUTAR OS PASSOS => "PASSO 01 - CREATE TABLE" E "PASSO 01 - INSERT TABLE"


-- 07 - CRIAR COMANDO PARA LISTAR A QUANTIDADE DE TIMES POR ESTADO

SELECT Estado , count(*) AS Quantidade FROM dbo.Futebol
GROUP BY Estado
ORDER BY Quantidade DESC, estado ASC-- essa aqui foi de letra 

-- 08 - CRIAR COMANDO PARA APRESENTAR QUAIS ESTADOS ESTÃO REPRESENTADOS NA TABELA

-- FORMA 01

SELECT Estado FROM dbo.Futebol
GROUP BY Estado


-- FORMA 02

SELECT DISTINCT Estado FROM dbo.Futebol


-- 09 - CRIAR UM COMANDO PARA COLOCAR EM ORDEM ALFABÉTICA OS TIMES - NA ORDEM CRESCENTE E DECRESCENTE

-- ORDEM CRESCENTE

SELECT Equipes FROM dbo.Futebol
ORDER BY Equipes ASC


-- ORDER DECRESCENTE

SELECT Equipes FROM dbo.Futebol
ORDER BY Equipes DESC


-- 10 - CRIAR UM COMANDO LISTAR OS TIMES QUE SERÃO REBAIXADOS (CONSIDERAR COMO REGRA OS 4 ÚLTIMOS)

-- FORMA 01

SELECT Pos , Equipes FROM dbo.futebol
WHERE Pos between 17 and 20

/*

-- Todas as formas possíveis

WHERE Pos between 17 and 20
WHERE Pos >= 17 and Pos  <= 20
WHERE Pos >= 17
WHERE Pos > 16
WHERE Pos IN (17,18,19,20)

*/

-- FORMA 02

SELECT TOP 4 Pos, Equipes FROM dbo.futebol 
ORDER BY POS DESC -- Fazendo desse jeito eu pego os 4 ultimos mas, eu não consigo retornar do 17 ao 20


-- 11 - CRIAR UM COMANDO PARA APRESENTAR OS TIMES QUE SERÃO CLASSIFICADOS PARA LIBERTADORES (CONSIDERAR COMO REGRA OS 4 PRIMEIROS)


-- FORMA 01

SELECT Pos , Equipes FROM dbo.futebol
WHERE Pos between 1 and 4

/*

-- Todas as formas possíveis

WHERE Pos between  1 and 4
WHERE Pos >= 1 and Pos  <= 4
WHERE Pos <=4 
WHERE Pos < 5
WHERE Pos IN (1,2,3,4)

*/

-- FORMA 02

SELECT	TOP(4) 
			Pos
			, Equipes 
FROM	dbo.futebol

-- SELECT TOP 4 Pos, Equipes FROM dbo.futebol

-- 12 - SEPARAR EM TABELAS OS TIMES DE ACORDO COM O SEU ESTADO

-- FORMA 01

SELECT Equipes
INTO EquipesMG -- SP BA CE GO MT MG PR PM RJ RS SC
FROM dbo.futebol 
WHERE Estado = 'Minas Gerais' -- 'São Paulo'  'Bahia' 'Ceará'  'Goiás' 'Mato Grosso' 'Minas Gerais' 'Paraná' 'Pernambuco'
							-- 'Rio de Janeiro'  'Rio Grande do Sul' 'Santa Catarina'  

SELECT * FROM EquipesMG


SELECT POS, Equipes 
into dbo.SaoPaulo
FROM dbo.Futebol 
WHERE Estado = 'São Paulo'

SELECT POS, Equipes 
into dbo.RioGrandedoSul
FROM dbo.Futebol 
WHERE Estado = 'Rio Grande do Sul'

SELECT POS, Equipes 
into dbo.RiodeJaneiro
FROM dbo.Futebol 
WHERE Estado = 'Rio de Janeiro'

SELECT POS, Equipes 
into dbo.Ceara
FROM dbo.Futebol 
WHERE Estado = 'Ceará'

SELECT POS, Equipes 
into dbo.MinasGerais
FROM dbo.Futebol 
WHERE Estado = 'Minas Gerais'

SELECT POS, Equipes 
into dbo.Parana
FROM dbo.Futebol 
WHERE Estado = 'Paraná'

SELECT POS, Equipes 
into dbo.Pernambuco
FROM dbo.Futebol 
WHERE Estado = 'Pernambuco'

SELECT POS, Equipes 
into dbo.Goias
FROM dbo.Futebol 
WHERE Estado = 'Goiás'

SELECT POS, Equipes 
into dbo.MatoGrosso
FROM dbo.Futebol 
WHERE Estado = 'Mato Grosso'

SELECT POS, Equipes 
into dbo.Bahia
FROM dbo.Futebol 
WHERE Estado = 'Bahia'

SELECT POS, Equipes 
into dbo.SantaCatarina
FROM dbo.Futebol 
WHERE Estado = 'Santa Catarina'

-- FORMA 02

CREATE TABLE dbo.EquipesMG
(
Equipes varchar(100)
)

Insert INTO dbo.EquipesMG(Equipes) 
Select Equipes 
from dbo.Futebol 
where Estado = 'Minas Gerais' 

SELECT * FROM EquipesMG

-- 13 - CRIAR COMANDO PARA ELIMINAR AS TABELAS CRIADAS NO PASSO 12

DROP TABLE EquipesMG -- SP BA CE GO MT MG PR PM RJ RS SC

