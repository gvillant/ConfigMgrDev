/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP 1000 [CI_ID]
      ,[LocaleID]
      ,[DisplayName]
      ,[Description]
      ,[CIInformativeURL]
      ,[rowversion]
  FROM [CM_STG].[dbo].[v_LocalizedCIProperties_SiteLoc]
  where DisplayName like '%DPM%'