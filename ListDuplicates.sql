
/*SELECT SYS.ResourceID, SYS.Name0,
SYS.Virtual_Machine_Host_Name0 as Host
FROM v_R_System SYS
WHERE SYS.Virtual_Machine_Host_Name0 = '6205SVIR01'
*/

/*
----------FIND MULTI VMs Hyper-V Host--------------
SELECT DISTINCT SYS.ResourceID, SYS.Name0,
SYS.Virtual_Machine_Host_Name0 as Host

FROM v_R_System SYS
INNER join v_R_System SYS2 on SYS.Virtual_Machine_Host_Name0 = SYS2.Virtual_Machine_Host_Name0
WHERE SYS.ResourceID <> SYS2.ResourceID AND SYS.Virtual_Machine_Host_Name0 <> ''

ORDER BY SYS.Virtual_Machine_Host_Name0,SYS.ResourceID

*/


----------FIND Duplicate MAC Addresses--------------
SELECT DISTINCT SYS.ResourceID, SYS.Name0 as Duplicate_Name,
SYS.Hardware_ID0 as HardwareID, 
SYS.SMS_Unique_Identifier0 AS SMSUniqueIdentifier, 
SYS.Client0 as IsClient,
SYS.Creation_Date0 as CreationDate
FROM v_R_System SYS
INNER join v_R_System SYS2 on SYS.Name0 = SYS2.Name0
WHERE SYS.ResourceID <> SYS2.ResourceID AND SYS.Name0 <> ''
ORDER BY SYS.Name0,SYS.ResourceID



----------FIND Duplicate Hardware IDs--------------
SELECT DISTINCT SYS.ResourceID, SYS.Name0 as Name,
SYS.Hardware_ID0 as Duplicate_HardwareID, 
SYS.SMS_Unique_Identifier0 AS SMSUniqueIdentifier, 
SYS.Client0 as IsClient,
SYS.Creation_Date0 as CreationDate
FROM v_R_System SYS
INNER join v_R_System SYS2 on SYS.Hardware_ID0 = SYS2.Hardware_ID0
WHERE SYS.ResourceID <> SYS2.ResourceID AND SYS.Hardware_ID0 <> ''
ORDER BY SYS.Hardware_ID0,SYS.ResourceID

----------FIND Duplicate SMS_Unique_Identifier--------------
SELECT DISTINCT SYS.ResourceID, SYS.Name0 as Name,
SYS.Hardware_ID0 as HardwareID, 
SYS.SMS_Unique_Identifier0 AS Duplicate_SMSUniqueIdentifier, 
SYS.Client0 as IsClient,
SYS.Creation_Date0 as CreationDate
FROM v_R_System SYS
INNER join v_R_System SYS2 on SYS.SMS_Unique_Identifier0 = SYS2.SMS_Unique_Identifier0
WHERE SYS.ResourceID <> SYS2.ResourceID AND SYS.SMS_Unique_Identifier0 <> ''
ORDER BY SYS.SMS_Unique_Identifier0,SYS.ResourceID

----------FIND Duplicate Resource Names--------------
SELECT DISTINCT SYS.ResourceID, SYS.Name0 as Duplicate_Name,
SYS.Hardware_ID0 as HardwareID, 
SYS.SMS_Unique_Identifier0 AS SMSUniqueIdentifier, 
SYS.Client0 as IsClient,
SYS.Creation_Date0 as CreationDate
FROM v_R_System SYS
INNER join v_R_System SYS2 on SYS.Name0 = SYS2.Name0
WHERE SYS.ResourceID <> SYS2.ResourceID AND SYS.Name0 <> ''
ORDER BY SYS.Name0,SYS.ResourceID


