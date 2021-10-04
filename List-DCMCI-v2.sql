/****** Script for SelectTopNRows command from SSMS  ******/
SELECT  LCI.[CI_ID], CI.CI_UniqueID
      ,LCI.[LocaleID]
      ,LCI.[DisplayName]
      ,LCI.[Description]
      ,LCI.[CIInformativeURL]
      ,LCI.[rowversion],*
  FROM [CM_STG].[dbo].[v_LocalizedCIProperties_SiteLoc] LCI
  left join v_ConfigurationItems CI on LCI.CI_ID = CI.CI_ID
  where DisplayName like '%exch%'
  
  