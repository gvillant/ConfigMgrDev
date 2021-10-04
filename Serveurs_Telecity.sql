	SELECT DISTINCT 
	SYS.Name0 AS [Nom de Machine], 
	OS.Description0 AS Description, 
	OS.Caption0 AS [Type de Système Exploitation], 
	CASE SYS.AD_Site_Name0
		WHEN 'Default-First-Site-Name' THEN 'Télécity'
		WHEN '7800-Clairefontaine' THEN 'Clairefontaine'
		WHEN 'FFF' THEN 'Grenelle'
		END AS [Site Géogr.], 
	MAX(IPSub.IP_Subnets0) as 'Subnet' ,MAX (BDY.DisplayName) as Location,
	CONVERT(VARCHAR(10),OS.InstallDate0, 120) AS [Date Installation], 
	OS.TotalVisibleMemorySize0 AS Mémoire,
	CSYS.Model0 AS [Type de Machine], 
	ISNULL(OS.CSDVersion0, 'RTM') AS [Service Pack], 
	CONVERT(VARCHAR(16), OS.LastBootUpTime0, 120) AS [Last Reboot], 
	CONVERT(VARCHAR(10), BIOS.ReleaseDate0, 120) AS [Date de la carte Mère], 
	CONVERT(VARCHAR(10), WKS.LastHWScan, 120) AS [Dernier Inventaire],  
	PRO.Name0 AS Processeur, 
	SYS.Virtual_Machine_Host_Name0 as [Nom d'Hôte],
	--ISNULL (vm.Type_dHote,'NA')	AS [Type d'Hôte], 
	COUNT(PRO.Name0) AS [Nb Processeur], 
	BIOS.SerialNumber0 AS [Serial Number],
	vFFF.PublicProfileFirewall0 as [FWPublicProfile], 
	vFFF.StandardProfileFirewall0 as [FWStandardProfile], 
	vFFF.DomainProfileFirewall0 as [FWDomainProfile],
	vFFF.BackupDB0 AS [SUPBackupDB] ,
	vFFF.BackupSYS0 AS [SUPBackupSYS] ,
	vFFF.ExploitDB0 AS [SUPExploitDB] ,
	vFFF.ExploitSYS0 AS [SUPExploitSYS],
	vFFF.WarrantyEndDate0 AS [SUPWarrantyEndDate],
	vFFF.WarrantyHW0 AS [SUPWarrantyHW],
	vFFF.WarrantySLA0 AS [SUPWarrantySLA]
	
	FROM v_R_SYSTEM SYS
	LEFT JOIN dbo.v_GS_OPERATING_SYSTEM OS ON SYS.ResourceID = OS.ResourceID 
	LEFT JOIN dbo.v_GS_WORKSTATION_STATUS WKS ON SYS.ResourceID = WKS.ResourceID 
	LEFT JOIN dbo.v_GS_COMPUTER_SYSTEM CSYS ON SYS.ResourceID = CSYS.ResourceID 
	LEFT JOIN dbo.v_GS_PC_BIOS BIOS ON SYS.ResourceID = BIOS.ResourceID 
	LEFT JOIN dbo.v_GS_System GSSYS ON SYS.ResourceID = GSSYS.ResourceID 
	LEFT JOIN dbo.v_GS_PROCESSOR PRO ON SYS.ResourceID = PRO.ResourceID
	LEFT JOIN dbo.v_GS_FFF0 vFFF on SYS.ResourceID = vFFF.ResourceID
	LEFT JOIN v_RA_System_IPSubnets IPSub on SYS.ResourceID = IPSub.ResourceID 
	LEFT JOIN vSMS_Boundary BDY on IPSub.IP_Subnets0 = BDY.Value
	
	WHERE (GSSYS.SystemRole0 LIKE 'Server') and (SYS.Name0 like 'FFF%') 
	
	--and (ipsub.IP_Subnets0 like '172%' or ipsub.IP_Subnets0 like '10%' or ipsub.IP_Subnets0 like '192%' )
	/*and IPSub.IP_Subnets0 like '169%' 
	and sys.name0 not in (
		SELECT SYS.Name0
		FROM v_R_SYSTEM SYS
		LEFT JOIN dbo.v_GS_OPERATING_SYSTEM OS ON SYS.ResourceID = OS.ResourceID 
		LEFT JOIN dbo.v_GS_WORKSTATION_STATUS WKS ON SYS.ResourceID = WKS.ResourceID 
		LEFT JOIN dbo.v_GS_COMPUTER_SYSTEM CSYS ON SYS.ResourceID = CSYS.ResourceID 
		LEFT JOIN dbo.v_GS_PC_BIOS BIOS ON SYS.ResourceID = BIOS.ResourceID 
		LEFT JOIN dbo.v_GS_System GSSYS ON SYS.ResourceID = GSSYS.ResourceID 
		LEFT JOIN dbo.v_GS_PROCESSOR PRO ON SYS.ResourceID = PRO.ResourceID
		LEFT JOIN dbo.v_GS_FFF0 vFFF on SYS.ResourceID = vFFF.ResourceID
		LEFT JOIN v_RA_System_IPSubnets IPSub on SYS.ResourceID = IPSub.ResourceID 
		LEFT JOIN vSMS_Boundary BDY on IPSub.IP_Subnets0 = BDY.Value
		
		WHERE (GSSYS.SystemRole0 LIKE 'Server') and (SYS.Name0 like 'FFF%') and (ipsub.IP_Subnets0 like '169%')
		) */
		
	GROUP BY 
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
	vFFF.PublicProfileFirewall0, vFFF.StandardProfileFirewall0, vFFF.DomainProfileFirewall0,
	vFFF.BackupDB0,vFFF.BackupSYS0,vFFF.ExploitDB0,vFFF.ExploitSYS0,vFFF.WarrantyEndDate0,vFFF.WarrantyHW0,vFFF.WarrantySLA0
	
	ORDER BY 1