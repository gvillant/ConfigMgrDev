SELECT  DISTINCT Name,MAX(ip.IP_Addresses0) ,[LastErrorCode],
CASE LastErrorCode 
WHEN '-2147023174' THEN 'WMI'
WHEN '1305' THEN 'XP SP2'
WHEN '120' THEN 'ALREADY CLIENT'
WHEN '53' THEN 'NETWORK'
END AS 'ErrorDescription'


      ,[PushSiteCode]
      ,[AssignedSiteCode]
      ,[InitialRequestDate]
      ,[Description]
      ,[NumProcessAttempts]
      ,[ErrorEventCreated]
      ,[Status]
  FROM v_CP_Machine
  left join v_RA_System_IPAddresses IP on v_CP_Machine.MachineID = IP.ResourceID
  --where LastErrorCode = 1305
    where Status <> 0 and Status <> 4
  GROUP BY NAme,[LastErrorCode],[PushSiteCode]
      ,[AssignedSiteCode]
      ,[InitialRequestDate]
      ,[Description]
      ,[NumProcessAttempts]
      ,[ErrorEventCreated]
      ,[Status]
  ORDER BY Name