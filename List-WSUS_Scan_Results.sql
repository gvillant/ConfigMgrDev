/*
List last WSUS Scan Status 
*/

DECLARE @ScanDate datetime 
SET @ScanDate=DATEADD(DAY,-2, GETUTCDATE()) --Last 2 hours

DECLARE @ActiveTime datetime 
SET @ActiveTime=DATEADD(DAY,-1, GETUTCDATE()) --Last 1 days 


select SYS.Name0 as ComputerName, SYS.Operating_System_Name_and0 as OS,
DATEADD(hh,DATEDIFF(hh,GETUTCDATE(),GETDATE()),CS.LastActiveTime) as LastActiveTime,
DATEADD(hh,DATEDIFF(hh,GETUTCDATE(),GETDATE()),OPSYS.LastBootUpTime0) as LastBoot,
DATEADD(hh,DATEDIFF(hh,GETUTCDATE(),GETDATE()),USS.ScanTime) as LastSuccessfullScan, 
DATEADD(hh,DATEDIFF(hh,GETUTCDATE(),GETDATE()),LastScanTime) as LastScanTime,
USS.ScanPackageVersion,
USS.LastScanState,
CASE USS.LastScanState
WHEN 0	THEN 'Scan state unknown'
WHEN 1	THEN 'Scan is waiting for catalog location'
WHEN 2	THEN 'Scan is running'
WHEN 3	THEN 'Scan completed'
WHEN 4	THEN 'Scan is pending retry'
WHEN 5	THEN 'Scan failed'
WHEN 6	THEN 'Scan completed with errors'
END as LastScanState2,

USS.LastErrorCode,
CASE USS.LastErrorCode
WHEN '-2147012890' THEN ''
WHEN '-2145107925' THEN 'The HTTP request could not be completed and the reason did not correspond to any of the WU_E_PT_HTTP_* error codes.'
WHEN '-2147467259' THEN 'Erreur non spécifiée'
WHEN '-2016410110' THEN 'Content location request timeout occurred'
WHEN '-2145123271' THEN 'Error not found'
WHEN '-2145107934' THEN 'Same as HTTP status 503 - the service is temporarily overloaded.'
WHEN '-2016410107' THEN 'Scan tool has been removed'
WHEN '-939523567' THEN ''
WHEN '-2147023890' THEN ''
WHEN '-2145124321' THEN 'Operation did not complete because the network connection was unavailable.'
WHEN '-2145124338' THEN ''
WHEN '-2147023838' THEN 'Le service ne peut pas être démarré parce qu’il est désactivé ou qu’aucun périphérique activé ne lui est associé.'
WHEN '-2016409966' THEN 'Group policy conflict'
WHEN '-2145107944' THEN 'Same as HTTP status 403 - server understood the request, but declined to fulfill it.'
WHEN '-2145107958' THEN 'Same as SOAPCLIENT_PARSE_ERROR - SOAP client failed to parse the response from the server.'
WHEN '-2147012866' THEN 'La connexion avec le serveur a été interrompue anormalement'
WHEN '-2145107924' THEN 'Same as ERROR_WINHTTP_NAME_NOT_RESOLVED - the proxy server or target server name cannot be resolved.'
WHEN '-2145107941' THEN ''
WHEN '-2147012894' THEN 'Le délai imparti à l’opération est dépassé'
WHEN '-2147024882' THEN 'Not enough storage is available to complete this operation.'
WHEN '-2145075194' THEN 'Driver synchronization failed.'
WHEN '-2145107952' THEN 'The number of round trips to the server exceeded the maximum limit.'
WHEN '-2145124322' THEN 'Operation did not complete because the service or system was being shut down.'
WHEN '-2145107943' THEN 'Same as HTTP status 404 - the server cannot find the requested URI (Uniform Resource Identifier).'
WHEN '-2147024883' THEN 'The data is invalid.'
WHEN '-2145120257' THEN 'An operation failed due to reasons not covered by another error code.'

END as Error,
LastScanPackageLocation


from v_R_System SYS
LEFT JOIN v_updateScanStatus USS on SYS.ResourceID = USS.ResourceID
LEFT JOIN v_CH_ClientSummary CS on SYS.ResourceID = CS.ResourceID
LEFT JOIN v_GS_COMPUTER_SYSTEM CSYS on SYS.ResourceID = CSYS.ResourceID
LEFT JOIN v_GS_OPERATING_SYSTEM OPSYS on SYS.ResourceID = OPSYS.ResourceID
LEFT JOIN BGB_ResStatus BRS on SYS.ResourceID = BRS.ResourceID

where 
LastScanState <> 3 
--and LastScanTime > @ScanDate
--and CS.LastActiveTime > @ActiveTime
--and ScanTime > @ScanDate 
--and 
--SYS.Name0 like '%CHB08%'
AND BRS.OnlineStatus = 1

order by LastScanPackageLocation, LastScanTime
