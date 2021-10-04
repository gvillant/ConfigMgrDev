Select sys.Name0 as 'Computer Name', SYS.ResourceID, CSYS.Model0 as Model
,Name as 'Task Sequence'
,DATEADD(hour,2,ExecutionTime)
,Step
,ActionName
,GroupName
,tes.LastStatusMsgName
,ExitCode
,case ExitCode 
When -2016409853 then 'Another software updates install job is in progress. Only one job is allowed at a time.'
When -2147023436 then 'This operation returned because the timeout period expired.'
When -2147012894 then 'The operation timed out.'
When -2145107952 then 'The number of round trips to the server exceeded the maximum limit.'
When -2147467259 then 'Unspecified error'
When -2147024890 then 'The handle is invalid.'
When -2145107944 then 'Same as HTTP status 403 - server understood the request, but declined to fulfill it.'
When -2147024894 Then 'The system cannot find the file specified.'
When -2147023293 Then 'Fatal error during installation.'
When -2016403452 Then 'The software distribution policy was not found.'
When 1 Then 'Incorrect function.'
When 2 Then 'The system cannot find the file specified.'
end as detail

,ActionOutput
 
from vSMS_TaskSequenceExecutionStatus tes
LEFT join v_R_System sys on tes.ResourceID = sys.ResourceID
LEFT join v_TaskSequencePackage tsp on tes.PackageID = tsp.PackageID
LEFT JOIN v_GS_COMPUTER_SYSTEM CSYS on CSYS.ResourceID = SYS.ResourceID
--where 
where  
DATEDIFF(HOUR,ExecutionTime,GETDATE()) < 72 -- AND ExitCode <> 0 and GroupName not like '%Install SU%' --=-2016403452 --
--and sys.ResourceID = 16784156
--and LastStatusMsgName not like '%skipped%'
--and ActionName like '%BitLocker%'
--and ActionName = 'Pre-provision BitLocker'
--and SYS.Name0 like '%2009%' -- 'FRS02009'
--AND tsp.Name in ('W7x64-03.10.01')
 --AND tsp.Name like ('W10%')
--and LastStatusMsgName like '%The task sequence execution engine successfully completed an action%'
--and Step = 742
ORDER BY sys.Name0,ExecutionTime DESC , 2, tes.Step DESC
