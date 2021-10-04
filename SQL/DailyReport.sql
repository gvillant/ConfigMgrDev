DECLARE @Lots nvarchar(max) = '140130'

SELECT 
 COL.Name as C064,
 PKG.Name AS TaskSequenceName, 
 adv.PresentTime as Deadline,
 adv.ExpirationTime as ExpirationTime,
 
  SUM(CASE WHEN stat.LastState NOT IN (9,11,13) THEN 1 ELSE 0 END) as Pending, 
  ROUND(100*SUM(CASE WHEN stat.LastState NOT IN (9,11,13) THEN 1 ELSE 0 END)/COUNT(*),1) as 
 
PercentPending, 
  SUM(CASE WHEN stat.LastState=9 THEN 1 ELSE 0 END) as Running, 
  ROUND(100*SUM(CASE WHEN stat.LastState=9 THEN 1 ELSE 0 END)/COUNT(*), 1) as 
 
PercentRunning, 
  SUM(CASE WHEN stat.LastState=13 THEN 1 ELSE 0 END) as C008, 
  ROUND(100*SUM(CASE WHEN stat.LastState=13 THEN 1 ELSE 0 END)/COUNT(*), 1) as C009, 
  SUM(CASE WHEN stat.LastState=11 THEN 1 ELSE 0 END) as C010, 
  ROUND(100*SUM(CASE WHEN stat.LastState=11 THEN 1 ELSE 0 END)/COUNT(*), 1) as C011 ,
 
 CASE WHEN AssignedScheduleEnabled != 0 OR (AdvertFlags & 0x720) != 0 
  THEN 1 
  ELSE 0 
 END AS C063,
 CASE 
  WHEN ((AdvertFlags & 0x20000000) != 0)
    THEN 0 
  WHEN ((AdvertFlags & 0x10000000) != 0)
    THEN 1
  WHEN ((AdvertFlags & 0x00040000) != 0) 
    THEN 2  
    ELSE 3 
  END AS TsAssignedAs, 
 adv.AdvertisementID 

FROM v_Advertisement ADV
LEFT JOIN v_Package PKG ON ADV.PackageID = PKG.PackageID 
LEFT JOIN v_Collection COL ON ADV.CollectionID = COL.CollectionID 

LEFT JOIN v_TaskSequencePackage TS ON ADV.PackageID = TS.PackageID 
LEFT JOIN v_ClientAdvertisementStatus  STAT on ADV.AdvertisementID = STAT.AdvertisementID 
LEFT JOIN v_CurrentAdvertisementAssignments ASSG ON 
 stat.AdvertisementID=assg.AdvertisementID and stat.ResourceID=assg.ResourceID 
 
WHERE PKG.ImageFlags = 0x4 and COL.Name like @Lots + '%'
GROUP BY stat.AdvertisementID, adv.AdvertisementName , COL.Name, PKG.Name ,adv.ExpirationTime ,adv.PresentTime, 
AssignedScheduleEnabled,AdvertFlags, ADV.AdvertisementID
ORDER BY COL.Name, ADV.AdvertisementName



