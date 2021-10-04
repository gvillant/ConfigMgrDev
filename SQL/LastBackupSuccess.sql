/*
LastBackupSuccess
*/

SELECT 
    stat.MachineName AS ServerName,stat.SiteCode AS SiteCode,MAX(stat.Time) AS LastBackUpTime 
FROM 
    (SELECT a.* FROM v_StatusMessage a join v_StatusMessage b 
    on a.sitecode = b.sitecode 
    AND a.modulename = b.modulename 
    AND a.recordid > b.recordid 
WHERE 
    a.component = 'SMS_SITE_BACKUP' 
    AND b.Component = 'SMS_SITE_BACKUP' 
    AND a.MessageID in (501) 
    AND b.messageID = 500 
    AND not exists 
(SELECT * FROM v_StatusMessage where component = 'SMS_SITE_BACKUP' and sitecode = a.sitecode and messageid = 4610 and recordid > b.recordid and recordid < a.recordid) 
and not exists 
(SELECT * FROM v_StatusMessage where component = 'SMS_SITE_BACKUP' and sitecode = a.sitecode and messageid = 500 and recordid > b.recordid and recordid < a.recordid) 
and not exists 
(SELECT * FROM v_StatusMessage where component = 'SMS_SITE_BACKUP' and sitecode = a.sitecode and messageid in (501) and recordid > b.recordid and recordid < a.recordid) 
) stat INNER JOIN v_Site sites 
                on sites.ServerName = stat.MachineName 
WHERE 
    sites.Type = 2 
GROUP BY 
    stat.SiteCode, stat.MachineName 
ORDER BY 3