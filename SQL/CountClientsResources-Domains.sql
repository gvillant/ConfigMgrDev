SELECT Resource_domain_OR_Workgr0 as ClientDomain, 
    count(distinct name0) as ClientCount 
FROM v_R_System 
    WHERE obsolete0=0 and Client0 = 1 --and Active0=1
GROUP BY Resource_domain_OR_Workgr0 
ORDER BY 1