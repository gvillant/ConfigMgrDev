/*
SiteServersNotCommunicatedinLast24h
*/

SELECT DISTINCT 
    SiteCode, Role, --SiteSystem, charindex('\\', SiteSystem,12) as Pos, LEN(SiteSystem), 
    replace (right (SiteSystem, LEN(SiteSystem)-charindex('\\', SiteSystem,12)-1),'\', '') 
    , (SELECT TOP 1 TimeReported) AS LastReportedTime 
    , getutcdate() AS CurrentTime 
FROM vSummarizer_SiteSystem NOLOCK 
WHERE 
    TimeReported < DATEADD(HOUR,-24, getutcdate())
    