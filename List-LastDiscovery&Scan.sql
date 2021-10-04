

DECLARE @olddate datetime 
SET @olddate=DATEADD(DAY,-7, GETUTCDATE()) --Last 7 days 


SELECT DISTINCT SYS.Netbios_Name0 as Name, SYS.Client0, SYS.Obsolete0,
SYS.Operating_System_Name_and0 as OSVersion, 
 	HWSCAN.LastHWScan, SWSCAN.LastScanDate as LastSWScan, SWSCAN.LastCollectedFileScanDate as LastSWColScan, SUSCAN.LastScanTime as LastSUScanTime,SUSCAN.LastScanState as LastSUScanState, stn.StateName,stn.TopicType
 ,MAX(HBDISC.AgentTime) as LastHeartbeatTime, MAX(CLIREGDISC.AgentTime) as LastMPRegistrationTime

FROM v_R_System  SYS 
LEFT JOIN v_GS_LastSoftwareScan  SWSCAN		on SYS.ResourceID = SWSCAN.ResourceID 
LEFT JOIN v_GS_WORKSTATION_STATUS  HWSCAN	on SYS.ResourceID = HWSCAN.ResourceID 
LEFT JOIN v_updateScanStatus SUSCAN			on SYS.ResourceID = SUSCAN.ResourceID
LEFT JOIN v_statenames stn					ON SUSCAN.LastScanState = stn.StateID 
												AND stn.TopicType = '501' 
												--AND stn.StateName = 'Scan completed' 
LEFT JOIN v_AgentDiscoveries HBDISC			on SYS.ResourceID = HBDISC.ResourceId
												AND HBDISC.AgentName = 'Heartbeat Discovery'
LEFT JOIN v_AgentDiscoveries CLIREGDISC			on SYS.ResourceID = CLIREGDISC.ResourceId
												AND CLIREGDISC.AgentName = 'MP_ClientRegistration'
--WHERE 
--SYS.Obsolete0 = 0 and 
--Client0 = 0
--SYS.Netbios_Name0 LIKE 'DSILT0157'

WHERE --SYS.Client0 = 1 
                             SYS.Obsolete0 = 0 
                  --          AND HWSCAN.LastHWScan > @olddate 

GROUP BY
SYS.Netbios_Name0, 
SYS.Client0,SYS.Obsolete0,
SYS.Operating_System_Name_and0 , 
 	HWSCAN.LastHWScan, SWSCAN.LastScanDate , SWSCAN.LastCollectedFileScanDate, SUSCAN.LastScanTime,SUSCAN.LastScanState, stn.StateName,stn.TopicType

  
ORDER BY SYS.Netbios_Name0