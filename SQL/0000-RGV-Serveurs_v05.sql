/*
Query for FFF Report "0000-RGV-Serveurs_v05"
02/04/2015	Gaëtan VILLANT @ Dell

Input(s) : 
	- CollectionID 
*/

/*
DECLARE @CollectionID as varchar(8)
SET @CollectionID = 'FFF002D2'
*/

SELECT DISTINCT  
	SYS.Name0 AS [Nom de Machine], 
	OS.Description0 AS Description, 
	ISNULL(OS.Caption0, 'Unknown') AS [Type de Système Exploitation], 
	CASE SYS.AD_Site_Name0
		WHEN 'Default-First-Site-Name' THEN 'Télécity'
		WHEN '7800-Clairefontaine' THEN 'Clairefontaine'
		WHEN 'FFF' THEN 'Grenelle'
		END AS [Site Géogr.], 
	
	MAX(IPSub.IP_Subnets0) as 'Subnet' ,
	MAX (BDY.DisplayName) as Location,
		
	CONVERT(VARCHAR(10),OS.InstallDate0, 120) AS [Date Installation], 
	OS.TotalVisibleMemorySize0 AS Mémoire,
	CSYS.Model0 AS [Type de Machine], 
	ISNULL(OS.CSDVersion0, 'RTM') AS [Service Pack], 
	CONVERT(VARCHAR(16), OS.LastBootUpTime0, 120) AS [Last Reboot], 
	CONVERT(VARCHAR(10), BIOS.ReleaseDate0, 120) AS [Date de la carte Mère], 
	CONVERT(VARCHAR(10), WKS.LastHWScan, 120) AS [Dernier Inventaire],
	  
	PRO.Name0 AS Processeur, 
	(SELECT COUNT (*) from v_GS_PROCESSOR PRO where PRO.ResourceID = SYS.resourceID) as [Nb Proc], 	
		
	SYS.Virtual_Machine_Host_Name0 as [Nom d'Hôte],
	BIOS.SerialNumber0 AS [Serial Number],
	
	-- Sum Logical disk space, limited by the where clause to Fixed Disk . 
	SUM(cast(isnull(LDISK.Size0,'0') as BIGINT)) as Size, 
	SUM(cast(isnull(LDISK.FreeSpace0,'0') as BIGINT)) as FreeSpace, 
	SUM(cast(isnull(LDISK.Size0,'0') as BIGINT))- SUM(cast(isnull(LDISK.FreeSpace0,'0') as BIGINT)) as UsedSpace,
	(SUM(cast(isnull(LDISK.Size0,'0') as BIGINT))- SUM(cast(isnull(LDISK.FreeSpace0,'0') as BIGINT)))/1024 as [UsedSpace (GB)],

	vFFF.PublicProfileFirewall0 as [FWPublicProfile], 
	vFFF.StandardProfileFirewall0 as [FWStandardProfile], 
	vFFF.DomainProfileFirewall0 as [FWDomainProfile]
	
	FROM v_R_SYSTEM SYS
	LEFT JOIN dbo.v_GS_OPERATING_SYSTEM OS ON SYS.ResourceID = OS.ResourceID 
	LEFT JOIN dbo.v_GS_WORKSTATION_STATUS WKS ON SYS.ResourceID = WKS.ResourceID 
	LEFT JOIN dbo.v_GS_COMPUTER_SYSTEM CSYS ON SYS.ResourceID = CSYS.ResourceID 
	LEFT JOIN dbo.v_GS_PC_BIOS BIOS ON SYS.ResourceID = BIOS.ResourceID 
	LEFT JOIN dbo.v_GS_System GSSYS ON SYS.ResourceID = GSSYS.ResourceID 
	LEFT JOIN dbo.v_GS_FFF0 vFFF on SYS.ResourceID = vFFF.ResourceID
	LEFT JOIN v_GS_LOGICAL_DISK LDISK on LDISK.ResourceID = SYS.ResourceID
	LEFT JOIN v_FullCollectionMembership FCM on SYS.ResourceID = FCM.ResourceID 
	OUTER APPLY (SELECT TOP 1 * from v_GS_PROCESSOR PRO  where PRO.ResourceID = SYS.resourceID) PRO
	OUTER APPLY (SELECT TOP 1 * from v_RA_System_IPSubnets IPSub where IPSub.ResourceID = SYS.resourceID and (IPSub.IP_Subnets0 not like '10.25%')) IPSub
	LEFT JOIN vSMS_Boundary BDY on IPSub.IP_Subnets0 = BDY.Value
	
	 WHERE FCM.CollectionID = @CollectionID
	 
	 --(GSSYS.SystemRole0 LIKE 'Server') and (SYS.Name0 like 'FFF%' or sys.Name0 like '%tobin%') 
	 
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
	BIOS.SerialNumber0, 
	vFFF.PublicProfileFirewall0, vFFF.StandardProfileFirewall0, vFFF.DomainProfileFirewall0
	
	ORDER BY 1