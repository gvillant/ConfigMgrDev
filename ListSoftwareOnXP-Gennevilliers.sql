Select DISTINCT SYS.Netbios_Name0,
SYS.Operating_System_Name_and0,
BDY.DisplayName,
Soft.ARPDisplayName0,
Soft.ProductName0, 
Soft.ProductVersion0, 
Soft.Publisher0 

FROM v_GS_INSTALLED_SOFTWARE Soft

JOIN v_R_System SYS ON Soft.ResourceID=SYS.ResourceID
JOIN v_FullCollectionMembership fcm on sys.ResourceID=fcm.ResourceID
LEFT JOIN v_RA_System_IPSubnets IPSub on SYS.ResourceID = IPSub.ResourceID 
LEFT JOIN vSMS_Boundary BDY on IPSub.IP_Subnets0 = BDY.Value

WHERE fcm.CollectionID = 'STG00224'
AND SYS.Obsolete0 = 0
AND BDY.DisplayName IN (
'FR - Gennevilliers G1 - G2',
'FR - Gennevilliers G3 (102)',
'FR - Gennevilliers G3 Imprimantes',
'FR - Gennevilliers G4',
'FR - Gennevilliers G4 (110)',
'FR - Gennevilliers G4 (111)',
'FR - Gennevilliers G4 Proxy',
'FR - Gennevilliers G4 Serveurs',
'FR - Gennevilliers G4 VMs',
'FR - Gennevilliers G5'
)

ORDER By SYS.Netbios_Name0, Soft.ARPDisplayName0

