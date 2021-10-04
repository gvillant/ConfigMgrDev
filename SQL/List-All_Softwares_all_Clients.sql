SELECT DISTINCT 
SYS.Netbios_Name0 as Name,  arp.DisplayName0, arp.Publisher0, arp.Version0,
SYS.User_Name0 as Login, MAX(usr.givenName0) as GivenName, MAX(usr.sn0) as LastName, MAX(USROU.User_OU_Name0) as 'OU-Usr' ,
CSYS.Manufacturer0 as Manufacturer, CSYS.Model0 as Model, BIOS.SerialNumber0 as SN, 
CPU.Name0 as CPUName, MAX(CPU.MaxClockSpeed0) as CPU, MAX(MEM.TotalPhysicalMemory0) as RAM, BIOS.SMBIOSBIOSVersion0 as BiosVersion,
MAX(MAC.MAC_Addresses0) as MACAddress, MAX(IPSub.IP_Subnets0) as 'Subnet' ,MAX (BDY.DisplayName) as Location,
SYS.Operating_System_Name_and0 OSVersion, OPSYS.Caption0 as OSName, 
CPU.AddressWidth0 as Arch, OPSYS.InstallDate0 as InstallDate,  
MAX(HWSCAN.LastHWScan) as LastHWScan, 
MAX(SYSOU.System_OU_Name0) as 'OU-Cmp', 
SYS.Resource_Domain_OR_Workgr0 as Domain,
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
LEFT JOIN v_RA_System_MACAddresses MAC on SYS.ResourceID = MAC.ResourceID
LEFT JOIN vSMS_Boundary BDY on IPSub.IP_Subnets0 = BDY.Value
LEFT JOIN v_Add_Remove_Programs arp on SYS.ResourceID = arp.ResourceID

WHERE SYS.Obsolete0 = 0 
--and sys.Name0 = 'FRS02002' 
--AND FCM.CollectionID = 'SMS00004' 
and bdy.DisplayName = 'FR - Gennevilliers G4 (110)'
and 
 (arp.publisher0 not in (' Hewlett-Packard', '{&Tahoma8}Hewlett-Packard', 'HEWLET~1|Hewlett-Packard', 'Hewlett Packard', 'Hewlett Packard Development Company L.P.', 'Hewlett Packard Development Company, L.P.', 'Hewlett Packard Development Group, L.P.', 'Hewlett Packard Development Group, LLP', 'Hewlett-Packard', 'Hewlett-Packard Co.', 'Hewlett-Packard Company', 'Hewlett-Packard Development Company, L.P.', 'HP', 'HPQ', '1E', 'Conexant', 'Conexant Systems', 'NVIDIA Corporation', 'McAfee', 'McAfee, Inc.', 'Trend Micro', 'Trend Micro Inc.', 'Trend Micro Inc. (tm)', 'Trend Micro Incorporated', 'TrendMicro','Citrix Online, a division of Citrix Systems, Inc.', 'Citrix Systems', 'Citrix Systems, Inc.', 'Broadcom', 'Broadcom Corporation','Dell', 'Dell Inc', 'Dell Inc.', 'Roxio', 'Roxio Inc.,', 'Easlman Kodak Company', 'Eastman Kodak Company', 'Eastman Kodak', 'RealNetworks', 'RealNetworks, Inc', 'RealNetworks, Inc.', 'Veetle, Inc', 'IBM', 'IBM Corporation', 'Lexmark International, Inc.',  'Lenovo', 'Lenovo Group Limited', 'Lenovo Group Limited.', 'Linksys', 'Linksys By Cisco Systems',  'Logitech', 'Logitech Inc.', 'Logitech, Inc.', 'Name of your company', 'Your Company Name',  'Kyocera Mita Corporation', 'KyoceraMita', 'Nikon',  'Canon', 'Canon Inc', 'CANON INC.',  'LeapFrog',  'Comcast',  'Comcast Cable Communications Management LLC', 'SEIKO EPSON', 'SEIKO EPSON Corp.',  'SEIKO EPSON CORPORATION',  'ATI',  'ATI Technologies',  'ATI Technologies Inc.',  'ATI Technologies, Inc.', 'Texas Instruments Inc.',  'TomTom',  'amrtomp3converter.com', 'TomTom International B.V.',  'Nero AG', 'AT&T', 'AT&T Inc.', 'Nortel', 'Nortel Networks', 'NOS Microsystems Ltd.', 'InstallShield Software Corp.') or arp.publisher0 is null)
and arp.DisplayName0 not like '%Acrobat 7.1%'
and arp.DisplayName0 not like '%Acrobat 8.2%'
and arp.DisplayName0 not like '%add-in%'
and arp.DisplayName0 not like '%CPSID%'
and arp.DisplayName0 not like '%Driver%' 
and arp.DisplayName0 not like '%live meeting%'
and arp.DisplayName0 not like '%malware%'
and arp.DisplayName0 not like '%Modem%' 
and arp.DisplayName0 not like '%outlook connector%'
and arp.DisplayName0 not like '%plug-in%'
and arp.DisplayName0 not like '%Shockwave%'
and arp.DisplayName0 not like '%SQL Server Native Client%'
and arp.DisplayName0 not like '%SQL%Setup%'
and arp.DisplayName0 not like '%toolbar%'
and arp.DisplayName0 not like '%Uninstall%'
and arp.DisplayName0 not like '%Update for%'
and arp.DisplayName0 not like '%Visio Viewer%'
and arp.DisplayName0 not like '%Visual C++%' 
and arp.DisplayName0 not like '%Visual Studio%Runtime' 
and arp.DisplayName0 not like '.print%' 
and arp.DisplayName0 not like '2007 Microsoft%' 
and arp.DisplayName0 not like '911Service%'
and arp.DisplayName0 not like 'AccelerometerP11%'
and arp.DisplayName0 not like 'Acrobat.com%' 
and arp.DisplayName0 not like 'Ad-Aware%'
and arp.DisplayName0 not like 'Adobe %Client%'
and arp.DisplayName0 not like 'Adobe %Language%'
and arp.DisplayName0 not like 'Adobe %Library%'
and arp.DisplayName0 not like 'Adobe %Support%'
and arp.DisplayName0 not like 'Adobe Air%' 
and arp.DisplayName0 not like 'Adobe Reader%'
and arp.DisplayName0 not like 'Adobe Setup%'
and arp.DisplayName0 not like 'Adobe WAS%'
and arp.DisplayName0 not like 'Adobe XMP%'
and arp.DisplayName0 not like 'Adobe%Color%'
and arp.DisplayName0 not like 'Adobe%common%'
and arp.DisplayName0 not like 'Adobe%Exten%'
and arp.DisplayName0 not like 'Adobe%Help%'
and arp.DisplayName0 not like 'Adobe%library%'
and arp.DisplayName0 not like 'Adobe%Security%'
and arp.DisplayName0 not like 'Adobe%support%'
and arp.DisplayName0 not like 'Adobe%Update%'
and arp.DisplayName0 not like 'Amazon%'
and arp.DisplayName0 not like 'Apple App%'
and arp.DisplayName0 not like 'ATI%' 
and arp.DisplayName0 not like 'AuthenTec%' 
and arp.DisplayName0 not like 'AutoUpdate%' 
and arp.DisplayName0 not like 'Bing bar%'
and arp.DisplayName0 not like 'BlackBerry Device%'
and arp.DisplayName0 not like 'BlackBery%media%'
and arp.DisplayName0 not like 'bluetooth%'
and arp.DisplayName0 not like 'Bonjour%' 
and arp.DisplayName0 not like 'Broadcom%' 
and arp.DisplayName0 not like 'Calendar Printing Assist%'
and arp.DisplayName0 not like 'Canon%'
and arp.DisplayName0 not like 'Catalyst Control%' 
and arp.DisplayName0 not like 'CC%' 
and arp.DisplayName0 not like 'Citrix online%' 
and arp.DisplayName0 not like 'Citrix%Web%'
and arp.DisplayName0 not like 'Citrix%XenApp%'
and arp.DisplayName0 not like 'Compatibility Pack%'
and arp.DisplayName0 not like 'Configuration Manager%' 
and arp.DisplayName0 not like 'Connect'
and arp.DisplayName0 not like 'D3DX10%'
and arp.DisplayName0 not like 'Dell %'
and arp.DisplayName0 not like 'DirectX%'
and arp.DisplayName0 not like 'Epson %'
and arp.DisplayName0 not like 'Fingerprint sensor%' 
and arp.DisplayName0 not like 'Google%Update%'  
and arp.DisplayName0 not like 'HighMAT%' 
and arp.DisplayName0 not like 'Hotfix%'
and arp.DisplayName0 not like 'HP %'
and arp.DisplayName0 not like 'HP Quick%' 
and arp.DisplayName0 not like 'Intel%' 
and arp.DisplayName0 not like 'J2SE%' 
and arp.DisplayName0 not like 'Java%' 
and arp.DisplayName0 not like 'Macromedia Flash%' 
and arp.DisplayName0 not like 'Microsoft %APIs%' 
and arp.DisplayName0 not like 'Microsoft .NET%'
and arp.DisplayName0 not like 'Microsoft ACT%' 
and arp.DisplayName0 not like 'Microsoft Application%'
and arp.DisplayName0 not like 'Microsoft ASP.NET%'
and arp.DisplayName0 not like 'Microsoft Base Smart Card%' 
and arp.DisplayName0 not like 'Microsoft Choice%' 
and arp.DisplayName0 not like 'Microsoft Compression%' 
and arp.DisplayName0 not like 'Microsoft Default Manager%'
and arp.DisplayName0 not like 'Microsoft Easy Assist%' 
and arp.DisplayName0 not like 'Microsoft Exchange%' 
and arp.DisplayName0 not like 'Microsoft Intel%'
and arp.DisplayName0 not like 'Microsoft Office 20%' 
and arp.DisplayName0 not like 'Microsoft Office Access%' 
and arp.DisplayName0 not like 'Microsoft Office Professional%' 
--and arp.DisplayName0 not like 'Microsoft Office%2007' 
--and arp.DisplayName0 not like 'Microsoft Office%2010' 
and arp.DisplayName0 not like 'Microsoft Report Viewer Redistributable%'
and arp.DisplayName0 not like 'Microsoft Save as PDF%' 
and arp.DisplayName0 not like 'Microsoft search%'
and arp.DisplayName0 not like 'Microsoft Silverlight%' 
--and arp.DisplayName0 not like 'Microsoft Sync%' 
and arp.DisplayName0 not like 'Microsoft UI Engine%'
and arp.DisplayName0 not like 'Microsoft User-Mode Driver%' 
and arp.DisplayName0 not like 'Microsoft WSE%' 
and arp.DisplayName0 not like 'Microsoft XML%' 
and arp.DisplayName0 not like 'Microsoft_vc%'
and arp.DisplayName0 not like 'MRI%' 
and arp.DisplayName0 not like 'MSN Messenger%'
and arp.DisplayName0 not like 'MSVCRT%' 
and arp.DisplayName0 not like 'MSXML%'
and arp.DisplayName0 not like 'My Web%'
and arp.DisplayName0 not like 'MyDSC%'
and arp.DisplayName0 not like 'MyFonts%'
and arp.DisplayName0 not like 'MyHeritage%'
and arp.DisplayName0 not like 'MyPublisher%'
and arp.DisplayName0 not like 'RDC%' 
and arp.DisplayName0 not like 'SCR3xxx Smart Card Read%'
and arp.DisplayName0 not like 'ScriptLogic%' 
and arp.DisplayName0 not like 'Segoe%' 
and arp.DisplayName0 not like 'Sonic%' 
and arp.DisplayName0 not like 'SoundMax%' 
and arp.DisplayName0 not like 'Spelling dictionaries%'
and arp.DisplayName0 not like 'Stamps.com%'
and arp.DisplayName0 not like 'Suite Shared%'
and arp.DisplayName0 not like 'Synaptics%'
and arp.DisplayName0 not like 'Time%Zone%Update%' 
and arp.DisplayName0 not like 'tipci' 
and arp.DisplayName0 not like 'Topaz%'  
and arp.DisplayName0 not like 'Trend%' 
and arp.DisplayName0 not like 'WebEx%' 
and arp.DisplayName0 not like 'WIMGAPI%' 
and arp.DisplayName0 not like 'Windows%'
and arp.DisplayName0 not like 'WOL Magic Packet%'
and arp.DisplayName0 not like 'WPF Toolkit%'
and arp.DisplayName0 not like '7-Zip%'
and arp.DisplayName0 not like '%KB96%'
and arp.DisplayName0 not like 'Adobe Flash Player%'
and arp.DisplayName0 not like '%Intel(R) PROSet/Wireless%'
and arp.DisplayName0 not like 'Realtek%'
--and arp.DisplayName0 not like 'InfraRecorder%'
and arp.DisplayName0 not like 'Microsoft Office Language Pack 2007%'
--and arp.DisplayName0 not like 'PDFCreator%'
and arp.DisplayName0 not like '%Language Pack%'
and arp.DisplayName0 not like '%Service Pack%'
and arp.DisplayName0 not like 'Zip Previewer by MK Net.Work%'
--and arp.DisplayName0 not like 'SyncToy 2.1%'
and arp.DisplayName0 not like 'Microsoft redistributable%'
and arp.DisplayName0 not like '%MUI%'
and arp.DisplayName0 not like '%Proofing%'
and arp.DisplayName0 <> 'Microsoft Policy Platform'
and arp.DisplayName0 <> 'Microsoft Office 64-bit Components 2013'
and arp.DisplayName0 <> 'Outils de vérification linguistique 2013 de Microsoft Office - Français'
and arp.DisplayName0 <> 'Microsoft Office Korrekturhilfen 2013 - Deutsch'
and arp.DisplayName0 <> 'LAN-Fax Utilities'
and arp.DisplayName0 <> 'Mozilla Maintenance Service'
and arp.DisplayName0 not like '%(kb%'

 
GROUP BY SYS.Netbios_Name0, arp.DisplayName0, arp.Publisher0, arp.Version0, SYS.Obsolete0,SYS.Resource_Domain_OR_Workgr0,  SYS.Operating_System_Name_and0,
CSYS.Manufacturer0, CSYS.Model0, BIOS.SerialNumber0,OPSYS.InstallDate0,  
HWSCAN.LastHWScan, BIOS.SMBIOSBIOSVersion0 ,
SYS.User_Name0, 
SYS.User_Domain0, SYS.AD_Site_Name0, OPSYS.Caption0, CPU.Name0, CPU.AddressWidth0, SYS.AD_Site_Name0

ORDER BY  SYS.Netbios_Name0, OPSYS.InstallDate0 DESC

