/****** Script for SelectTopNRows command from SSMS  ******/
SELECT [CI_ID]
      ,[CI_UniqueID]
      ,[DateCreated]
      ,[DateLastModified]
      ,CreatedBy
      ,[LastModifiedBy]
      ,[Title]
      ,[Description]
  FROM v_AuthListInfo
  order by Title