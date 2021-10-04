/*
DECLARE @P_OStype varchar(20)
SET @P_OStype = 'Server';
*/

--/*
DECLARE @LastActivity DATETIME
SET @LastActivity = '2015-08-18';
--*/


SELECT DISTINCT 
SYS.Netbios_Name0 as Name,
COLLEC.CollectionName,
SYS.Obsolete0 as Obsolete,
CASE SYS.Obsolete0
	WHEN '0' THEN  'Managed'
	ELSE 'Not Managed'
	END as Client, 
TOPC.TopConsoleUser0 as TopConsoleUser,
SYS.Is_Assigned_To_User0 as isAssignedToUser,
MAX(usr.givenName0) as GivenName, MAX(usr.sn0) as LastName, MAX(USR.User_Name0) as Login , 
SYS.User_Name0 as LastLogin,MAX(USROU.User_OU_Name0) as 'OU-User' ,
CSYS.Manufacturer0 as Manufacturer, CSYS.Model0 as Model, BIOS.SerialNumber0 as Serial, 
STA.SMSTSPackageName0 as TSName,STA.SMSTSLaunchMode0 as TSLaunchMode, 
CASE STA.SMSTSMediaType0 
WHEN ' _SMSTSMediaType ' THEN 'SMS'
ELSE STA.SMSTSMediaType0
END as TSMedia, STA.Version0 as TSVersion,
CPU.Name0 as CPUName, MAX(CPU.MaxClockSpeed0) as CPU, MAX(MEM.TotalPhysicalMemory0) as RAM, BIOS.SMBIOSBIOSVersion0 as BiosVersion,
MAX(MAC.MAC_Addresses0) as MACAddress, MAX(IPSub.IP_Subnets0) as 'Subnet' ,MAX (BDY.DisplayName) as Location,
SYS.Operating_System_Name_and0 as OSVersion, 
CASE 
	WHEN SYS.Operating_System_Name_and0 like '%Workstation 5.0%' THEN 'Windows 2000'
	WHEN SYS.Operating_System_Name_and0 like '%Workstation 5.1%' THEN 'Windows XP'
	WHEN SYS.Operating_System_Name_and0 like '%Workstation 5.2%' THEN 'Windows XP'
	WHEN SYS.Operating_System_Name_and0 like '%Workstation 6.1%' THEN 'Windows 7'
	WHEN SYS.Operating_System_Name_and0 like '%Windows 7%6.1%' THEN 'Windows 7'
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
	WHEN SYS.Operating_System_Name_and0 like '%OnTap%' THEN 'OnTap'
	ELSE 'Unknown'
	END as OSVer,
CASE 
	WHEN SYS.Operating_System_Name_and0 like '%Workstation%' or SYS.Operating_System_Name_and0 like '%Windows%6.1%' or SYS.Operating_System_Name_and0 like '%OS X%' THEN 'Workstation'
	WHEN SYS.Operating_System_Name_and0 like '%Server%' or SYS.Operating_System_Name_and0 like '%OnTap%' THEN 'Server'
	ELSE 'Unknown'
	END as OSType,
OPSYS.Caption0 as OSCaption, 
CPU.AddressWidth0 as Arch, OPSYS.InstallDate0 as InstallDate,  
MAX(HWSCAN.LastHWScan) as LastHWScan, 
MAX(SYSOU.System_OU_Name0) as 'OU-Computer',
CASE WHEN (CHARINDEX('.',SYS.Resource_Domain_OR_Workgr0) = 0)  THEN UPPER(SYS.Resource_Domain_OR_Workgr0)
	ELSE UPPER(SUBSTRING (SYS.Resource_Domain_OR_Workgr0,0,CHARINDEX('.',SYS.Resource_Domain_OR_Workgr0)))
	END	as Domain,	

LDISK.Description0 as LogicalDisk , LDISK.DeviceID0 as DeviceID, LDISK.VolumeName0 as VolumeName, 
LDISK.FileSystem0 as FileSystem, LDISK.Size0 as Size, 
LDISK.FreeSpace0 as FreeSpace,(LDISK.Size0 - LDISK.FreeSpace0) as UsedSpace,

SYS.AD_Site_Name0 as ADSiteName,SYS.Last_Logon_Timestamp0 as LastLogonAD,
CASE 
	WHEN SYS.Last_Logon_Timestamp0 > @LastActivity THEN 'Active'
	ELSE 'Inactive'
	END AS 'ADActivity',
CLISUM.LastActiveTime as 'CMLastActiveTime',
CASE 
	WHEN CLISUM.ClientActiveStatus = 1 THEN 'Active'
	WHEN CLISUM.ClientActiveStatus = 0 THEN 'Inactive'
	END AS 'CMClientActiveStatus'
 
FROM v_R_System  as SYS  
LEFT JOIN v_RA_System_SMSInstalledSites as ASSG on SYS.ResourceID=ASSG.ResourceID 
LEFT JOIN v_RA_System_IPSubnets IPSub on SYS.ResourceID = IPSub.ResourceID 
LEFT JOIN v_GS_X86_PC_MEMORY MEM on SYS.ResourceID = MEM.ResourceID 
LEFT JOIN v_GS_PROCESSOR CPU on SYS.ResourceID = CPU.ResourceID 
LEFT JOIN v_GS_COMPUTER_SYSTEM CSYS on SYS.ResourceID = CSYS.ResourceID 
LEFT JOIN v_GS_OPERATING_SYSTEM OPSYS on SYS.ResourceID=OPSYS.ResourceID 
LEFT JOIN v_GS_WORKSTATION_STATUS HWSCAN on SYS.ResourceID = HWSCAN.ResourceID 
LEFT JOIN v_GS_PC_BIOS BIOS on SYS.ResourceID = BIOS.ResourceID  
LEFT JOIN v_GS_SYSTEM_CONSOLE_USAGE_MAXGROUP as TOPC on SYS.ResourceID = TOPC.ResourceID
LEFT JOIN v_R_User USR on TOPC.TopConsoleUser0 = USR.Unique_User_Name0
LEFT JOIN v_RA_System_SystemOUName SYSOU on SYS.ResourceID=SYSOU.ResourceID 
LEFT JOIN v_RA_User_UserOUName USROU on USR.ResourceID = USROU.ResourceID
LEFT JOIN v_FullCollectionMembership FCM on SYS.ResourceID = FCM.ResourceID
LEFT JOIN v_Collections COLLEC on COLLEC.SiteID = FCM.CollectionID 
LEFT JOIN v_GS_LOGICAL_DISK LDISK on LDISK.ResourceID = SYS.ResourceID 
LEFT JOIN v_RA_System_MACAddresses MAC on SYS.ResourceID = MAC.ResourceID
LEFT JOIN vSMS_Boundary BDY on IPSub.IP_Subnets0 = BDY.Value
LEFT JOIN v_GS_STAGO_OS_Deployment0 STA on SYS.ResourceID = STA.ResourceID
LEFT JOIN v_CH_ClientSummary CLISUM on SYS.ResourceID = CLISUM.ResourceID

WHERE (LDISK.DeviceID0 IS NULL or LDISK.DeviceID0 = 'C:')
and COLLEC.CollectionName LIKE 'IE11 - All%'
--and SYS.Last_Logon_Timestamp0 > @LastActivity
--and SYS.Operating_System_Name_and0 like ('%' + @OSType + '%')
--and SYS.Obsolete0 = 1 
--and operatingSystemVersion0 like '%6.1%' 
--and Domain0 like '%CN%'
--and CPU.AddressWidth0 = 32
--AND FCM.CollectionID = 'SMS00004' 
--and SYS.Name0 = 'AES03597'
 
GROUP BY SYS.Netbios_Name0, SYS.Obsolete0,SYS.Resource_Domain_OR_Workgr0,  SYS.Operating_System_Name_and0,
CSYS.Manufacturer0, CSYS.Model0, BIOS.SerialNumber0,
STA.SMSTSPackageName0,STA.SMSTSLaunchMode0, STA.SMSTSMediaType0, STA.Version0 ,
OPSYS.InstallDate0,  
HWSCAN.LastHWScan, BIOS.SMBIOSBIOSVersion0 ,
TOPC.TopConsoleUser0,SYS.Is_Assigned_To_User0,
SYS.User_Name0, 
SYS.User_Domain0, SYS.AD_Site_Name0, OPSYS.Caption0, CPU.Name0, CPU.AddressWidth0 
,LDISK.Description0 , LDISK.DeviceID0, LDISK.VolumeName0, LDISK.FileSystem0,LDISK.Size0, LDISK.FreeSpace0,(LDISK.Size0 - LDISK.FreeSpace0), 
SYS.AD_Site_Name0,SYS.Last_Logon_Timestamp0, CLISUM.LastActiveTime,CLISUM.ClientActiveStatus,COLLEC.CollectionName

ORDER BY  OSVER, OSVersion, SYS.Netbios_Name0, OPSYS.InstallDate0 DESC