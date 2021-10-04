/*
Query for Server Report 
02/04/2015	Gaëtan VILLANT @ Dell

Input(s) : 
	- CollectionID 
*/
/*

DECLARE @CollectionID as varchar(8)
SET @CollectionID = 'STG00816'
*/

SELECT DISTINCT  
--		CASE WHEN (CHARINDEX('.',SYS.Name0) = 0)  THEN UPPER(SYS.Name0)
--	ELSE UPPER(SUBSTRING (SYS.Name0,0,CHARINDEX('.',SYS.Name0)))
--	END	as [Nom de Machine],	
	SYS.Name0 as 'Name',
	OS.Description0 as 'Description', 
	ISNULL(OS.Caption0, 'Unknown') as 'OS',
	SYS.AD_Site_Name0 as 'AD Site', 
	MAX(IPSub.IP_Subnets0) as 'Subnet',
	MAX (BDY.DisplayName) as 'Location',
--	CONVERT(VARCHAR(10),OS.InstallDate0, 120) AS [Install date], 
	OS.InstallDate0 as 'OSInstallDate',
	OS.TotalVisibleMemorySize0 as 'RAMSize',
	CSYS.Model0 AS 'Model', 
	ISNULL(OS.CSDVersion0, 'RTM') as 'ServicePack',
	--CONVERT(VARCHAR(16), OS.LastBootUpTime0, 120) as 'BootTime', 
	OS.LastBootUpTime0 as 'BootTime',
	--CONVERT(VARCHAR(10), BIOS.ReleaseDate0, 120) AS [Date de la carte Mère], 
	--CONVERT(VARCHAR(10), WKS.LastHWScan, 120) AS [Dernier Inventaire],
	  WKS.LastHWScan as 'LastHWInventory',
	PRO.Name0 as 'Processor', 
	(SELECT COUNT (*) from v_GS_PROCESSOR PRO where PRO.ResourceID = SYS.resourceID) as 'ProcessorCount', 	
		
	SYS.Virtual_Machine_Host_Name0 as 'VirtuHostName',
	BIOS.SerialNumber0 AS SerialNumber,
	
	-- Sum Logical disk space, limited by the where clause to Fixed Disk . 
	SUM(cast(isnull(LDISK.Size0,'0') as BIGINT)) as Size, 
	SUM(cast(isnull(LDISK.FreeSpace0,'0') as BIGINT)) as FreeSpace, 
	SUM(cast(isnull(LDISK.Size0,'0') as BIGINT))- SUM(cast(isnull(LDISK.FreeSpace0,'0') as BIGINT)) as UsedSpace,
	(SUM(cast(isnull(LDISK.Size0,'0') as BIGINT))- SUM(cast(isnull(LDISK.FreeSpace0,'0') as BIGINT)))/1024 as [UsedSpace (GB)]
	
	FROM v_R_SYSTEM SYS
	LEFT JOIN dbo.v_GS_OPERATING_SYSTEM OS ON SYS.ResourceID = OS.ResourceID 
	LEFT JOIN dbo.v_GS_WORKSTATION_STATUS WKS ON SYS.ResourceID = WKS.ResourceID 
	LEFT JOIN dbo.v_GS_COMPUTER_SYSTEM CSYS ON SYS.ResourceID = CSYS.ResourceID 
	LEFT JOIN dbo.v_GS_PC_BIOS BIOS ON SYS.ResourceID = BIOS.ResourceID 
	LEFT JOIN dbo.v_GS_System GSSYS ON SYS.ResourceID = GSSYS.ResourceID 
	LEFT JOIN v_GS_LOGICAL_DISK LDISK on LDISK.ResourceID = SYS.ResourceID
	LEFT JOIN v_FullCollectionMembership FCM on SYS.ResourceID = FCM.ResourceID 
	OUTER APPLY (SELECT TOP 1 * from v_GS_PROCESSOR PRO  where PRO.ResourceID = SYS.resourceID) PRO
	OUTER APPLY (SELECT TOP 1 * from v_RA_System_IPSubnets IPSub where IPSub.ResourceID = SYS.resourceID and (IPSub.IP_Subnets0 not like '10.25%')) IPSub
	LEFT JOIN vSMS_Boundary BDY on IPSub.IP_Subnets0 = BDY.Value
	
	WHERE FCM.CollectionID = @CollectionID
	 
	 --(GSSYS.SystemRole0 LIKE 'Server') and (SYS.Name0 like 'ZZZ' or sys.Name0 like 'YYY') 
	 
		--and (LDISK.DriveType0 = 0 or LDISK.DriveType0 = 3 or LDISK.DriveType0 is NULL)
	 	 --and sys.Name0 like '%exc-BDD02%'
		--and (ipsub.IP_Subnets0 like '172%' or ipsub.IP_Subnets0 like '10%' or ipsub.IP_Subnets0 like '192%' )
		/*and IPSub.IP_Subnets0 like '169%' 
		) */
		
	GROUP BY 
	SYS.ResourceID,
	SYS.Name0, 
	OS.Description0, 
	OS.Caption0,
	OS.CSDVersion0, 
	SYS.AD_Site_Name0, 
	OS.InstallDate0, 
	OS.TotalVisibleMemorySize0, 
	CSYS.Model0, 
	SYS.Virtual_Machine_Host_Name0,
	OS.CSDVersion0, 
	BIOS.ReleaseDate0,
	PRO.Name0, 
	OS.LastBootUpTime0, 
	WKS.LastHWScan, 
	BIOS.SerialNumber0
	
	ORDER BY 1