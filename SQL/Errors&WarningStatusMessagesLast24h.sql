/*
Errors&WarningStatusMessagesLast24h
*/

SELECT 
    MessageID 
    ,sm.Severity as SeverityN
    ,case sm.Severity
    WHEN '-2147483648' THEN 'Warning'
    WHEN '-1073741824' THEN 'Critical'
    ELSE ' Unknown' END as Severity
    ,MachineName 
    ,COUNT(*) as 'Count' 
    ,MAX(Time) as 'LastOccurred'  
    ,Component          
FROM v_StatusMessage sm WITH (NOLOCK) 
WHERE 
    ModuleName = 'SMS Server' 
    AND Sm.Severity != 1073741824 
    AND Time > DATEADD(hour, -24, GetutcDate()) 
    AND SiteCode in ('STG')            
GROUP BY 
    MessageID, MachineName, Component, sm.Severity 
ORDER BY 4 desc