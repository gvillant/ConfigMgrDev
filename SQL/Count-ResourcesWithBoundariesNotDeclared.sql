SELECT COUNT(distinct SYS.Netbios_Name0) as Count, IPSub.IP_Subnets0, MAX(IPSub.IP_Subnets0) as 'Subnet' ,MAX (BDY.DisplayName) as Location

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
LEFT JOIN v_RA_System_MACAddresses MAC on SYS.ResourceID = MAC.ResourceID
LEFT JOIN vSMS_Boundary BDY on IPSub.IP_Subnets0 = BDY.Value

--WHERE SYS.Obsolete0 = 0 
--AND FCM.CollectionID = 'SMS00004' 
WHERE BDY.DisplayName is NULL
 
/*GROUP BY SYS.Netbios_Name0,  SYS.ResourceID,SYS.Client_Type0, SYS.ResourceID, SYS.Obsolete0,SYS.Resource_Domain_OR_Workgr0,  SYS.Operating_System_Name_and0,
CSYS.Manufacturer0, CSYS.Model0, BIOS.SerialNumber0,OPSYS.InstallDate0,  
HWSCAN.LastHWScan, BIOS.SMBIOSBIOSVersion0 ,
SYS.User_Name0, 
SYS.User_Domain0, SYS.AD_Site_Name0, OPSYS.Caption0, CPU.Name0, CPU.AddressWidth0 , SYS.AD_Site_Name0,
SYS.Is_Virtual_Machine0
*/

group by IPSub.IP_Subnets0

having COUNT(distinct SYS.Netbios_Name0) > 1
ORDER BY Subnet