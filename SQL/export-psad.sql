/*
Query for STAGO Report PSAD export"
13/03/2018	Gaëtan VILLANT @ Dell

Input(s) : 
	- CollectionID 
*/
--/*

DECLARE @CollectionID as varchar(8)
SET @CollectionID = 'SMS00001' --'FFF002D2'
--*/

SELECT DISTINCT  
		CASE WHEN (CHARINDEX('.',SYS.Name0) = 0)  THEN UPPER(SYS.Name0)
	ELSE UPPER(SUBSTRING (SYS.Name0,0,CHARINDEX('.',SYS.Name0)))
	END	as [Name],	
	CONVERT(VARCHAR(10),OS.InstallDate0, 112) AS InstallDate, 
	UPPER(SYS.Name0 + '_' + CONVERT(VARCHAR(10),OS.InstallDate0, 112)) as 'PSAD_ID',
	--UMTR.RelationshipResourceID,
	(Select count(UDA.UniqueUserName) From v_UserMachineRelationship UDA
            LEFT JOIN v_UserMachineTypeRelation  umtr on uda.RelationshipResourceID = umtr.RelationshipResourceID  
            Where UDA.MachineResourceID = SYS.ResourceID and umtr.RelationshipResourceID IS NOT NULL) as UDACount,

	SUBSTRING(( Select ', '+UDA.UniqueUserName  AS [text()]
					From v_UserMachineRelationship UDA 
					LEFT JOIN v_UserMachineTypeRelation  umtr on uda.RelationshipResourceID = umtr.RelationshipResourceID  
					Where UDA.MachineResourceID = SYS.ResourceID and umtr.RelationshipResourceID IS NOT NULL
					ORDER BY UDA.UniqueUserName
					For XML PATH ('')), 2, 1000) as 'DeviceAffinity(Login)',

	SUBSTRING(( Select ', '+ (select TOP 1 usr.displayName0 from v_R_User usr where  usr.Unique_User_Name0 = UDA.UniqueUserName)  AS [text()]
					From v_UserMachineRelationship UDA 
					LEFT JOIN v_UserMachineTypeRelation  umtr on uda.RelationshipResourceID = umtr.RelationshipResourceID  
					Where UDA.MachineResourceID = SYS.ResourceID and umtr.RelationshipResourceID IS NOT NULL
					ORDER BY UDA.UniqueUserName
					For XML PATH ('')), 2, 1000) as 'DeviceAffinity(DisplayName)',
					
	--UDA.UniqueUserName,
	--(select TOP 1 usr.displayName0 from v_R_User usr where  usr.Unique_User_Name0 = UDA.UniqueUserName) as Test,

    TOPC.TopConsoleUser0 as 'TopConsoleUser(Login)',
	(select TOP 1 usr.displayName0 from v_R_User usr where usr.Unique_User_Name0 = TOPC.TopConsoleUser0) as 'TopConsoleUser(DisplayName)',

	SYS.Resource_Domain_OR_Workgr0 as Domain,
CASE 
	WHEN SYS.Operating_System_Name_and0 like '%Workstation 5.0%' THEN 'Windows 2000'
	WHEN SYS.Operating_System_Name_and0 like '%Workstation 5.1%' THEN 'Windows XP'
	WHEN SYS.Operating_System_Name_and0 like '%Workstation 5.2%' THEN 'Windows XP'
	WHEN SYS.Operating_System_Name_and0 like '%Workstation 6.0%' THEN 'Windows Vista'
	WHEN SYS.Operating_System_Name_and0 like '%Workstation 6.1%' THEN 'Windows 7'
	WHEN SYS.Operating_System_Name_and0 like '%Workstation 6.2%' THEN 'Windows 8'
	WHEN SYS.Operating_System_Name_and0 like '%Workstation 6.3%' THEN 'Windows 8.1'
	WHEN SYS.Operating_System_Name_and0 like '%Workstation 10%' THEN 
		CASE	WHEN OS.BuildNumber0 ='10586' THEN 'Windows 10 1511'
				WHEN OS.BuildNumber0 ='14393' THEN 'Windows 10 1607'
				WHEN OS.BuildNumber0 ='15063' THEN 'Windows 10 1703'
				WHEN OS.BuildNumber0 ='16299' THEN 'Windows 10 1709'
				WHEN OS.BuildNumber0 ='17093' THEN 'Windows 10 1803'
		END
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
	END as [OSVer]
	
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
	 and SYS.Operating_System_Name_and0 like '%Workstation%'
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
	CHS.ClientActiveStatus,
	SYS.Resource_Domain_OR_Workgr0,
	OS.BuildNumber0
	
	
	ORDER BY 1