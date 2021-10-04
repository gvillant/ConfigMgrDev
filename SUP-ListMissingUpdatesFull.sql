declare @AuthListLocalID as int
declare @AuthListID as varchar(250)
declare @CollID as varchar(10)
declare @UpdatesBefore as Date

Set @CollID = 'FFF00274'
Set @AuthListID = 'ScopeId_25A690F5-780E-4EBE-8F34-3E95034EC5EE/AuthList_B014BABB-6355-4B3A-A628-7B36F2F1A1C1'
select @AuthListLocalID=CI_ID from v_AuthListInfo where CI_UniqueID=@AuthListID

SELECT
rs.NetBios_Name0 AS Name,
ui.ArticleID,ui.BulletinID,ui.Title,
ui.DatePosted, ui.DateLastModified, 
cat.CategoryInstanceName,
CASE ui.Severity
  WHEN 10 THEN 'Critical' 
  WHEN 8 THEN 'Important' 
  WHEN 6 THEN 'Moderate' 
  WHEN 2 THEN 'Low' 
  WHEN 0 THEN 'None'
  ELSE '(Unknown)' 
END AS [Severity],
ucsa.Status, 
CASE 
  WHEN DATEDIFF("day",ui.DateRevised,GETDATE()) < 30 THEN '0'
  WHEN DATEDIFF("day",ui.DateRevised,GETDATE()) >= 30 THEN '1'
END AS Age,
ui.IsExpired,ui.IsSuperseded

FROM v_UpdateComplianceStatus ucsa
INNER JOIN v_CIRelation cir ON ucsa.CI_ID = cir.ToCIID
INNER JOIN v_UpdateInfo ui ON ucsa.CI_ID = ui.CI_ID 
LEFT JOIN v_R_System rs ON ucsa.ResourceID = rs.ResourceID 
LEFT JOIN v_CICategoryInfo_All cat on ucsa.CI_ID = cat.CI_ID
--WHERE Name0 = '0000SADC01' 
WHERE 
cat.CategoryTypeName = 'UpdateClassification' 
and cir.RelationType = 1
and cir.FromCIID = @AuthListLocalID 
AND ucsa.ResourceID in (Select vc.ResourceID FROM v_FullCollectionMembership vc WHERE vc.CollectionID = @CollID)
and ucsa.Status = '2' -- = Required

order by name, CategoryInstanceName, Severity, DateLastModified desc

