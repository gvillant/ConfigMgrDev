--DECLARE @P_OStype varchar(20)
--SET @P_OStype = 'Server';
DECLARE @LastActivity DATE
SET @LastActivity = '01/01/2015'


SELECT DISTINCT 
SYS.Netbios_Name0 as Name,
SYS.Obsolete0,
CASE SYS.Obsolete0
	WHEN '0' THEN  'Managed'
	ELSE 'Not Managed'
	END as Client, 
SYS.User_Name0 as Login, MAX(usr.givenName0) as GivenName, MAX(usr.sn0) as LastName, MAX(USROU.User_OU_Name0) as 'OU-Usr' ,
CSYS.Manufacturer0 as Manufacturer, CSYS.Model0 as Model, BIOS.SerialNumber0 as SN, 
CPU.Name0 as CPUName, MAX(CPU.MaxClockSpeed0) as CPU, MAX(MEM.TotalPhysicalMemory0) as RAM, BIOS.SMBIOSBIOSVersion0 as BiosVersion,
MAX(MAC.MAC_Addresses0) as MACAddress, MAX(IPSub.IP_Subnets0) as 'Subnet' ,MAX (BDY.DisplayName) as Location,
SYS.Operating_System_Name_and0 OSVersion, 
CASE 
	WHEN SYS.Operating_System_Name_and0 like '%Workstation 5.0%' THEN 'Windows 2000'
	WHEN SYS.Operating_System_Name_and0 like '%Workstation 5.1%' THEN 'Windows XP'
	WHEN SYS.Operating_System_Name_and0 like '%Workstation 5.2%' THEN 'Windows XP'
	WHEN SYS.Operating_System_Name_and0 like '%Workstation 6.0%' THEN 'Windows Vista'
	WHEN SYS.Operating_System_Name_and0 like '%Workstation 6.1%' THEN 'Windows 7'
	WHEN SYS.Operating_System_Name_and0 like '%Workstation 6.2%' THEN 'Windows 8'
	WHEN SYS.Operating_System_Name_and0 like '%Workstation 6.3%' THEN 'Windows 8.1'
	WHEN SYS.Operating_System_Name_and0 like '%OS X%' THEN 'Mac OS X'
	WHEN SYS.Operating_System_Name_and0 like '%Server 5.0%' THEN 'Server 2000'
	WHEN SYS.Operating_System_Name_and0 like '%Server 5.2%' THEN 'Server 2003'
	WHEN SYS.Operating_System_Name_and0 like '%Server 6.0%' THEN 'Server 2008'
	WHEN SYS.Operating_System_Name_and0 like '%Server 6.1%' THEN 'Server 2008 R2'
	WHEN SYS.Operating_System_Name_and0 like '%Server 6.2%' THEN 'Server 2012'
	WHEN SYS.Operating_System_Name_and0 like '%Server 6.3%' THEN 'Server 2012 R2'
	WHEN SYS.Operating_System_Name_and0 like '%RHEL 5%' THEN 'RHEL 5'
	WHEN SYS.Operating_System_Name_and0 like '%RHEL 6%' THEN 'RHEL 6'
	ELSE 'Unknown'
	END as [OSVer],
CASE 
	WHEN (SYS.Operating_System_Name_and0 like '%Workstation%') or (SYS.Operating_System_Name_and0 like '%OS X%') THEN 'Workstation'
	WHEN (SYS.Operating_System_Name_and0 like '%Server%') or (SYS.Operating_System_Name_and0 like '%RHEL%') THEN 'Server'
	ELSE 'Unknown'
	END as [OSType],
OPSYS.Caption0 as OSName, 
CPU.AddressWidth0 as Arch, OPSYS.InstallDate0 as InstallDate,  
MAX(HWSCAN.LastHWScan) as LastHWScan, 
MAX(SYSOU.System_OU_Name0) as 'OU-Cmp', 
SYS.Resource_Domain_OR_Workgr0 as Domain,

--LDISK.Description0 as LogicalDisk , LDISK.DeviceID0 as DeviceID, LDISK.VolumeName0 as VolumeName, LDISK.FileSystem0 as FileSystem, 

-- Sum Logical disk space, limited by the where clause to Fixed Disk . 
SUM(cast(isnull(LDISK.Size0,'0') as BIGINT)) as Size, SUM(cast(isnull(LDISK.FreeSpace0,'0') as BIGINT)) as FreeSpace, 
SUM(cast(isnull(LDISK.Size0,'0') as BIGINT))- SUM(cast(isnull(LDISK.FreeSpace0,'0') as BIGINT)) as UsedSpace,

SYS.AD_Site_Name0 as ADSiteName,SYS.Last_Logon_Timestamp0 as LastLogonAD,
CASE 
	WHEN SYS.Last_Logon_Timestamp0 > @LastActivity THEN 'Active'
	ELSE 'Inactive'
	END AS 'Activity',
SYS.Virtual_Machine_Host_Name0 as VM_HostServer
 
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

WHERE 
(LDISK.DriveType0 = 0 or LDISK.DriveType0 = 3 or LDISK.DriveType0 is null) and ((SYS.Operating_System_Name_and0 like '%Server%') or (SYS.Operating_System_Name_and0 like '%RHEL%'))

/* LOGICALDisk DriveType :
	- 0 > Fixed Unix 
	- 2 > Removable
	- 3 > Fixed Windows 
	- 5 CD-ROM
*/

--and sys.Name0 like 'FFF-C2K-fr%'

--(LDISK.DeviceID0 IS NULL or LDISK.DeviceID0 = 'C:')

--and SYS.Operating_System_Name_and0 like ('%' + @OSType + '%')
--and SYS.Obsolete0 = 1 
--and operatingSystemVersion0 like '%6.1%' 
--and Domain0 like '%CN%'
--and CPU.AddressWidth0 = 32
--AND FCM.CollectionID = 'SMS00004' 
 
GROUP BY SYS.Netbios_Name0, SYS.Obsolete0,SYS.Resource_Domain_OR_Workgr0,  SYS.Operating_System_Name_and0,
CSYS.Manufacturer0, CSYS.Model0, BIOS.SerialNumber0,
OPSYS.InstallDate0,  
HWSCAN.LastHWScan, BIOS.SMBIOSBIOSVersion0 ,
SYS.User_Name0, 
SYS.User_Domain0, SYS.AD_Site_Name0, OPSYS.Caption0, CPU.Name0, CPU.AddressWidth0, 
--LDISK.Description0 , LDISK.DeviceID0, LDISK.VolumeName0, LDISK.FileSystem0,
--LDISK.Size0, LDISK.FreeSpace0,(LDISK.Size0 - LDISK.FreeSpace0), 
SYS.AD_Site_Name0,SYS.Last_Logon_Timestamp0, SYS.Virtual_Machine_Host_Name0

ORDER BY  OSVER, SYS.Netbios_Name0, OPSYS.InstallDate0 DESC