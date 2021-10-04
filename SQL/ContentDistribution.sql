--http://www.danrichings.com/?p=166
--ConfiMgr Content Report 

SELECT
 DPStatus.PackageID, PKG.Manufacturer + ' - ' + PKG.Name + ' - ' + PKG.[Version] AS [Content Name],
REPLACE(RBACObj.ObjectTypeName, 'SMS_','') AS [Content Type],
REPLACE(DPStatus.Name, '\', '') AS [Distribution Point],
 DPStatus.SiteCode,
CASE DPStatus.MessageState
WHEN 1 THEN 'Success'
WHEN 2 THEN 'In Progress'
WHEN 4 THEN 'Failed'
ELSE 'Unknown'
END AS [Status],
DPStatus.MessageID,
CASE DPStatus.MessageID
WHEN 2303 THEN 'Content was successfully refreshed'
WHEN 2324 THEN 'Failed to access or create the content share'
WHEN 2330 THEN 'Content was distributed to distribution point'
WHEN 2384 THEN 'Content hash has been successfully verified'
WHEN 2323 THEN 'Failed to initialize NAL'
WHEN 2354 THEN 'Failed to validate content status file'
WHEN 2357 THEN 'Content transfer manager was instructed to send content to the distribution point'
WHEN 2360 THEN 'Status message 2360 unknown'
WHEN 2370 THEN 'Failed to install distribution point'
WHEN 2371 THEN 'Waiting for prestaged content'
WHEN 2372 THEN 'Waiting for content'
WHEN 2376 THEN 'In Progress'
WHEN 2380 THEN 'Content evaluation has started'
WHEN 2381 THEN 'An evaluation task is running. Content was added to the queue'
WHEN 2382 THEN 'Content hash is invalid'
WHEN 2383 THEN 'Failed to validate content hash'
WHEN 2385 THEN 'Missing Files'
WHEN 2391 THEN 'Failed to connect to remote distribution point'
WHEN 2398 THEN 'Content Status not found'
WHEN 8203 THEN 'Failed to update package'
WHEN 8204 THEN 'Content is being distributed to the distribution point'
WHEN 8211 THEN 'Failed to update package'
ELSE 'Status message ' + CAST(DPStatus.MessageID AS VARCHAR) + ' unknown'
END AS [Message],
DPStatus.LastUpdateDate,
DPStatus.GroupCount AS [Group Count],
STAT.SourceSize as Size,
PKG.SourceVersion, PKG.LastRefreshTime, pkg.PkgSourcePath

 
FROM dbo.vSMS_DistributionDPStatus AS DPStatus
INNER JOIN dbo.RBAC_SecuredObjectTypes RBACObj ON DPStatus.ObjectTypeID = RBACObj.ObjectTypeID
LEFT OUTER JOIN dbo.v_Package PKG
LEFT JOIN v_PackageStatusRootSummarizer STAT on PKG.PackageID = STAT.PackageID
ON DPStatus.PackageID = PKG.PackageID
WHERE (DPStatus.MessageState in (2,4))-- AND PKG.PackageID = 'STG001BE' -- @MessageState) OR (@MessageState = 999) 
--and DPStatus.Name like '%cfsnuc%'
ORDER BY  [Distribution Point], PackageID --LastUpdateDate , [Distribution Point],  [Content Name], [Content Type],  PackageID ASC
