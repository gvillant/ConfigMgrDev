/****** Script for SelectTopNRows command from SSMS  ******/
SELECT distinct SettingName,CI_ID
  FROM v_CISettings
  --where SettingName like '%dpm%'
  --and ci_id = 16809615
  where SourceType in ('0','4','9')
  