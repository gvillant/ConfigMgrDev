select  
SYS.ResourceID, SYS.NAME0 as Name, TOPU.TopConsoleUser0 as TopConsoleUser, USR.Name0 as UserName,USR.sn0 ,USR.givenName0 as UserGivenName,
CASE WHEN (CHARINDEX('.',SYS.Resource_Domain_OR_Workgr0) = 0)  THEN UPPER(SYS.Resource_Domain_OR_Workgr0)
	ELSE UPPER(SUBSTRING (SYS.Resource_Domain_OR_Workgr0,0,CHARINDEX('.',SYS.Resource_Domain_OR_Workgr0)))
	END	as Domain,
CASE 
	WHEN SYS.Operating_System_Name_and0 like '%Workstation 5.0%' THEN 'Windows 2000'
	WHEN SYS.Operating_System_Name_and0 like '%Workstation 5.1%' THEN 'Windows XP'
	WHEN SYS.Operating_System_Name_and0 like '%Workstation 5.2%' THEN 'Windows XP'
	WHEN SYS.Operating_System_Name_and0 like '%Workstation 6.1%' THEN 'Windows 7'
	WHEN SYS.Operating_System_Name_and0 like '%Workstation 6.2%' THEN 'Windows 8'
	WHEN SYS.Operating_System_Name_and0 like '%Workstation 6.3%' THEN 'Windows 8.1'
	WHEN SYS.Operating_System_Name_and0 like '%Workstation 10.0%' THEN 'Windows 10'
	WHEN SYS.Operating_System_Name_and0 like '%Server 5.0%' THEN 'Server 2000'
	WHEN SYS.Operating_System_Name_and0 like '%Server 5.2%' THEN 'Server 2003'
	WHEN SYS.Operating_System_Name_and0 like '%Server 6.0%' THEN 'Server 2008'
	WHEN SYS.Operating_System_Name_and0 like '%Server 6.1%' THEN 'Server 2008 R2'
	WHEN SYS.Operating_System_Name_and0 like '%Server 6.2%' THEN 'Server 2012'
	WHEN SYS.Operating_System_Name_and0 like '%Server 6.3%' THEN 'Server 2012 R2'
	ELSE 'Unknown'
	END as [OSVer],
CASE 
	WHEN SYS.Operating_System_Name_and0 like '%Workstation%' THEN 'Workstation'
	WHEN SYS.Operating_System_Name_and0 like '%Server%' THEN 'Server'
	ELSE 'Unknown'
	END as [OSType],
	 
ISC.ProductName0 as ProductName, ISC.ProductVersion0 as ProductVersion, ISC.Publisher0 as Publisher,
ISC.NormalizedName, ISC.NormalizedVersion, ISC.NormalizedPublisher,
ISC.InstallDate0 as InstallDate, ISC.MPC0 as MPC, ISC.ChannelCode0 as ChannelCode, ISC.FamilyName, ISC.CategoryName, 
CAT1.CategoryName as Tag1,
CAT2.CategoryName as Tag2,
CAT3.CategoryName as Tag3,

ISC.SoftwarePropertiesHash0 AS Hash,
ISC.SoftwarePropertiesHashEx0

from v_GS_INSTALLED_SOFTWARE_CATEGORIZED ISC
LEFT JOIN v_LU_Category_Editable CAT1 on CAT1.CategoryID = ISC.Tag1ID
LEFT JOIN v_LU_Category_Editable CAT2 on CAT2.CategoryID = ISC.Tag2ID
LEFT JOIN v_LU_Category_Editable CAT3 on CAT3.CategoryID = ISC.Tag3ID
LEFT JOIN v_R_System SYS on SYS.ResourceID = ISC.ResourceID
LEFT JOIN v_GS_SYSTEM_CONSOLE_USAGE_MAXGROUP TOPU on ISC.ResourceID = TOPU.ResourceID
LEFT JOIN v_R_User USR on TOPU.TopConsoleUser0 = USR.Unique_User_Name0

WHERE SYS.Obsolete0 = 0 AND SYS.Client0 = '1'
AND ISC.Tag1ID is not null and ISC.InstallDate0 IS NOT NULL
-- and SYS.Name0 = 'FRS01501' 
-- and (ISC.NormalizedName = 'Adobe Acrobat 7 Professional' ) 
-- or ISC.NormalizedName = 'Microsoft Windows XP Professional Edition')
-- and ISC.NormalizedName like '%Visio Standard 2013%' --and SYS.Resource_Domain_OR_Workgr0 = 'STAGO'

ORDER BY SYS.Name0
