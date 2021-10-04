DECLARE @UserSIDs nvarchar(max) 
DECLARE @SiteCode nvarchar(max) = 'STG'
DECLARE @StateMigrationPoint nvarchar(max) = '%'

SELECT SourceName AS StateMigrationSource0 
       , MAX(StoreCreationDate) AS StateMigrationCaptureDate0 
       , ROUND( MAX(StoreSize) / 1000000.0, 1 ) AS StateMigrationStateSize0  
       , RestoreName
       , COUNT(*) AS StateMigrationTotalAssoc0 
       , COUNT(StoreReleaseDate) AS StateMigrationReleasedAssoc0 
       , COUNT(*) - COUNT(StoreReleaseDate) AS StateMigrationRemainingAssoc0 
       , MAX(StorePath) AS StateMigrationStateLocation0 
FROM fn_rbac_StateMigration(@UserSIDs)   
WHERE SiteCode LIKE @SiteCode AND SMPServerName LIKE @StateMigrationPoint AND StoreDeletionDate IS NULL 
GROUP BY SourceName, RestoreName 
ORDER BY SourceName

