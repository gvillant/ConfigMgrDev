/****** Script for SelectTopNRows command from SSMS  ******/
SELECT SYS.name0, sys.User_Name0, sys.User_Domain0,
 [ModelID]
      ,[ItemKey]
      ,[CIVersion]
      ,[SDMPackageVersion]
      ,[RuleType]
      ,[InstanceData]
      ,[PreReifiedValue]
      ,[PostReifiedValue]
      ,[RuleID]
      ,[SettingID]
      ,[IsRuleValue]
      ,[ContributionRulesCount]
      ,[UserID]
      ,[ContributingRules]
  FROM v_R_System SYS
  
  LEFT JOIN v_CIComplianceStatusReificationDetail REM on SYS.ResourceID = REM.ItemKey
  WHERE ModelID = '16802805' and PreReifiedValue <> PostReifiedValue and PreReifiedValue like '%' + sys.User_Name0 + '%'
  --and PreReifiedValue like 'FRS%' 
  --and ItemKey = '16778734'
  order by Name0