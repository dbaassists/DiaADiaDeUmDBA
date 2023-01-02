SELECT 'GRANT SELECT ON [' + S.name + '].[' + T.NAME + '] TO [brsgdb-compass] ' 
FROM SYS.TABLES T, SYS.schemas S
WHERE T.schema_id = S.schema_id
AND S.name = 'COMPASS'

