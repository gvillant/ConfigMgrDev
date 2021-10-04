/****** Script for SelectTopNRows command from SSMS  ******/
SELECT  DISTINCT Name,[LastErrorCode]
      ,[PushSiteCode]
      ,[AssignedSiteCode]
      ,[InitialRequestDate]
      ,[Description]
      ,[NumProcessAttempts]
      ,[ErrorEventCreated]
      ,[Status]
  FROM v_CP_Machine
  --where LastErrorCode = 1305
    where Status <> 0 and Status <> 4
  ORDER BY Name
  