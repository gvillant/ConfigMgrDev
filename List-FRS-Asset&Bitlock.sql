SELECT  SYS.Netbios_Name0 as Name, ENC.SMBIOSAssetTag0,  
SYS.User_Name0 as Login, MAX(usr.givenName0) as GivenName, MAX(usr.sn0) as LastName, MAX(USROU.User_OU_Name0) as 'OU-Usr' ,
CSYS.Manufacturer0 as Manufacturer, CSYS.Model0 as Model, BIOS.SerialNumber0 as SN, 
CPU.Name0 as CPUName, MAX(CPU.MaxClockSpeed0) as CPU, MAX(MEM.TotalPhysicalMemory0) as RAM, 
MAX(MAC.MAC_Addresses0) as MACAddress, MAX(IPSub.IP_Subnets0) as 'Subnet',  
SYS.Operating_System_Name_and0 OSVersion, OPSYS.Caption0 as OSName, 
CPU.AddressWidth0 as Arch, (OPSYS.InstallDate0) as InstallDate,  
MAX(HWSCAN.LastHWScan) as LastHWScan, 
MAX(SYSOU.System_OU_Name0) as 'OU-Cmp', 
SYS.Resource_Domain_OR_Workgr0 as Domain 
,LDISK.Description0 as LogicalDisk , LDISK.DeviceID0 as DeviceID, LDISK.VolumeName0 as VolumeName, 
LDISK.FileSystem0 as FileSystem, LDISK.Size0 as Size, 
LDISK.FreeSpace0 as FreeSpace,(LDISK.Size0 - LDISK.FreeSpace0) as UsedSpace, BITLOCK.ProtectionStatus0 as isBitlocked, 
SYS.AD_Site_Name0 as ADSiteName
 
FROM v_R_System  as SYS  
LEFT JOIN v_RA_System_SMSInstalledSites as ASSG on SYS.ResourceID=ASSG.ResourceID 
LEFT JOIN v_RA_System_IPSubnets IPSub on SYS.ResourceID = IPSub.ResourceID 
LEFT JOIN  v_GS_X86_PC_MEMORY MEM on SYS.ResourceID = MEM.ResourceID 
LEFT JOIN  v_GS_PROCESSOR CPU on SYS.ResourceID = CPU.ResourceID 
LEFT JOIN  v_GS_COMPUTER_SYSTEM CSYS on SYS.ResourceID = CSYS.ResourceID 
LEFT JOIN v_GS_OPERATING_SYSTEM OPSYS on SYS.ResourceID=OPSYS.ResourceID 
LEFT JOIN v_GS_WORKSTATION_STATUS HWSCAN on SYS.ResourceID = HWSCAN.ResourceID 
LEFT JOIN v_GS_PC_BIOS BIOS on SYS.ResourceID = BIOS.ResourceID  
LEFT JOIN v_R_User USR on SYS.User_Name0 = USR.User_Name0
LEFT JOIN v_RA_System_SystemOUName SYSOU on SYS.ResourceID=SYSOU.ResourceID 
LEFT JOIN v_RA_User_UserOUName USROU on USR.ResourceID = USROU.ResourceID
LEFT JOIN v_FullCollectionMembership FCM on SYS.ResourceID = FCM.ResourceID 
LEFT JOIN v_GS_LOGICAL_DISK LDISK on LDISK.ResourceID = SYS.ResourceID 
LEFT JOIN v_RA_System_MACAddresses MAC on SYS.ResourceID = MAC.ResourceID
LEFT JOIN v_GS_SYSTEM_ENCLOSURE ENC on SYS.ResourceID = ENC.ResourceID
LEFT JOIN v_GS_ENCRYPTABLE_VOLUME BITLOCK on SYS.ResourceID = BITLOCK.ResourceID

WHERE SYS.Obsolete0 = 0 AND (LDISK.DeviceID0 IS NULL or LDISK.DeviceID0 = 'C:')
AND SYS.Operating_System_Name_and0 = 'Microsoft Windows NT Workstation 6.1' AND SYS.Netbios_Name0 LIKE 'FRS%'
--AND FCM.CollectionID = 'SMS00004' 
 
GROUP BY SYS.Netbios_Name0, ENC.SMBIOSAssetTag0, SYS.Obsolete0,SYS.Resource_Domain_OR_Workgr0,  SYS.Operating_System_Name_and0,
CSYS.Manufacturer0, CSYS.Model0, BIOS.SerialNumber0,OPSYS.InstallDate0,  
HWSCAN.LastHWScan, 
SYS.User_Name0, 
SYS.User_Domain0, SYS.AD_Site_Name0, OPSYS.Caption0, CPU.Name0, CPU.AddressWidth0 
,LDISK.Description0 , LDISK.DeviceID0, LDISK.VolumeName0, LDISK.FileSystem0,LDISK.Size0, LDISK.FreeSpace0,(LDISK.Size0 - LDISK.FreeSpace0), BITLOCK.ProtectionStatus0,
SYS.AD_Site_Name0

ORDER BY SYS.Netbios_Name0
