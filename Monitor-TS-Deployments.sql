Select Name0 as 'Computer Name',sys.ResourceID
,Name as 'Task Sequence'
,dateadd(HOUR,1, ExecutionTime)
,Step
,ActionName
,GroupName
,tes.LastStatusMsgName
,ExitCode
,ActionOutput
 
from vSMS_TaskSequenceExecutionStatus tes
inner join v_R_System sys on tes.ResourceID = sys.ResourceID
inner join v_TaskSequencePackage tsp on tes.PackageID = tsp.PackageID
where 
--tsp.Name in ('Windows OS Deployment x64', 'Windows OS Deployment x86')
--and 
DATEDIFF(hour,ExecutionTime,GETDATE()) < 8
ORDER BY 2 desc,4 desc,Step Desc