
--/*
declare @CIName as varchar(250)
Set @CIName = 'Software: DPM Protection Agent is fully operational' -- 
--Set @CIName = 'Security: CheckLocalAdministrators'
--*/



SELECT CMPSTAT.CI_ID
	,SYS.Name0 as Name,
	CASE CMPSTAT.IsDetected
		WHEN '0' THEN 'Not-Detected'
		ELSE STATID.StateName
		END as StateName,
    CASE CMPSTAT.ComplianceState 
		WHEN '1' THEN NULL
		ELSE MAX(CMP.CurrentValue)
		END as LastErrorMessage,
    CASE CMPSTAT.ComplianceState 
		WHEN '1' THEN NULL
		ELSE MAX(CMP.LastComplianceMessageTime)
		END as LastErrorMessageTime
	--	,MIN(CMP.LastComplianceMessageTime)
	  ,CIPROP.DisplayName as CIName
	  ,CIPROP.Description as CIDescription
	  ,CIS.SettingName as SettingName
      ,CMPSTAT.CIVersion
      ,CMPSTAT.IsDetected
      ,CMPSTAT.ComplianceValidationRuleFailures
      ,CMPSTAT.ErrorCount
      ,CMPSTAT.ConflictCount
      ,CMPSTAT.LastComplianceMessageTime
      ,MAX(IPSub.IP_Subnets0) as 'Subnet' 
      ,MAX(BDY.DisplayName) as Location
      ,SYS.User_Name0 as Login, MAX(usr.givenName0) as GivenName, MAX(usr.sn0) as LastName
  
  FROM v_CICurrentComplianceStatus CMPSTAT
	OUTER APPLY (select ST.StateName from v_StateNames ST where (ST.TopicType = 401 AND ST.StateID = CMPSTAT.ComplianceState)) STATID
	OUTER APPLY (select CMPSDET.CurrentValue, CMPSDET.LastComplianceMessageTime from v_CICurrentSettingsComplianceStatusDetail CMPSDET where (CMPSDET.CI_ID = CMPSTAT.CI_ID and CMPSTAT.ResourceID = CMPSDET.ResourceID)) CMP
	LEFT JOIN v_R_System SYS on CMPSTAT.ResourceID = SYS.ResourceID
	--LEFT JOIN v_CICurrentSettingsComplianceStatusDetail CMP on CMPSTAT.CI_ID = CMP.CurrentValue
	LEFT JOIN v_RA_System_IPSubnets IPSub on SYS.ResourceID = IPSub.ResourceID 
	LEFT JOIN v_GS_COMPUTER_SYSTEM CSYS on SYS.ResourceID = CSYS.ResourceID 
	LEFT JOIN v_GS_OPERATING_SYSTEM OPSYS on SYS.ResourceID=OPSYS.ResourceID 
	LEFT JOIN v_R_User USR on SYS.User_Name0 = USR.User_Name0
	LEFT JOIN v_FullCollectionMembership FCM on SYS.ResourceID = FCM.ResourceID 
	LEFT JOIN vSMS_Boundary BDY on IPSub.IP_Subnets0 = BDY.Value
	LEFT JOIN v_CISettings CIS on CMPSTAT.CI_ID = CIS.CI_ID
	LEFT JOIN v_LocalizedCIProperties_SiteLoc CIPROP on CMPSTAT.CI_ID = CIPROP.CI_ID
  
  where CIPROP.DisplayName = @CIName
  --CMPSTAT.CI_ID = 16816952 
  --and ComplianceState = 1
  --and IsDetected = 0
  
  GROUP BY CMPSTAT.CI_ID
      ,SYS.Name0
      ,STATID.StateName
      ,CMPSTAT.ComplianceState
--	  ,CMP.CurrentValue, CMP.LastComplianceMessageTime
	  ,CIPROP.DisplayName
	  ,CIPROP.Description
	  ,CIS.SettingName
      ,CMPSTAT.CIVersion
      ,CMPSTAT.IsDetected
      ,CMPSTAT.ComplianceValidationRuleFailures
      ,CMPSTAT.ErrorCount
      ,CMPSTAT.ConflictCount
      ,CMPSTAT.LastComplianceMessageTime
      ,SYS.User_Name0
  