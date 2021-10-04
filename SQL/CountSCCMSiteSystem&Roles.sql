/*
CountSCCMSiteSystem&Roles
*/

SELECT 
    r.rolename as RoleName,count (*) as ServerCount from v_systemresourcelist r 
--WHERE rolename in ('SMS Management Point','SMS Site Server','SMS SQL Server','AI Update Service Point','SMS Distribution Point','SMS Software Update Point','SMS Fallback Status Point','SMS System Health Validator','SMS Reporting Point','SMS Server Locator Point') 
GROUP BY r.rolename 
ORDER BY 2 desc
