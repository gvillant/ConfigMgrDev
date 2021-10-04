SELECT 
[t2].[CollectionName], [t2].[SiteID] as CollectionID,t2.refreshType,
[t2].[value] AS [Seconds], 
[t2].[LastIncrementalRefreshTime], 
[t2].[IncrementalMemberChanges] AS [IncChanges], 
[t2].[LastMemberChangeTime] AS [MemberChangeTime]

FROM (
		SELECT [t0].[CollectionName], 
			[t0].[SiteID], 
			DATEDIFF(Millisecond, 
			[t1].[IncrementalEvaluationStartTime], 
			[t1].[LastIncrementalRefreshTime]) * 0.001 AS [value], 
			[t1].[LastIncrementalRefreshTime], 
			[t1].[IncrementalMemberChanges], 
			[t1].[LastMemberChangeTime], 
			[t1].[IncrementalEvaluationStartTime], 
			v1.[RefreshType]

			FROM [dbo].[Collections_G] AS [t0]

			INNER JOIN [dbo].[Collections_L] AS [t1] ON [t0].[CollectionID] = [t1].[CollectionID]
			inner join v_Collection v1 on [t0].[siteid] = v1.CollectionID) AS [t2]

	WHERE ([t2].[IncrementalEvaluationStartTime] IS NOT NULL) 
	AND ([t2].[LastIncrementalRefreshTime] IS NOT NULL) 
	AND (refreshtype='4' or refreshtype='6')
	AND collectionName like '%MADMR%'
	AND collectionName NOT like '%FFF%'
	AND collectionName NOT like '%0000%'
ORDER BY [t2].[CollectionName], t2.[value] DESC