select DISTINCT
ISC.ProductName0 as ProductName, ISC.ProductVersion0 as ProductVersion, ISC.Publisher0 as Publisher,
ISC.NormalizedName, ISC.NormalizedVersion, ISC.NormalizedPublisher, ISC.MPC0 as MPC, ISC.ChannelCode0 as ChannelCode, ISC.FamilyName, ISC.CategoryName, 
CAT1.CategoryName as Tag1,
CAT2.CategoryName as Tag2,
CAT3.CategoryName as Tag3,
ISC.SoftwarePropertiesHash0 AS Hash,
ISC.UninstallString0 as UninstallString

FROM v_GS_INSTALLED_SOFTWARE_CATEGORIZED ISC
LEFT JOIN v_LU_Category_Editable CAT1 on CAT1.CategoryID = ISC.Tag1ID
LEFT JOIN v_LU_Category_Editable CAT2 on CAT2.CategoryID = ISC.Tag2ID
LEFT JOIN v_LU_Category_Editable CAT3 on CAT3.CategoryID = ISC.Tag3ID

WHERE  ISC.Tag1ID is not null 
--and SYS.Name0 = 'FRS01501' 
--and (ISC.NormalizedName = 'Microsoft Visio Standard 2013' or ISC.NormalizedName = 'Visio Standard 2013')
--and ISC.NormalizedName like '%Visio Standard 2013%' --and SYS.Resource_Domain_OR_Workgr0 = 'STAGO'
