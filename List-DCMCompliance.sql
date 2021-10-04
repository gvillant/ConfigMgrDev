
--/*
declare @CIName as varchar(250)
Set @CIName = 'Software: DPM Protection Agent is fully operational' -- 
Set @CIName = 'Security: CheckLocalAdministrators'
--*/

--select @AuthListLocalID=CI_ID from v_AuthListInfo where CI_UniqueID=@AuthListID



SELECT CMP.Netbios_Name0 as NetbiosName
	  ,CIPROP.DisplayName as CIName
	  ,CIPROP.Description as CIDescription
	  ,CIS.SettingName as SettingName
	  ,CIS.CI_ID
	  ,CMP.CIVersion
	  ,CMP.CurrentValue
      ,CMP.LastComplianceMessageTime
      ,MAX(IPSub.IP_Subnets0) as 'Subnet' 
      ,MAX (BDY.DisplayName) as Location
	  ,SYS.Operating_System_Name_and0 as OSVersion
	  ,OPSYS.InstallDate0 as OSInstallDate
	  ,SYS.User_Name0 as Login, MAX(usr.givenName0) as GivenName, MAX(usr.sn0) as LastName
	  
  FROM v_CICurrentSettingsComplianceStatusDetail CMP
LEFT JOIN v_R_System as SYS on SYS.ResourceID = CMP.ResourceID
LEFT JOIN v_RA_System_IPSubnets IPSub on SYS.ResourceID = IPSub.ResourceID 
LEFT JOIN v_GS_COMPUTER_SYSTEM CSYS on SYS.ResourceID = CSYS.ResourceID 
LEFT JOIN v_GS_OPERATING_SYSTEM OPSYS on SYS.ResourceID=OPSYS.ResourceID 
LEFT JOIN v_R_User USR on SYS.User_Name0 = USR.User_Name0
LEFT JOIN v_FullCollectionMembership FCM on SYS.ResourceID = FCM.ResourceID 
LEFT JOIN vSMS_Boundary BDY on IPSub.IP_Subnets0 = BDY.Value
LEFT JOIN v_CISettings CIS on CMP.CI_ID = CIS.CI_ID
LEFT JOIN v_LocalizedCIProperties_SiteLoc CIPROP on CMP.CI_ID = CIPROP.CI_ID
  
  WHERE 
  --Setting_CI_ID = '16777619'
  --Setting_CI_ID = '16816952' 
  CIPROP.DisplayName = @CIName
  
  GROUP BY CMP.Netbios_Name0
      ,CIS.CI_ID
	  ,CIPROP.DisplayName
	  ,CIPROP.Description
      ,CIS.SettingName
	  ,CMP.CIVersion
	  ,CMP.CurrentValue
      ,CMP.LastComplianceMessageTime
      ,SYS.Operating_System_Name_and0 
	  ,OPSYS.InstallDate0 
	  ,SYS.User_Name0 
  
  ORDER BY CMP.Netbios_Name0
  
  