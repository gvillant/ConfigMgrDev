/*
Query for FFF Report "0000-RGV-Clients"
26/08/2015	Ga�tan VILLANT @ Dell

Input(s) : 
	- CollectionID 
*/
--/*

DECLARE @CollectionID as varchar(8)
SET @CollectionID = 'PR1001F9' --'FFF002D2'
--*/

SELECT DISTINCT  
		CASE WHEN (CHARINDEX('.',SYS.Name0) = 0)  THEN UPPER(SYS.Name0)
	ELSE UPPER(SUBSTRING (SYS.Name0,0,CHARINDEX('.',SYS.Name0)))
	END	as [Name],	
	SYS.Name0 AS [FullName],
	
	--UMTR.RelationshipResourceID,
		SUBSTRING(
        (
            Select ', '+UDA.UniqueUserName  AS [text()]
            From v_UserMachineRelationship UDA 
            LEFT JOIN v_UserMachineTypeRelation  umtr on uda.RelationshipResourceID = umtr.RelationshipResourceID  
            Where UDA.MachineResourceID = SYS.ResourceID and umtr.RelationshipResourceID IS NOT NULL
            ORDER BY UDA.UniqueUserName
            For XML PATH ('')
        ), 2, 1000) as UDA,
    (Select count(UDA.UniqueUserName) 
    From v_UserMachineRelationship UDA
            LEFT JOIN v_UserMachineTypeRelation  umtr on uda.RelationshipResourceID = umtr.RelationshipResourceID  
            Where UDA.MachineResourceID = SYS.ResourceID and umtr.RelationshipResourceID IS NOT NULL) as UDACount,
    TOPC.TopConsoleUser0 as TopConsoleUser,            
	--UDA.UniqueUserName,
	ISNULL(OS.Caption0, 'Unknown') AS [OSCaption], 
	SYS.Operating_System_Name_and0 OSVersion, 
CASE 
	WHEN SYS.Operating_System_Name_and0 like '%Workstation 5.0%' THEN 'Windows 2000'
	WHEN SYS.Operating_System_Name_and0 like '%Workstation 5.1%' THEN 'Windows XP'
	WHEN SYS.Operating_System_Name_and0 like '%Workstation 5.2%' THEN 'Windows XP'
	WHEN SYS.Operating_System_Name_and0 like '%Workstation 6.0%' THEN 'Windows Vista'
	WHEN SYS.Operating_System_Name_and0 like '%Workstation 6.1%' THEN 'Windows 7'
	WHEN SYS.Operating_System_Name_and0 like '%Workstation 6.2%' THEN 'Windows 8'
	WHEN SYS.Operating_System_Name_and0 like '%Workstation 6.3%' THEN 'Windows 8.1'
	WHEN SYS.Operating_System_Name_and0 like '%Workstation 10%' THEN 'Windows 10'
	WHEN SYS.Operating_System_Name_and0 like '%OS X%' THEN 'Mac OS X'
	WHEN SYS.Operating_System_Name_and0 like '%Server 5.0%' THEN 'Server 2000'
	WHEN SYS.Operating_System_Name_and0 like '%Server 5.2%' THEN 'Server 2003'
	WHEN SYS.Operating_System_Name_and0 like '%Server 6.0%' THEN 'Server 2008'
	WHEN SYS.Operating_System_Name_and0 like '%Server 6.1%' THEN 'Server 2008 R2'
	WHEN SYS.Operating_System_Name_and0 like '%Server 6.2%' THEN 'Server 2012'
	WHEN SYS.Operating_System_Name_and0 like '%Server 6.3%' THEN 'Server 2012 R2'
	WHEN SYS.Operating_System_Name_and0 like '%RHEL 5%' THEN 'RHEL 5'
	WHEN SYS.Operating_System_Name_and0 like '%RHEL 6%' THEN 'RHEL 6'
	WHEN SYS.Operating_System_Name_and0 like 'CentOS%' THEN 'CentOS'
	ELSE 'Unknown'
	END as [OSVer],
	
	CASE 
	WHEN GSSYS.SystemType0 like '%X86%' THEN 'x86'
	WHEN GSSYS.SystemType0 like '%X64%' THEN 'x64'
	END as SystemType,
	
	ISNULL(OS.CSDVersion0, 'RTM') AS [Service Pack], 
	
	CASE SYS.AD_Site_Name0
		WHEN 'Default-First-Site-Name' THEN 'Telecity'
		WHEN '7800-Clairefontaine' THEN 'Clairefontaine'
		WHEN 'FFF' THEN 'Grenelle'
		END AS [Location (AD)], 
	
	MAX(IPSub.IP_Subnets0) as 'Subnet' ,
	MAX (BDY.DisplayName) as Location,
		
	CONVERT(VARCHAR(10),OS.InstallDate0, 120) AS [Date Installation], 
	OS.TotalVisibleMemorySize0 AS Memoire,
	ISNULL(CSYS.Model0, 'Unknown') AS [Type de Machine], 
	ISNULL(BIOS.SerialNumber0, 'Unknown') AS [SerialNumber], 
	CONVERT(VARCHAR(16), OS.LastBootUpTime0, 120) AS [Dernier Reboot], 
	CONVERT(VARCHAR(10), BIOS.ReleaseDate0, 120) AS [Date de la carte Mere], 
	CONVERT(VARCHAR(10), WKS.LastHWScan, 120) AS [Dernier Inventaire],
	CHS.LastActiveTime AS [Derniere Activite],
	CHS.ClientActiveStatus as [Client Actif],
	 PRO.Name0 AS Processeur, 
	(SELECT COUNT (*) from v_GS_PROCESSOR PRO where PRO.ResourceID = SYS.resourceID) as [Nb Proc], 	
	
	-- Virtual Machine
	SYS.Is_Virtual_Machine0 as isVM,	
	SYS.Virtual_Machine_Host_Name0 as [VM Host],
	CSYS.Model0,
	
	CASE 
	WHEN SYS.Is_Virtual_Machine0 = '1' Then 'Virtual'
	WHEN SYS.Is_Virtual_Machine0 = '0' Then 'Physical'
	ELSE 	 
	 ISNULL(CONVERT(VARCHAR(10),SYS.Is_Virtual_Machine0), 
		CASE 
		WHEN CSYS.Model0 LIKE 'Virtual%' THEN 'Virtual'
		WHEN CSYS.Model0 IS NULL THEN 'Unknown'
		ELSE 'Physical'
		END) END as isVM2,
	
SYS.AgentEdition0 as AgentEdition ,
CASE 
	WHEN SYS.AgentEdition0 = '0' THEN 'Windows'
	WHEN SYS.AgentEdition0 = '1' THEN 'Windows 8.1 OMADM'
	WHEN SYS.AgentEdition0 = '2' THEN 'Windows Mobile 6'
	WHEN SYS.AgentEdition0 = '4' THEN 'Windows Phone'
	WHEN SYS.AgentEdition0 = '5' THEN 'OS X'
	WHEN SYS.AgentEdition0 = '7' THEN 'Embedded'
	WHEN SYS.AgentEdition0 = '8' THEN 'iPhone'
	WHEN SYS.AgentEdition0 = '9' THEN 'Ipad'
	WHEN SYS.AgentEdition0 = '11' THEN 'Android'
	WHEN SYS.AgentEdition0 = '13' THEN 'Linux/Unix'	
	ELSE 'Unknown' 
	END as AgentEditionType,
	 	
	-- Sum Logical disk space, limited by the where clause to Fixed Disk . 
	SUM(cast(isnull(LDISK.Size0,'0') as BIGINT)) as Size, 
	SUM(cast(isnull(LDISK.FreeSpace0,'0') as BIGINT)) as FreeSpace, 
	SUM(cast(isnull(LDISK.Size0,'0') as BIGINT))- SUM(cast(isnull(LDISK.FreeSpace0,'0') as BIGINT)) as UsedSpace,
	(SUM(cast(isnull(LDISK.Size0,'0') as BIGINT))- SUM(cast(isnull(LDISK.FreeSpace0,'0') as BIGINT)))/1024 as [UsedSpace (GB)]
	
	FROM v_R_SYSTEM SYS
	LEFT JOIN v_GS_OPERATING_SYSTEM OS ON SYS.ResourceID = OS.ResourceID 
	LEFT JOIN v_GS_WORKSTATION_STATUS WKS ON SYS.ResourceID = WKS.ResourceID 
	LEFT JOIN v_GS_COMPUTER_SYSTEM CSYS ON SYS.ResourceID = CSYS.ResourceID 
	LEFT JOIN v_GS_PC_BIOS BIOS ON SYS.ResourceID = BIOS.ResourceID 
	LEFT JOIN v_GS_System GSSYS ON SYS.ResourceID = GSSYS.ResourceID 
	LEFT JOIN v_GS_LOGICAL_DISK LDISK on LDISK.ResourceID = SYS.ResourceID
	LEFT JOIN v_FullCollectionMembership FCM on SYS.ResourceID = FCM.ResourceID 
	OUTER APPLY (SELECT TOP 1 * from v_GS_PROCESSOR PRO  where PRO.ResourceID = SYS.resourceID) PRO
	OUTER APPLY (SELECT TOP 1 * from v_RA_System_IPSubnets IPSub where IPSub.ResourceID = SYS.resourceID and (IPSub.IP_Subnets0 not like '10.25%')) IPSub
	LEFT JOIN vSMS_Boundary BDY on IPSub.IP_Subnets0 = BDY.Value
	LEFT JOIN v_CH_ClientSummary CHS on SYS.ResourceID = CHS.ResourceID
	
	LEFT JOIN v_GS_SYSTEM_CONSOLE_USAGE_MAXGROUP TOPC on SYS.ResourceID = TOPC.ResourceID
	--Get Device Affinity
	OUTER APPLY (SELECT UDA.* from v_UserMachineRelationship UDA
	LEFT JOIN v_UserMachineTypeRelation UMTR on UDA.RelationshipResourceID = UMTR.RelationshipResourceID
	where UDA.MachineResourceID = SYS.resourceID and UMTR.RelationshipResourceID IS NOT NULL) UDA
	
	--LEFT JOIN v_UserMachineRelationship UDA on SYS.ResourceID = UDA.MachineResourceID AND UDA.RelationActive = 1 
	--LEFT join v_UserMachineTypeRelation  umtr on uda.RelationshipResourceID = umtr.RelationshipResourceID and umtr.RelationshipResourceID IS NOT NULL
	
	 WHERE FCM.CollectionID = @CollectionID --and umtr.RelationshipResourceID IS NOT NULL
	 
	 --and csys.Model0 is null
	 --(GSSYS.SystemRole0 LIKE 'Server') and (SYS.Name0 like 'FFF%' or sys.Name0 like '%tobin%') 
	 
		--and (LDISK.DriveType0 = 0 or LDISK.DriveType0 = 3 or LDISK.DriveType0 is NULL)
	 	 --and sys.Name0 like '%exc-BDD02%'
		--and (ipsub.IP_Subnets0 like '172%' or ipsub.IP_Subnets0 like '10%' or ipsub.IP_Subnets0 like '192%' )
		/*and IPSub.IP_Subnets0 like '169%' 
		) */
		
	GROUP BY 
	--umtr.RelationshipResourceID,
	SYS.ResourceID,
	SYS.Name0, 
	UDA.UniqueUserName,
	TOPC.TopConsoleUser0,
	OS.Description0, 
	GSSYS.SystemType0,
	OS.Caption0,SYS.Operating_System_Name_and0,
	OS.CSDVersion0, 
	SYS.AD_Site_Name0, 
	OS.InstallDate0, 
	OS.TotalVisibleMemorySize0, 
	CSYS.Model0, SYS.AgentEdition0,
	SYS.Virtual_Machine_Host_Name0,SYS.Is_Virtual_Machine0 ,
	OS.CSDVersion0, 
	BIOS.ReleaseDate0,
	PRO.Name0, 
	OS.LastBootUpTime0, 
	WKS.LastHWScan, 
	BIOS.SerialNumber0,
	CHS.LastActiveTime,
	CHS.ClientActiveStatus
	
	ORDER BY 1