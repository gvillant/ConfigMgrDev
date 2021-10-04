SELECT DISTINCT app.Manufacturer, app.DisplayName, app.SoftwareVersion, app.Description,

dt.DisplayName AS DeploymentTypeName, 
dt.PriorityInLatestApp, 
dt.DateCreated,
dt.DateLastModified,
dt.Technology, 
v_ContentInfo.ContentSource, 
v_ContentInfo.SourceSize,
v_ContentInfo.ContentFlags,
(v_ContentInfo.ContentFlags & 0x00020000)/0x00020000 AS DONOT_FALLBACK 
                      
FROM         dbo.fn_ListDeploymentTypeCIs(1033) AS dt 
LEFT JOIN            dbo.fn_ListLatestApplicationCIs(1033) AS app ON dt.AppModelName = app.ModelName 
LEFT JOIN       v_ContentInfo ON dt.ContentId = v_ContentInfo.Content_UniqueID
WHERE     (dt.IsLatest = 1)
order by Manufacturer, DisplayName,SoftwareVersion