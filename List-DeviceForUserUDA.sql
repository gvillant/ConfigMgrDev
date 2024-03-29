/****** Script for SelectTopNRows command from SSMS  ******/
SELECT  umr.RelationshipResourceID
      ,umr.[UniqueUserName]
      ,[MachineResourceID]
      ,[RelationActive]
      ,umr.CreationTime
      ,[MachineResourceName]
      ,[MachineResourceClientType]
      ,umtr.*
  FROM v_R_System sys
  left join [v_UserMachineRelationship] umr on umr.MachineResourceID = sys.ResourceID
  left join v_UserMachineTypeRelation umtr on umtr.RelationshipResourceID = umr.RelationshipResourceID
  where umr.[UniqueUserName] like 'stago\melotf' and umtr.RelationshipResourceID is not null