SELECT  distinct app.Manufacturer, app.DisplayName, app.SoftwareVersion, app.Description,

dt.DisplayName AS DeploymentTypeName, 
dt.PriorityInLatestApp, 
dt.DateCreated,dt.CreatedBy,
dt.DateLastModified, dt.LastModifiedBy ,
dt.Technology, 
v_ContentInfo.ContentSource, 
v_ContentInfo.SourceSize,
v_ContentInfo.ContentFlags,
(v_ContentInfo.ContentFlags & 0x00020000)/0x00020000 AS DONOT_FALLBACK ,
ITEM.CI_ID,
--ITEM.SDMPackageDigest,
ITEM.SDMPackageDigest.value('declare namespace p1="http://schemas.microsoft.com/SystemCenterConfigurationManager/2009/AppMgmtDigest"; 
      (p1:AppMgmtDigest/p1:DeploymentType/p1:Installer/p1:CustomData/p1:InstallCommandLine)[1]', 'nvarchar(max)') AS DTInstallString,
ITEM.SDMPackageDigest.value('declare namespace p1="http://schemas.microsoft.com/SystemCenterConfigurationManager/2009/AppMgmtDigest"; 
      (p1:AppMgmtDigest/p1:DeploymentType/p1:Installer/p1:CustomData/p1:UninstallCommandLine)[1]', 'nvarchar(max)') AS DTUnInstallString,
ITEM.SDMPackageDigest.value('declare namespace p1="http://schemas.microsoft.com/SystemCenterConfigurationManager/2009/AppMgmtDigest"; 
      (p1:AppMgmtDigest/p1:DeploymentType/p1:Installer/p1:CustomData/p1:ProductCode)[1]', 'nvarchar(max)') AS DTProductCode,
ITEM.SDMPackageDigest.value('declare namespace p1="http://schemas.microsoft.com/SystemCenterConfigurationManager/2009/AppMgmtDigest"; 
      (p1:AppMgmtDigest/p1:DeploymentType/p1:Installer/p1:CustomData/p1:ExecuteTime)[1]', 'nvarchar(max)') AS DTExecuteTime,
ITEM.SDMPackageDigest.value('declare namespace p1="http://schemas.microsoft.com/SystemCenterConfigurationManager/2009/AppMgmtDigest"; 
      (p1:AppMgmtDigest/p1:DeploymentType/p1:Installer/p1:CustomData/p1:MaxExecuteTime)[1]', 'nvarchar(max)') AS DTMaxExecuteTime,
ITEM.SDMPackageDigest.value('declare namespace p1="http://schemas.microsoft.com/SystemCenterConfigurationManager/2009/AppMgmtDigest"; 
      (p1:AppMgmtDigest/p1:DeploymentType/p1:Installer/p1:CustomData/p1:UserInteractionMode)[1]', 'nvarchar(max)') AS UserInteractionMode,
ITEM.SDMPackageDigest.value('declare namespace p1="http://schemas.microsoft.com/SystemCenterConfigurationManager/2009/AppMgmtDigest"; 
      (p1:AppMgmtDigest/p1:DeploymentType/p1:Installer/p1:ExecutionContext)[1]', 'nvarchar(max)') AS ExecutionContext 
                      
FROM         dbo.fn_ListDeploymentTypeCIs(1033) AS dt 
LEFT JOIN            dbo.fn_ListLatestApplicationCIs(1033) AS app ON dt.AppModelName = app.ModelName 
LEFT JOIN       v_ContentInfo ON dt.ContentId = v_ContentInfo.Content_UniqueID
LEFT JOIN		  v_ConfigurationItems ITEM on dt.CI_ID = ITEM.CI_ID
WHERE     (dt.IsLatest = 1) 
/*and 
ITEM.SDMPackageDigest.value('declare namespace p1="http://schemas.microsoft.com/SystemCenterConfigurationManager/2009/AppMgmtDigest"; 
      (p1:AppMgmtDigest/p1:DeploymentType/p1:Installer/p1:CustomData/p1:InstallCommandLine)[1]', 'nvarchar(max)') like '%package%'
*/
order by Manufacturer, DisplayName,SoftwareVersion
