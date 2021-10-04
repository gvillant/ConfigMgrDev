SELECT Distinct IP_Subnets0, bdinfo.DisplayName,
Count(SYS.ResourceID) AS 'Count' 

FROM v_R_System SYS
LEFT JOIN v_RA_System_IPSubnets IPSUB on SYS.ResourceID = IPSUB.ResourceID
LEFT JOIN vSMS_Boundary BDINFO on IPSUB.IP_Subnets0 = BDINFO.Value

WHERE SYS.Obsolete0 = 0 
Group By IPSUB.IP_Subnets0,BDINFO.DisplayName
Order By IPSUB.IP_Subnets0

--------------------------------------------------------------------
SELECT Distinct IP_Subnets0, bdinfo.DisplayName,
Count(SYS.ResourceID) AS 'Count' 

FROM v_R_System SYS
LEFT JOIN v_RA_System_IPSubnets IPSUB on SYS.ResourceID = IPSUB.ResourceID
LEFT JOIN vSMS_Boundary BDINFO on IPSUB.IP_Subnets0 = BDINFO.Value

WHERE SYS.Obsolete0 = 0 and (BDINFO.DisplayName not like 'FFF.%' and BDINFO.DisplayName is not NULL)
Group By IPSUB.IP_Subnets0,BDINFO.DisplayName
Order By IPSUB.IP_Subnets0

--------------------------------------------------------------------
SELECT Distinct IP_Subnets0, bdinfo.DisplayName,
Count(SYS.ResourceID) AS 'Count' 

FROM v_R_System SYS
LEFT JOIN v_RA_System_IPSubnets IPSUB on SYS.ResourceID = IPSUB.ResourceID
LEFT JOIN vSMS_Boundary BDINFO on IPSUB.IP_Subnets0 = BDINFO.Value

WHERE SYS.Obsolete0 = 0 and BDINFO.DisplayName IS NULL
Group By IPSUB.IP_Subnets0,BDINFO.DisplayName
Order By IPSUB.IP_Subnets0
