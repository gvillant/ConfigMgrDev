select 
	COL.collectionname as [CollectionName]
      ,COL.SiteID
      ,COL.Flags
      ,COL.CollectionComment
      ,COL.Schedule
      ,COL.LastChangeTime
      ,COL.LastRefreshRequest
      ,COL.CollectionType
      ,COL.LimitToCollectionID
      ,COL.IsReferenceCollection
      ,COL.BeginDate
      ,COL.EvaluationStartTime
      ,COL.LastRefreshTime
      ,COL.LastIncrementalRefreshTime
      ,COL.LastMemberChangeTime
      ,COL.CurrentStatus
      ,COL.CurrentStatusTime
      ,COL.LimitToCollectionName
      ,COL.CollectionVariablesCount
      ,COL.ServiceWindowsCount
      ,COL.PowerConfigsCount
      ,COL.RefreshType
      ,COL.IsBuiltIn
      ,COL.IncludeExcludeCollectionsCount
      ,COL.LocalMemberCount
      ,COL.HasProvisionedMember,
		FL.Name as[FolderName], 
		FLM.ContainerNodeID as [FolderID], 
		COL.siteid as [CollectionID]

FROM vcollections COL
INNER JOIN vFolderMembers FLM on COL.siteid = FLM.InstanceKey
INNER JOIN vsms_folders FL on FLM.ContainerNodeID = FL.ContainerNodeID

WHERE FLM.ObjectTypeName = 'SMS_Collection_Device' and FL.Name = '_Limited'
--AND FL.Name = '_Limited' and Schedule =''
--and LastIncrementalRefreshTime is null 

ORDER BY COL.CollectionName

