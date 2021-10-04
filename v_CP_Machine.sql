SELECT  LastErrorCode, CASE LastErrorCode 
WHEN '-2147023174' THEN 'WMI'
WHEN '1305' THEN 'XP SP2'
WHEN '120' THEN 'ALREADY CLIENT'
WHEN '53' THEN 'NETWORK'
END AS 'Description',
status, count(distinct Name) as count

  FROM [CM_STG].[dbo].[v_CP_Machine]
 
  where Status <> 0
  group by LastErrorCode, Status
  ORDER BY LastErrorCode,Status
  