/*
Client Count & Percentage with Hardware & Software Inventory Reported in last 7 days
*/

DECLARE  @olddate datetime 
        ,@NullVal datetime 
SET @olddate = DATEADD(day,-7, GETUTCDATE())

SELECT  sites.SMS_Assigned_Sites0   AS AssignedSite 
       ,TotalSys.Total AS TotalActiveClients 
       ,SuccSys.Succ AS HWSuccess 
       ,SuccSW.Succ AS SWSuccess 
       ,CONVERT(decimal(5,2),(SuccSys.Succ*100.00/TotalSys.Total)) AS 'HW Percentage' 
       ,CONVERT(decimal(5,2),(SuccSW.Succ*100.00/TotalSys.Total))  AS 'SW Percentage' 
       
  FROM v_RA_system_smsassignedsites sites 
       INNER JOIN ( 
                   
                   SELECT  sit.SMS_Assigned_Sites0 AS AssSite 
                          ,COUNT(DISTINCT sis.Netbios_Name0) AS Succ 
                     FROM v_RA_System_SMSAssignedSites sit 
                          INNER JOIN v_R_System sis 
                             ON sit.ResourceID = sis.ResourceID 
                          INNER JOIN v_gs_workstation_status sts 
                             ON sis.ResourceID = sts.ResourceID 
                            AND sis.Client0 = 1 
                            AND sis.Obsolete0 = 0 
                            AND sis.Active0 = 1 
                            AND sts.LastHWScan > @olddate 
                    GROUP BY sit.sms_assigned_sites0 
                   ) SuccSys 
          ON sites.SMS_Assigned_Sites0 = SuccSys.AssSite 
       INNER JOIN ( 
                   SELECT  sit.SMS_Assigned_Sites0 AS AssSite 
                          ,COUNT(DISTINCT sis.Netbios_Name0) AS Succ 
                     FROM v_RA_System_SMSAssignedSites sit 
                          INNER JOIN v_R_System sis 
                             ON sit.ResourceID = sis.ResourceID 
                          INNER JOIN v_GS_LastSoftwareScan sts 
                             ON sis.ResourceID = sts.ResourceID 
                            AND sis.Client0 = 1 
                            AND sis.Obsolete0 = 0 
                            AND sis.Active0 = 1 
                            AND sts.LastScanDate > @olddate 
                    GROUP BY sit.SMS_Assigned_Sites0 
                   ) SuccSW 
          ON SuccSW.AssSite = sites.SMS_Assigned_Sites0 
       INNER JOIN ( 
                   SELECT  sit.SMS_Assigned_Sites0 AS AssSite 
                          ,COUNT(DISTINCT sis.Netbios_Name0) AS Total 
                     FROM v_RA_System_SMSAssignedSites sit 
                          INNER JOIN v_R_system sis 
                             ON sit.ResourceID = sis.ResourceID 
                            AND sis.Client0 = 1 
                            AND sis.Obsolete0 = 0 
                            AND sis.Active0 = 1 
                    GROUP BY sit.SMS_Assigned_Sites0 
                   ) TotalSys 
          ON sites.SMS_Assigned_Sites0 = TotalSys.Asssite 
GROUP BY  sites.SMS_Assigned_Sites0 
          ,TotalSys.Total 
          ,SuccSys.Succ 
          ,SuccSW.Succ 
ORDER BY 4 DESC 