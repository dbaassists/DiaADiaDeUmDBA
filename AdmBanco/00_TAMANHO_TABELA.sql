/*

Tabela							Linhas		Reservado	Dados		Indice	NaoUtilizado
##TMP_TB_TransacaoOrdemVenda	10120921	11974760	11974608	96		56

Tabela							Linhas		Reservado	Dados		Indice	NaoUtilizado
##TMP_TB_TransacaoOrdemVenda	10120921	01806808	01806600		80		128

*/

USE SGBODS
GO

Declare @TABLE VARCHAR(100)
SET @TABLE = 'TB_TransacaoOrdemVenda'

SELECT
    OBJECT_NAME(object_id) As Tabela, Rows As Linhas,
    SUM(Total_Pages * 8) As Reservado,
    SUM(CASE WHEN Index_ID > 1 THEN 0 ELSE Data_Pages * 8 END) As Dados,
        SUM(Used_Pages * 8) -
        SUM(CASE WHEN Index_ID > 1 THEN 0 ELSE Data_Pages * 8 END) As Indice,
    SUM((Total_Pages - Used_Pages) * 8) As NaoUtilizado
FROM
    sys.partitions As P WITH(NOLOCK)
    INNER JOIN sys.allocation_units As A WITH(NOLOCK)  ON P.hobt_id = A.container_id

WHERE OBJECT_NAME(object_id) IN (@TABLE)
GROUP BY OBJECT_NAME(object_id), Rows
ORDER BY Tabela


SELECT
    OBJECT_NAME(object_id) As Tabela, Rows As Linhas,
    SUM(Total_Pages * 8) As Reservado,
    SUM(CASE WHEN Index_ID > 1 THEN 0 ELSE Data_Pages * 8 END) As Dados,
        SUM(Used_Pages * 8) -
        SUM(CASE WHEN Index_ID > 1 THEN 0 ELSE Data_Pages * 8 END) As Indice,
    SUM((Total_Pages - Used_Pages) * 8) As NaoUtilizado
FROM
    SGBODS.sys.partitions As P WITH(NOLOCK)
    INNER JOIN SGBODS.sys.allocation_units As A WITH(NOLOCK)  ON P.hobt_id = A.container_id

WHERE OBJECT_NAME(object_id) IN ( @TABLE )
GROUP BY OBJECT_NAME(object_id), Rows
ORDER BY Tabela