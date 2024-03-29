DECLARE @olddate datetime 
SET @olddate=DATEADD(day,-7, GETUTCDATE())

DECLARE @WUSuccess int
SET @WUSuccess = (SELECT  COUNT(1)
                           FROM v_updateScanStatus upp 
                                INNER JOIN v_statenames stn 
                                   ON upp.LastScanState = stn.StateID 
                                  AND stn.TopicType = '501' 
                                  AND stn.StateName = 'Scan completed' 
                                INNER JOIN v_RA_System_SMSAssignedSites sit 
                                   ON upp.ResourceID = sit.ResourceID 
                                  AND upp.LastScanPackageLocation LIKE 'http%' 
                                  AND upp.LastScanTime > @olddate
                          GROUP BY  upp.LastScanState 
                                   ,sit.SMS_Assigned_Sites0
)

SELECT top 1 
		SiteCode
      ,ClientsActive as TotalActiveClients
      ,ClientsActiveHW as HWSuccess
      ,CONVERT(decimal(5,2),(ClientsActiveHW*100.00/ClientsActive)) AS 'HW Percentage' 
      ,ClientsActiveSW as SWSuccess 
      ,CONVERT(decimal(5,2),(ClientsActiveSW*100.00/ClientsActive))  AS 'SW Percentage' 
      ,ClientsActiveDDR as DDRSuccess
      ,CONVERT(decimal(5,2),(ClientsActiveDDR*100.00/ClientsActive))  AS 'DDR Percentage' 
      ,@WUSuccess as WUSuccess
      ,CONVERT(decimal(5,2),(@WUSuccess*100.00/ClientsActive))  AS 'WU Percentage' 
      ,ClientsInactive
      ,ClientsTotal
      ,Date

  FROM 
  v_CH_ClientSummaryHistory
  where CollectionID = 'SMSDM003' --Collection 'All Desktop and Server Clients'
    
  order by DATE desc 
  
  