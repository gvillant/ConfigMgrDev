
DECLARE @olddate datetime 
SET @olddate=DATEADD(DAY,-7, GETUTCDATE()) --Last 7 days 


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
                            --AND sts.LastHWScan > @olddate 
                    GROUP BY sit.sms_assigned_sites0 
                    
SELECT  sit.SMS_Assigned_Sites0 [SiteCode] 
               ,COUNT(1) TotalClient 
          FROM v_R_System sis 
               INNER JOIN v_RA_System_SMSAssignedSites sit 
                  ON sis.ResourceID = sit.ResourceID 
                 AND sis.Client0 = 1 
                 AND sis.Obsolete0 = 0 
                 AND sis.Active0 = 1 
           GROUP BY sit.SMS_Assigned_Sites0 