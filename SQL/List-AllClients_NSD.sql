--DECLARE @P_OStype varchar(20)
--SET @P_OStype = 'Server';
DECLARE @LastActivity DATE
SET @LastActivity = '01/01/2015'


SELECT DISTINCT 
SYS.Name0 as Name,
SYS.Obsolete0,

---------------------- Start Specific values for NSD Import----------------------
'' + 'MATERIEL' 
+ '' Class, 
''+ (case(substring(SYS.name0,5,1)) when 'C' then 'CLIENT' 
	when 'S' then 'SERVEUR' else '' end)
	+''Category,
''+ (case(substring(SYS.name0,5,2)) when 'CP' then 'PORTABLE' 
	when 'CF' then 'FIXE' else '' end)
	+''Type,
''+ (case(substring(SYS.name0,5,3)) when 'CPB' then 'BUREAUTIQUE' 
when 'CPS' then 'SPECIFIQUE' when 'CFS' then 'SPECIFIQUE' when 'CFB' then 'BUREAUTIQUE' else '' end)
+''Typology,
CSYS.SystemType0 as SystemType,

'' + IsNull(rtrim(AMTag.AMT0),'') 
+ '' Chpar4,
'' + IsNull(rtrim(BIOS.SMBIOSBIOSVersion0),'') 
+ '' Chpar5,
'' + Isnull(rtrim(CASE CONVERT(VARCHAR, SYS.AMTStatus0) WHEN 0 THEN 'Inconnu' WHEN 1 THEN 'Detected' WHEN 2 THEN 'Non Provisionné' WHEN 3 THEN 'Provisionné' ELSE 'Incompatible' END),'')
+ '' Chpar6,
'' +  case SYS.Client0 when 0 then 'Hors connexion' else 'En ligne' end
+ '' Chpar7,
SYS.Active0 as ClientActive,
'' + Isnull(rtrim(CASE CONVERT(VARCHAR, SYS.Active0) WHEN 0 THEN 'Inactive' WHEN 1 THEN 'Active' ELSE '' END),'')
+ '' ClientActiveState,
---------------------- End Specific values for NSD Import----------------------

CASE SYS.Obsolete0
	WHEN '0' THEN  'Managed'
	ELSE 'Not Managed'
	END as Client, 
SYS.User_Name0 as Login, MAX(usr.givenName0) as GivenName, MAX(usr.sn0) as LastName, MAX(USROU.User_OU_Name0) as 'OU-Usr' ,
CSYS.Manufacturer0 as Manufacturer, CSYS.Model0 as Model, BIOS.SerialNumber0 as SN, 
MAX(CPU.Name0) as CPUName, MAX(CPU.NormSpeed0) as CPUClock, 
--'' + Isnull(rtrim(CASE CONVERT(VARCHAR, COUNT(DISTINCT CPU.DeviceID0)) WHEN 0 THEN '' ELSE COUNT(DISTINCT CPU.DeviceID0) END),'') as CPUCount,  
MAX(MEM.TotalPhysicalMemory0) as RAM, BIOS.SMBIOSBIOSVersion0 as BiosVersion,
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
MAX(CPU.AddressWidth0) as Arch, 
OPSYS.InstallDate0 as InstallDate,  
CONVERT(VARCHAR(10), BIOS.ReleaseDate0, 120) AS MotherboardDate, 
MAX(HWSCAN.LastHWScan) as LastHWScan, 
MAX(SYSOU.System_OU_Name0) as 'OU-Cmp', 
SYS.Resource_Domain_OR_Workgr0 as Domain,
/*
LDISK.Description0 as LogicalDisk , LDISK.DeviceID0 as DeviceID, LDISK.VolumeName0 as VolumeName, 
LDISK.FileSystem0 as FileSystem, LDISK.Size0 as Size, 
LDISK.FreeSpace0 as FreeSpace,(LDISK.Size0 - LDISK.FreeSpace0) as UsedSpace,
*/
SYS.AD_Site_Name0 as ADSiteName,SYS.Last_Logon_Timestamp0 as LastLogonAD,
CASE 
	WHEN SYS.Last_Logon_Timestamp0 > @LastActivity THEN 'Active'
	ELSE 'Inactive'
	END AS 'Activity',
SYS.Virtual_Machine_Host_Name0 as VM_HostServer,
vFFF.PublicProfileFirewall0 as [FWPublicProfile], 
vFFF.StandardProfileFirewall0 as [FWStandardProfile], 
vFFF.DomainProfileFirewall0 as [FWDomainProfile]
 
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
LEFT JOIN v_GS_AMT_AGENT AMTAg on SYS.ResourceID=AMTAg.ResourceID 
LEFT JOIN dbo.v_GS_FFF0 vFFF on SYS.ResourceID = vFFF.ResourceID

--WHERE --(LDISK.DeviceID0 IS NULL or LDISK.DeviceID0 = 'C:' or LDISK.VolumeName0 = '/' )

-- and SYS.Operating_System_Name_and0 like ('%' + @OSType + '%')
--and SYS.Obsolete0 = 1 
--and operatingSystemVersion0 like '%6.1%' 
--and CPU.AddressWidth0 = 32
--AND FCM.CollectionID = 'FFF0006C' -- Collection FFF-MADMR-Serveurs Télécity
--FCM.CollectionID = 'FFF0006E' -- Collection FFF-MADMR-All Site Servers
--AND FCM.CollectionID = 'SMS00004' 
--AND FCM.CollectionID = 'SMS00004' 
--AND FCM.CollectionID = 'SMS00004' 
  
GROUP BY SYS.Name0, SYS.Obsolete0,SYS.Resource_Domain_OR_Workgr0,  SYS.Operating_System_Name_and0,
CSYS.Manufacturer0, CSYS.Model0, BIOS.SerialNumber0,
OPSYS.InstallDate0,  
HWSCAN.LastHWScan, BIOS.SMBIOSBIOSVersion0 ,
SYS.User_Name0, 
SYS.User_Domain0, SYS.AD_Site_Name0, OPSYS.Caption0, CSYS.SystemType0 
,LDISK.Description0 , LDISK.DeviceID0, LDISK.VolumeName0, LDISK.FileSystem0,LDISK.Size0, LDISK.FreeSpace0,(LDISK.Size0 - LDISK.FreeSpace0), SYS.AD_Site_Name0,SYS.Last_Logon_Timestamp0, SYS.Virtual_Machine_Host_Name0,
AMTag.AMT0, BIOS.SMBIOSBIOSVersion0, AMTag.ProvisionState0,SYS.AMTStatus0,SYS.Client0,SYS.Active0,BIOS.ReleaseDate0,vFFF.PublicProfileFirewall0, vFFF.StandardProfileFirewall0, vFFF.DomainProfileFirewall0

ORDER BY  OSVER, SYS.Name0, OPSYS.InstallDate0 DESC

