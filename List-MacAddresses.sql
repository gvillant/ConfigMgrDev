

SELECT SYS.ResourceID, SYS.Name0, MAC.MAC_Addresses0
FROM v_R_System SYS
LEFT JOIN dbo.v_RA_System_MACAddresses MAC on SYS.ResourceID = MAC.ResourceID
--WHERE SYS.Virtual_Machine_Host_Name0 = '6205SVIR01'

