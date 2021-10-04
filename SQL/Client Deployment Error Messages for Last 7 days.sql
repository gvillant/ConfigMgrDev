select Top 10 StateDescription, 
    LastMessageStateID, count(*) 'ClientsCount' 
from v_ClientDeploymentState 
where LastMessageStateID not in ('400','700','100','500') 
    and DeploymentBeginTime >DATEADD(day,-30, getdate()) 
group by StateDescription, LastMessageStateID 
order by 3 desc