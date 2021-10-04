SELECT DISTINCT 
SYS.Netbios_Name0 as Name,
CASE WHEN (CHARINDEX('.',SYS.Resource_Domain_OR_Workgr0) = 0)  THEN UPPER(SYS.Resource_Domain_OR_Workgr0)
	ELSE UPPER(SUBSTRING (SYS.Resource_Domain_OR_Workgr0,0,CHARINDEX('.',SYS.Resource_Domain_OR_Workgr0)))
	END	as Domain,	
MAX(IPSub.IP_Subnets0) as 'Subnet' ,MAX (BDY.DisplayName) as Location,
SYS.Operating_System_Name_and0 OSVersion, 

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
OPSYS.Caption0 as OSName, 
OPSYS.OperatingSystemSKU0 as OperatingSystemSKU,
CASE ISNULL(OPSYS.OperatingSystemSKU0, '0') 
WHEN 0 THEN 'Undefined'
WHEN 1 THEN 'Ultimate Edition'
WHEN 2 THEN 'Home Basic Edition'
WHEN 3 THEN 'Home Premium Edition'
WHEN 4 THEN 'Enterprise Edition'
WHEN 7 THEN 'Standard Server Edition'
WHEN 8 THEN 'Datacenter Server Edition'
WHEN 10 THEN 'Enterprise Server Edition'
WHEN 48 THEN 'Professional Edition'
ELSE 'Unknown'
END as OSSKU,
CPU.AddressWidth0 as Arch, OPSYS.InstallDate0 as InstallDate,  
MAX(HWSCAN.LastHWScan) as LastHWScan,
CSYS.Manufacturer0 as Manufacturer,
CSYS.Model0 as Model
 
FROM v_R_System  as SYS  
LEFT JOIN v_RA_System_SMSInstalledSites as ASSG on SYS.ResourceID=ASSG.ResourceID 
LEFT JOIN v_RA_System_IPSubnets IPSub on SYS.ResourceID = IPSub.ResourceID 
LEFT JOIN v_GS_X86_PC_MEMORY MEM on SYS.ResourceID = MEM.ResourceID 
LEFT JOIN v_GS_PROCESSOR CPU on SYS.ResourceID = CPU.ResourceID 
LEFT JOIN v_GS_COMPUTER_SYSTEM CSYS on SYS.ResourceID = CSYS.ResourceID 
LEFT JOIN v_GS_OPERATING_SYSTEM OPSYS on SYS.ResourceID=OPSYS.ResourceID 
LEFT JOIN v_GS_WORKSTATION_STATUS HWSCAN on SYS.ResourceID = HWSCAN.ResourceID 
LEFT JOIN v_GS_PC_BIOS BIOS on SYS.ResourceID = BIOS.ResourceID  
LEFT JOIN v_R_User USR on SYS.User_Name0 = USR.User_Name0
LEFT JOIN v_RA_System_SystemOUName SYSOU on SYS.ResourceID=SYSOU.ResourceID 
LEFT JOIN v_RA_User_UserOUName USROU on USR.ResourceID = USROU.ResourceID
LEFT JOIN v_FullCollectionMembership FCM on SYS.ResourceID = FCM.ResourceID 
LEFT JOIN v_GS_LOGICAL_DISK LDISK on LDISK.ResourceID = SYS.ResourceID 
LEFT JOIN v_RA_System_MACAddresses MAC on SYS.ResourceID = MAC.ResourceID
LEFT JOIN vSMS_Boundary BDY on IPSub.IP_Subnets0 = BDY.Value
LEFT JOIN v_GS_STAGO_OS_Deployment0 STA on SYS.ResourceID = STA.ResourceID

WHERE SYS.Obsolete0 = 0 AND (LDISK.DeviceID0 IS NULL or LDISK.DeviceID0 = 'C:') 
AND SYS.Client0 = '1' --AND SYS.Operating_System_Name_and0 like 'Microsoft Windows NT Workstation 6.1%' 
--and SYS.Name0 = 'DSIDT0024_NEW'
--and sys.Name0 like 'USS0%'
--AND FCM.CollectionID = 'SMS00004' 
 
GROUP BY SYS.Netbios_Name0, SYS.Obsolete0,SYS.Resource_Domain_OR_Workgr0,  SYS.Operating_System_Name_and0,
CSYS.Manufacturer0, CSYS.Model0, BIOS.SerialNumber0,OPSYS.InstallDate0,  OPSYS.OperatingSystemSKU0,
HWSCAN.LastHWScan, BIOS.SMBIOSBIOSVersion0 ,
SYS.User_Name0, 
SYS.User_Domain0, SYS.AD_Site_Name0, OPSYS.Caption0, CPU.Name0, CPU.AddressWidth0 
,LDISK.Description0 , LDISK.DeviceID0, LDISK.VolumeName0, LDISK.FileSystem0,LDISK.Size0, LDISK.FreeSpace0,(LDISK.Size0 - LDISK.FreeSpace0), SYS.AD_Site_Name0

ORDER BY 10, 2, 6, SYS.Netbios_Name0, OPSYS.InstallDate0 DESC