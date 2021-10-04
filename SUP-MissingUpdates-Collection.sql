declare @AuthListLocalID as int
declare @AuthListID as varchar(250)
declare @CollID as varchar(10)
declare @UpdatesBefore as Date
Set @CollID = 'FFF0009B'

Set @AuthListID = 'ScopeId_25A690F5-780E-4EBE-8F34-3E95034EC5EE/AuthList_B014BABB-6355-4B3A-A628-7B36F2F1A1C1'

select @AuthListLocalID=CI_ID from v_AuthListInfo where CI_UniqueID=@AuthListID


SELECT
rs.NetBios_Name0 AS Name,
ucsa.ResourceID,
CASE ui.Severity
  WHEN 10 THEN 'Critical' 
  WHEN 8 THEN 'Important' 
  WHEN 6 THEN 'Moderate' 
  WHEN 2 THEN 'Low' 
  WHEN 0 THEN 'Add-on'
  ELSE '(Unknown)' 
END AS [Severity],
CASE 
  WHEN DATEDIFF("day",ui.DateRevised,GETDATE()) < 30 THEN '0'
  WHEN DATEDIFF("day",ui.DateRevised,GETDATE()) >= 30 THEN '1'
END AS Age
INTO #tmp_SUMissing
FROM v_UpdateComplianceStatus ucsa
INNER JOIN v_CIRelation cir ON ucsa.CI_ID = cir.ToCIID
INNER JOIN v_UpdateInfo ui ON ucsa.CI_ID = ui.CI_ID 
LEFT JOIN v_R_System rs ON ucsa.ResourceID = rs.ResourceID 
WHERE cir.FromCIID=@AuthListLocalID 
AND cir.RelationType=1
AND ucsa.ResourceID in (Select vc.ResourceID FROM v_FullCollectionMembership vc WHERE vc.CollectionID = @CollID)
AND ucsa.Status = '2' --Required
--AND ui.DateRevised <= @UpdatesBefore

SELECT 
Name,
ResourceID,
SUM(CASE WHEN Severity = 'Critical' AND Age = 0 THEN 1 ELSE 0 END) AS LessCrit,
SUM(CASE WHEN Severity = 'Critical' AND Age = 1 THEN 1 ELSE 0 END) AS MoreCrit,
SUM(CASE WHEN Severity = 'Important' AND Age = 0  THEN 1 ELSE 0 END) AS LessImp,
SUM(CASE WHEN Severity = 'Important' AND Age = 1 THEN 1 ELSE 0 END) AS MoreImp,
SUM(CASE WHEN Severity = 'Moderate' AND Age = 0  THEN 1 ELSE 0 END) AS LessMod,
SUM(CASE WHEN Severity = 'Moderate' AND Age = 1 THEN 1 ELSE 0 END) AS MoreMod,
SUM(CASE WHEN Severity = 'Low' AND Age = 0  THEN 1 ELSE 0 END) AS LessLow,
SUM(CASE WHEN Severity = 'Low' AND Age = 1 THEN 1 ELSE 0 END) AS MoreLow,
SUM(CASE WHEN Severity = 'Add-on' AND Age = 0  THEN 1 ELSE 0 END) AS LessAddon,
SUM(CASE WHEN Severity = 'Add-on' AND Age = 1 THEN 1 ELSE 0 END) AS MoreAddon,
Count(Severity) As Total
FROM 
#tmp_SUMissing
Group By Name, ResourceID
ORDER BY Name

DROP TABLE #tmp_SUMissing