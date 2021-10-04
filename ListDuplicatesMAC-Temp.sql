SELECT dbo.v_RA_System_MACAddresses.MAC_Addresses0, v_R_System.ResourceID,
Count(dbo.v_R_System.Name0) AS SystemCount 

FROM dbo.v_R_System 
RIGHT OUTER JOIN dbo.v_RA_System_MACAddresses ON dbo.v_R_System.ResourceID = dbo.v_RA_System_MACAddresses.ResourceID 

GROUP BY v_R_System.ResourceID ,dbo.v_RA_System_MACAddresses.MAC_Addresses0 
ORDER BY SystemCount DESC