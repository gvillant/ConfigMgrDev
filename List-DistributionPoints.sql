
SELECT SiteCode
      ,RoleName
      ,ServerName
      ,CASE WHEN (CHARINDEX('.',ServerName) = 0)  THEN UPPER(ServerName)
	ELSE UPPER(SUBSTRING (ServerName,0,CHARINDEX('.',ServerName)))
	END	as Name 

  FROM v_SystemResourceList

  WHERE RoleName = 'SMS Distribution Point'

  order by ServerName
  