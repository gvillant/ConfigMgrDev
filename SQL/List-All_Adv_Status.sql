SELECT 
  stat.AdvertisementID, 
  adv.AdvertisementName, 
  COUNT(*) as Total0, 
  SUM(CASE WHEN stat.LastState NOT IN (9,11,13) THEN 1 ELSE 0 END) as Pending, 
  ROUND(100*SUM(CASE WHEN stat.LastState NOT IN (9,11,13) THEN 1 ELSE 0 END)/COUNT(*),1) as 
 
PercentPending, 
  SUM(CASE WHEN stat.LastState=9 THEN 1 ELSE 0 END) as Running, 
  ROUND(100*SUM(CASE WHEN stat.LastState=9 THEN 1 ELSE 0 END)/COUNT(*), 1) as 
 
PercentRunning, 
  SUM(CASE WHEN stat.LastState=13 THEN 1 ELSE 0 END) as C008, 
  ROUND(100*SUM(CASE WHEN stat.LastState=13 THEN 1 ELSE 0 END)/COUNT(*), 1) as C009, 
  SUM(CASE WHEN stat.LastState=11 THEN 1 ELSE 0 END) as C010, 
  ROUND(100*SUM(CASE WHEN stat.LastState=11 THEN 1 ELSE 0 END)/COUNT(*), 1) as C011 
FROM v_ClientAdvertisementStatus  stat 
JOIN v_Advertisement  adv ON adv.AdvertisementID=stat.AdvertisementID 
JOIN v_TaskSequencePackage  ts ON adv.PackageID=ts.PackageID 
LEFT JOIN v_CurrentAdvertisementAssignments  assg ON 
 stat.AdvertisementID=assg.AdvertisementID and stat.ResourceID=assg.ResourceID 
 
WHERE stat.LastState in (8,9,10,11,12,13) or assg.ResourceID is not NULL 
GROUP BY stat.AdvertisementID, adv.AdvertisementName 
ORDER BY stat.AdvertisementID

