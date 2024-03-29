SELECT sys.Resource_Domain_OR_Workgr0 as Domain
      ,MAX (BDY.DisplayName) as Location
      ,Operating_System_Name_and0 as OSFull
      ,count (distinct sys.resourceID)as Count 
  FROM [v_R_System] SYS
  LEFT join v_RA_System_IPAddresses IP on IP.ResourceID = SYS.ResourceID
  LEFT join v_RA_System_IPSubnets SUB on SUB.ResourceID = SYS.ResourceID
  LEFT join vSMS_Boundary BDY on SUB.IP_Subnets0 =BDY.Value
  WHERE  sys.Resource_Domain_OR_Workgr0 <> 'STAGO' and  Operating_System_Name_and0 like '%Work%' and sys.Obsolete0 = 0
  GROUP BY sys.Resource_Domain_OR_Workgr0 ,[Operating_System_Name_and0] 
  Order by Domain, Location, OSFull
