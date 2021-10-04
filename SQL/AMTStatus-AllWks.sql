SELECT DISTINCT
SYS.Netbios_Name0, 
amtag.AMT0 as AMTVersion,
amtag.BiosVersion0 as BIOS,
amtag.ProvisionState0 as ProvState,
AMTSCSMgt.AMTControlMode0,
AMTSCSInfo.LMSVersion0,
AMTSCSInfo.MEIVersion0,
AMTSCSInfo.IsMEIEnabled0,
AMTSCSConf.SCSProfileName0,
AMTSCSConf.LastConfigurationTime0,
AMTSCSCert.NextCertExpiryDate0,

CSYS.Manufacturer0, CSYS.Model0, BIOS.SerialNumber0, OPSYS.InstallDate0, 
HWSCAN.LastHWScan, 
SYS.User_Name0, SYS.User_Domain0, 
ASSG.SMS_Installed_Sites0, 
SYS.Client_Version0,
MEM.TotalPhysicalMemory0, 
MAX(IPSub.IP_Subnets0) as 'Subnet',
SYS.Operating_System_Name_and0 as OSFull,
OPSYS.Caption0 as OS, 
MAX(SYSOU.System_OU_Name0) as 'OU'

FROM v_R_System  as SYS 
JOIN v_RA_System_SMSInstalledSites as ASSG on SYS.ResourceID=ASSG.ResourceID
LEFT JOIN v_RA_System_IPSubnets IPSub on SYS.ResourceID = IPSub.ResourceID
LEFT JOIN  v_GS_X86_PC_MEMORY MEM on SYS.ResourceID = MEM.ResourceID
LEFT JOIN  v_GS_COMPUTER_SYSTEM CSYS on SYS.ResourceID = CSYS.ResourceID
LEFT JOIN  v_GS_PROCESSOR Processor  on Processor.ResourceID = SYS.ResourceID
LEFT JOIN v_GS_OPERATING_SYSTEM OPSYS on SYS.ResourceID=OPSYS.ResourceID
LEFT JOIN v_GS_WORKSTATION_STATUS HWSCAN on SYS.ResourceID = HWSCAN.ResourceID
LEFT JOIN v_GS_LastSoftwareScan SWSCAN on SYS.ResourceID = SWSCAN.ResourceID
LEFT JOIN v_GS_PC_BIOS BIOS on SYS.ResourceID = BIOS.ResourceID 
LEFT JOIN v_RA_System_SystemOUName SYSOU on SYS.ResourceID=SYSOU.ResourceID 
LEFT JOIN v_GS_AMT_AGENT AMTAg on SYS.ResourceID=AMTAg.ResourceID 
LEFT JOIN v_GS_Intel_AMT_OSInfo0 AMTSCSInfo on SYS.ResourceID=AMTSCSInfo.ResourceID 
LEFT JOIN v_GS_Intel_AMT_ConfigurationInfo_Certificates0 AMTSCSCert on SYS.ResourceID=AMTSCSCert.ResourceID 
LEFT JOIN v_GS_Intel_AMT_ConfigurationInfo0 AMTSCSConf on SYS.ResourceID=AMTSCSConf.ResourceID 
LEFT JOIN v_GS_Intel_AMT_ManageabilityInfo_ManagementSettings0 AMTSCSMgt on SYS.ResourceID = AMTSCSMgt.ResourceID

WHERE SYS.Operating_System_Name_and0 LIKE '%Work%' AND SYS.Client0 = 1 AND SYS.Name0 like '620%' and Model0 = 'OptiPlex 9020'-- AND AMTControlMode0 IS NOT NULL

GROUP BY SYS.Netbios_Name0, SYS.Obsolete0,SYS.Resource_Domain_OR_Workgr0, 
CSYS.Manufacturer0, CSYS.Model0, BIOS.SerialNumber0,OPSYS.InstallDate0,
HWSCAN.LastHWScan, MEM.TotalPhysicalMemory0,
SYS.User_Name0, SYS.User_Domain0, SYS.Operating_System_Name_and0,
ASSG.SMS_Installed_Sites0, SYS.Client_Version0, OPSYS.Caption0,
AMTSCSMgt.AMTControlMode0,
amtag.AMT0 ,
amtag.BiosVersion0 ,
amtag.ProvisionState0,
AMTSCSInfo.LMSVersion0,
AMTSCSInfo.MEIVersion0,
AMTSCSInfo.IsMEIEnabled0,
AMTSCSConf.SCSProfileName0,
AMTSCSConf.LastConfigurationTime0,
AMTSCSCert.NextCertExpiryDate0


ORDER BY OPSYS.InstallDate0 DESC