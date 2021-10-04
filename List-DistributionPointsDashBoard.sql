/*
This query will return All distribution point servers, Disk usage, OS and Hardware information.
Created 21/09/2015 by Gaëtan Villant @ Dell.
*/


--DROP TABLE #TempSiteSystem
CREATE TABLE #TempSiteSystem
          (
          ServerName varchar(255),
          Name varchar(25),
          BytesFree varchar(25),
          BytesTotal varchar(25),
          PercentFree varchar(25),
          TimeReported datetime,
          DriveLetter varchar(3),
          DownSince datetime,
          SiteCode varchar(3),
          RoleName varchar(255)
          )
insert into #TempSiteSystem
SELECT DISTINCT 
      SYSRL.ServerName
      ,CASE WHEN (CHARINDEX('.',SYSRL.ServerName) = 0)  THEN UPPER(SYSRL.ServerName)
	ELSE UPPER(SUBSTRING (SYSRL.ServerName,0,CHARINDEX('.',SYSRL.ServerName)))
	END	as Name, 
	SSS.BytesFree, SSS.BytesTotal, SSS.PercentFree, SSS.TimeReported
	,CASE WHEN (CHARINDEX('$',SSS.SiteObject) = 0)  THEN ''
	ELSE RIGHT(UPPER(SUBSTRING (SSS.SiteObject,0,CHARINDEX('$',SSS.SiteObject))),1)
	END	as DriveLetter,
	SSS.DownSince,
	SYSRL.SiteCode
    ,SYSRL.RoleName

  FROM v_SystemResourceList SYSRL
	LEFT JOIN v_SiteSystemSummarizer SSS on SYSRL.NALPath = SSS.SiteSystem and SYSRL.RoleName = SSS.Role
	
  WHERE RoleName = 'SMS Distribution Point'

  order by ServerName,DriveLetter
 
 SELECT TSS.* ,
 
CASE 
	WHEN SYS.Operating_System_Name_and0 like '%Workstation 5.0%' THEN 'Windows 2000'
	WHEN SYS.Operating_System_Name_and0 like '%Workstation 5.1%' THEN 'Windows XP'
	WHEN SYS.Operating_System_Name_and0 like '%Workstation 5.2%' THEN 'Windows XP'
	WHEN SYS.Operating_System_Name_and0 like '%Workstation 6.1%' THEN 'Windows 7'
	WHEN SYS.Operating_System_Name_and0 like '%Workstation 6.2%' THEN 'Windows 8'
	WHEN SYS.Operating_System_Name_and0 like '%Workstation 6.3%' THEN 'Windows 8.1'
	WHEN SYS.Operating_System_Name_and0 like '%Workstation 10.0%' THEN 'Windows 10'
	WHEN SYS.Operating_System_Name_and0 like '%Server 5.0%' THEN 'Server 2000'
	WHEN SYS.Operating_System_Name_and0 like '%Server 5.2%' THEN 'Server 2003'
	WHEN SYS.Operating_System_Name_and0 like '%Server 6.0%' THEN 'Server 2008'
	WHEN SYS.Operating_System_Name_and0 like '%Server 6.1%' THEN 'Server 2008 R2'
	WHEN SYS.Operating_System_Name_and0 like '%Server 6.2%' THEN 'Server 2012'
	WHEN SYS.Operating_System_Name_and0 like '%Server 6.3%' THEN 'Server 2012 R2'
	ELSE 'Unknown'
	END as [OSVer],
CASE 
	WHEN SYS.Operating_System_Name_and0 like '%Workstation%' THEN 'Workstation'
	WHEN SYS.Operating_System_Name_and0 like '%Server%' THEN 'Server'
	ELSE 'Unknown'
	END as [OSType],
	CSYS.Model0 as Model,
	BIOS.SerialNumber0 as SerialNumber,
	MAX(HWSCAN.LastHWScan) as LastHWScan
	
 FROM #TempSiteSystem TSS
 LEFT JOIN v_R_System SYS on SYS.Name0 = TSS.Name
 LEFT JOIN v_GS_COMPUTER_SYSTEM CSYS on SYS.ResourceID = CSYS.ResourceID 
 LEFT JOIN v_GS_WORKSTATION_STATUS HWSCAN on SYS.ResourceID = HWSCAN.ResourceID 
 LEFT JOIN v_GS_PC_BIOS BIOS on SYS.ResourceID = BIOS.ResourceID  
 
 GROUP BY TSS.ServerName,TSS.Name, TSS.BytesFree, TSS.BytesTotal, TSS.PercentFree, TSS.TimeReported,TSS.DriveLetter,TSS.DownSince,TSS.SiteCode,TSS.RoleName,
			SYS.Operating_System_Name_and0,CSYS.Model0,BIOS.SerialNumber0
  
  
    DROP TABLE #TempSiteSystem
          