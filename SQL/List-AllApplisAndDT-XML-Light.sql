
;WITH XMLNAMESPACES (DEFAULT 'http://schemas.microsoft.com/SystemCenterConfigurationManager/2009/AppMgmtDigest')
SELECT DISTINCT  

APP.SDMPackageDigest.value('(/AppMgmtDigest/Application/CustomId)[1]', 'nvarchar(max)') as APPCustomID,
APP.Manufacturer as APPManufacturer, APP.DisplayName as APPDisplayName, APP.SoftwareVersion as APPSoftwareVersion, APP.Description as APPDescription,
--ISC.FamilyName as AIFamilyName,
--ISC.CategoryName as AICategoryName,
--CAT1.CategoryName as CAT1CategoryName,
--CAT2.CategoryName as CAT2CategoryName,
--CAT3.CategoryName as CAT3CategoryName,
--CLG.Name as CLGName,CLG.Categories as CLGCategories,CLG.Keywords as CLGKeywords,CLG.Icon as CLGIcon,CLG.EndUserDocUrl as CLGEndUserDocUrl,CLG.EndUserDocUrlText as CLGEndUserDocUrlText,
--CLG.Description as CLGDescription,CLG.PrivacyUrl as CLGPrivacyUrl,DT.DisplayName as DTDeploymentTypeName, 
DT.PriorityInLatestApp as DTPriorityInLatestApp, 
DT.DateCreated as DTDateCreated,DT.CreatedBy as DTCreatedBy,
DT.DateLastModified as DTDateLastModified, DT.LastModifiedBy as DTLastModifiedBy ,
DT.Technology as DTTechnology, 
CTINF.ContentSource as CINFContentSource, 
CTINF.SourceSize as CINFSourceSize,
--CTINF.ContentFlags as CINFContentFlags,
(CTINF.ContentFlags & 0x00020000)/0x00020000 as CINFDoNotFallback,
--ITEM.CI_ID,
--ITEM.SDMPackageDigest,
--/*
ITEM.SDMPackageDigest.value('(AppMgmtDigest/DeploymentType/Installer/CustomData/InstallCommandLine)[1]', 'nvarchar(max)') as DTInstallString,
ITEM.SDMPackageDigest.value('(AppMgmtDigest/DeploymentType/Installer/CustomData/UninstallCommandLine)[1]', 'nvarchar(max)') as DTUnInstallString,
ITEM.SDMPackageDigest.value('(AppMgmtDigest/DeploymentType/Installer/CustomData/ProductCode)[1]', 'nvarchar(max)') as DTProductCode,
ITEM.SDMPackageDigest.value('(AppMgmtDigest/DeploymentType/Installer/CustomData/ExecuteTime)[1]', 'nvarchar(max)') as DTExecuteTime,
ITEM.SDMPackageDigest.value('(AppMgmtDigest/DeploymentType/Installer/CustomData/MaxExecuteTime)[1]', 'nvarchar(max)') as DTMaxExecuteTime,
ITEM.SDMPackageDigest.value('(AppMgmtDigest/DeploymentType/Installer/CustomData/RequiresReboot)[1]', 'nvarchar(max)') as RequiresReboot,

--ITEM.SDMPackageDigest.value('(AppMgmtDigest/DeploymentType/Installer/ExecutionContext)[1]', 'nvarchar(max)') as 'ExecutionContext(InstallationBehavior)',
CASE 
	WHEN ITEM.SDMPackageDigest.value('(AppMgmtDigest/DeploymentType/Installer/ExecutionContext)[1]', 'nvarchar(max)') IS NULL THEN 'Install for system if Device; otherwise install for User'
	ELSE ITEM.SDMPackageDigest.value('(AppMgmtDigest/DeploymentType/Installer/ExecutionContext)[1]', 'nvarchar(max)')
	END as 'RequiresLogOn(LogonRequirement)', 

--ITEM.SDMPackageDigest.value('(AppMgmtDigest/DeploymentType/Installer/RequiresLogOn)[1]', 'nvarchar(max)') as 'RequiresLogOn(LogonRequirement)',
CASE 
	WHEN ITEM.SDMPackageDigest.value('(AppMgmtDigest/DeploymentType/Installer/RequiresLogOn)[1]', 'nvarchar(max)') IS NULL THEN 'Wheher or not a user is logged on'
	WHEN ITEM.SDMPackageDigest.value('(AppMgmtDigest/DeploymentType/Installer/RequiresLogOn)[1]', 'nvarchar(max)') = 'true' THEN 'Only when a user is logged on'
	WHEN ITEM.SDMPackageDigest.value('(AppMgmtDigest/DeploymentType/Installer/RequiresLogOn)[1]', 'nvarchar(max)') = 'false' THEN 'Only when no user is logged on'
	END as 'RequiresLogOn(LogonRequirement)',

CASE 
	WHEN ITEM.SDMPackageDigest.value('(AppMgmtDigest/DeploymentType/Installer/CustomData/UserInteractionMode)[1]', 'nvarchar(max)') IS NULL THEN 'Normal'
	ELSE ITEM.SDMPackageDigest.value('(AppMgmtDigest/DeploymentType/Installer/CustomData/UserInteractionMode)[1]', 'nvarchar(max)') 
	END as 'UserInteractionMode(InstallProgramVisibility)',
CASE 
	WHEN 
	ITEM.SDMPackageDigest.value('(AppMgmtDigest/DeploymentType/Installer/CustomData/RequiresUserInteraction)[1]', 'nvarchar(max)') IS NULL THEN 'false'
	ELSE 'true'
	END as 'RequiresUserInteraction(AllowUserToInteract)',

	ITEM.SDMPackageDigest.value('(/AppMgmtDigest/DeploymentType/Installer/InstallAction/Args/Arg/@Name) [9]', 'nvarchar(MAX)') ,
CASE 
	WHEN 
	ITEM.SDMPackageDigest.value('(/AppMgmtDigest/DeploymentType/Installer/InstallAction/Args/Arg/@Name) [9]', 'nvarchar(MAX)') = 'PostInstallBehavior' Then ITEM.SDMPackageDigest.value('(/AppMgmtDigest/DeploymentType/Installer/InstallAction/Args/Arg) [9]', 'nvarchar(MAX)')-- IS NULL THEN 'Determine based on return codes'
	ELSE NULL
	END as 'RestartBehavior'
--*/                     
FROM			dbo.fn_ListDeploymentTypeCIs(1033) DT 
LEFT JOIN       dbo.fn_ListLatestApplicationCIs(1033) APP		ON DT.AppModelName = APP.ModelName 
LEFT JOIN		v_ContentInfo CTINF									ON DT.ContentId = CTINF.Content_UniqueID
LEFT JOIN		v_ConfigurationItems ITEM						on DT.CI_ID = ITEM.CI_ID
--LEFT JOIN		v_CatalogAppModelProperties CLG					on APP.ModelID = CLG.ModelOrProgId
--LEFT JOIN		v_GS_INSTALLED_SOFTWARE_CATEGORIZED ISC			on APP.SDMPackageDigest.value('(/AppMgmtDigest/Application/CustomId)[1]', 'nvarchar(max)') = ISC.NormalizedName
--LEFT JOIN		v_LU_Category_Editable CAT1						on CAT1.CategoryID = ISC.Tag1ID
--LEFT JOIN		v_LU_Category_Editable CAT2						on CAT2.CategoryID = ISC.Tag2ID
--LEFT JOIN		v_LU_Category_Editable CAT3						on CAT3.CategoryID = ISC.Tag3ID


WHERE     (DT.IsLatest = 1) 
/*and 
ITEM.SDMPackageDigest.value((AppMgmtDigest/DeploymentType/Installer/CustomData/InstallCommandLine)[1]', 'nvarchar(max)') like '%package%'
AND Manufacturer = 'Matchware'
*/
order by APP.Manufacturer, APP.DisplayName,APP.SoftwareVersion
