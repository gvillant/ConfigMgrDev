
;WITH XMLNAMESPACES (DEFAULT 'http://schemas.microsoft.com/SystemCenterConfigurationManager/2009/AppMgmtDigest')
SELECT DISTINCT 
--app.CI_UniqueID,

APP.Manufacturer as Manufacturer, APP.DisplayName as DisplayName, APP.SoftwareVersion as SoftwareVersion, APP.Description as Description,

APP.SDMPackageDigest.value('(/AppMgmtDigest/Application/CustomId)[1]', 'nvarchar(max)') as APPCustomID,
APP.SDMPackageDigest.value('(/AppMgmtDigest/Application/DisplayInfo/Info/ReleaseDate)[1]', 'nvarchar(max)') as APPReleaseDate,

APP.SDMPackageDigest.value('(/AppMgmtDigest/Application/Owners/User/@Id)[1]', 'nvarchar(max)') as APPOwners,
APP.SDMPackageDigest.value('(/AppMgmtDigest/Application/Contacts/User/@Id)[1]', 'nvarchar(max)') as APPContact,

/*
ISC.FamilyName as AIFamilyName,
ISC.CategoryName as AICategoryName,
CAT1.CategoryName as CAT1CategoryName,
CAT2.CategoryName as CAT2CategoryName,
CAT3.CategoryName as CAT3CategoryName,
*/
CLG.Name as CLGName,
CLG.Categories as CLGCategories,
CLG.Keywords as CLGKeywords,
FOL.Name as Folder,
CLG.Icon as CLGIcon,
CLG.EndUserDocUrl as CLGEndUserDocUrl,
CLG.EndUserDocUrlText as CLGEndUserDocUrlText,
CLG.Description as CLGDescription,
CLG.PrivacyUrl as CLGPrivacyUrl,

app.IsEnabled,
app.IsSuperseded, app.IsDeployed, 
app.NumberOfDeployments,
app.NumberOfUsersWithApp,app.NumberOfDevicesWithApp,
app.NumberOfDeploymentTypes,

DT.DisplayName as DeploymentTypeName, 
DT.PriorityInLatestApp as PriorityInLatestApp, 
DT.DateCreated as DateCreated,DT.CreatedBy as CreatedBy,
DT.DateLastModified as DateLastModified, DT.LastModifiedBy as LastModifiedBy ,
DT.Technology as Technology, 
CTINF.ContentSource as ContentSource, 
CTINF.SourceSize as SourceSize,
CTINF.ContentFlags as ContentFlags,
(CTINF.ContentFlags & 0x00020000)/0x00020000 as DoNotFallback,
--/*
ITEM.CI_ID,
--ITEM.SDMPackageDigest,
ITEM.SDMPackageDigest.value('(AppMgmtDigest/DeploymentType/Installer/CustomData/InstallCommandLine)[1]', 'nvarchar(max)') as DTInstallString,
ITEM.SDMPackageDigest.value('(AppMgmtDigest/DeploymentType/Installer/CustomData/UninstallCommandLine)[1]', 'nvarchar(max)') as DTUnInstallString,
ITEM.SDMPackageDigest.value('(AppMgmtDigest/DeploymentType/Installer/CustomData/ProductCode)[1]', 'nvarchar(max)') as DTProductCode,
ITEM.SDMPackageDigest.value('(AppMgmtDigest/DeploymentType/Installer/CustomData/ExecuteTime)[1]', 'nvarchar(max)') as DTExecuteTime,
ITEM.SDMPackageDigest.value('(AppMgmtDigest/DeploymentType/Installer/CustomData/MaxExecuteTime)[1]', 'nvarchar(max)') as DTMaxExecuteTime,
ITEM.SDMPackageDigest.value('(AppMgmtDigest/DeploymentType/Installer/CustomData/UserInteractionMode)[1]', 'nvarchar(max)') as UserInteractionMode,
ITEM.SDMPackageDigest.value('(AppMgmtDigest/DeploymentType/Installer/ExecutionContext)[1]', 'nvarchar(max)') as ExecutionContext ,
ITEM.SDMPackageDigest.value('(/AppMgmtDigest/DeploymentType/Installer/Contents/Content/OnFastNetwork)[1]', 'nvarchar(max)') AS [OnFastNetwork] ,
ITEM.SDMPackageDigest.value('(/AppMgmtDigest/DeploymentType/Installer/Contents/Content/OnSlowNetwork)[1]', 'nvarchar(max)') AS [OnSlowNetwork] 
--*/                      
FROM			dbo.fn_ListDeploymentTypeCIs(1033) DT 
LEFT JOIN       dbo.fn_ListLatestApplicationCIs(1033) APP		ON DT.AppModelName = APP.ModelName 
LEFT JOIN		v_ContentInfo CTINF								ON DT.ContentId = CTINF.Content_UniqueID
LEFT JOIN		v_ConfigurationItems ITEM						on DT.CI_ID = ITEM.CI_ID
LEFT JOIN		v_CatalogAppModelProperties CLG					on APP.ModelID = CLG.ModelOrProgId
--LEFT JOIN		v_GS_INSTALLED_SOFTWARE_CATEGORIZED ISC			on APP.SDMPackageDigest.value('(/AppMgmtDigest/Application/CustomId)[1]', 'nvarchar(max)') = ISC.NormalizedName
--LEFT JOIN		v_LU_Category_Editable CAT1						on CAT1.CategoryID = ISC.Tag1ID
--LEFT JOIN		v_LU_Category_Editable CAT2						on CAT2.CategoryID = ISC.Tag2ID
--LEFT JOIN		v_LU_Category_Editable CAT3						on CAT3.CategoryID = ISC.Tag3ID
LEFT JOIN		vFolderMembers FOLM								on app.ModelName = FOLM.InstanceKey
LEFT JOIN		vsms_folders FOL								on FOLM.ContainerNodeID = FOL.ContainerNodeID

WHERE  DT.IsLatest = 1 --and FOL.Name = 'Application Catalog - To BE'
/*and 
ITEM.SDMPackageDigest.value((AppMgmtDigest/DeploymentType/Installer/CustomData/InstallCommandLine)[1]', 'nvarchar(max)') like '%package%'
AND Manufacturer = 'Matchware'
*/
--and app.DisplayName = 'SKYPE FOR BUSINESS BASIC 2016_R01'
order by APP.Manufacturer, APP.DisplayName,APP.SoftwareVersion
