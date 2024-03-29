
SELECT CMP.Netbios_Name0
	  ,CMP.CurrentValue
      ,CMP.LastComplianceMessageTime
      ,MAX(IPSub.IP_Subnets0) as 'Subnet' 
      ,MAX (BDY.DisplayName) as Location
	  ,SYS.Operating_System_Name_and0 OSVersion
	  ,OPSYS.InstallDate0 as InstallDate
	  ,SYS.User_Name0 as Login, MAX(usr.givenName0) as GivenName, MAX(usr.sn0) as LastName
	  
  FROM v_CICurrentSettingsComplianceStatusDetail CMP
LEFT JOIN v_R_System as SYS on SYS.ResourceID = CMP.ResourceID
LEFT JOIN v_RA_System_IPSubnets IPSub on SYS.ResourceID = IPSub.ResourceID 
LEFT JOIN  v_GS_COMPUTER_SYSTEM CSYS on SYS.ResourceID = CSYS.ResourceID 
LEFT JOIN v_GS_OPERATING_SYSTEM OPSYS on SYS.ResourceID=OPSYS.ResourceID 
LEFT JOIN v_R_User USR on SYS.User_Name0 = USR.User_Name0
LEFT JOIN v_FullCollectionMembership FCM on SYS.ResourceID = FCM.ResourceID 
LEFT JOIN vSMS_Boundary BDY on IPSub.IP_Subnets0 = BDY.Value
  
  WHERE Setting_CI_ID = '16809615'  --Netbios_Name0 = 'FRS01498' 
  
  GROUP BY CMP.Netbios_Name0
	  ,CMP.CurrentValue
      ,CMP.LastComplianceMessageTime
      ,SYS.Operating_System_Name_and0 
	  ,OPSYS.InstallDate0 
	  ,SYS.User_Name0 
  
  ORDER BY LastComplianceMessageTime DESC, OPSYS.InstallDate0, CMP.Netbios_Name0
  