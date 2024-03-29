/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP 1000 [ContainerNodeID]
      ,[Name]
      ,[ObjectType]
      ,[ParentContainerNodeID]
      ,[SearchFolder]
      ,[FolderFlags]
      ,[SearchString]
      ,[SourceSite]
      ,[FolderGuid]
      ,[ObjectTypeName]
      ,[IsEmpty]
  FROM [CM_STG].[dbo].[vSMS_Folders]
  where ParentContainerNodeID = 16777485