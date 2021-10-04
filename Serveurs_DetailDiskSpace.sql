SELECT                v_GS_SYSTEM.Name0 AS [Nom de Machine], 
                      --SUM(v_GS_LOGICAL_DISK.Size0) as SUMDiskSize,
                      v_GS_LOGICAL_DISK.Name0,
                      v_GS_LOGICAL_DISK.Size0,
                      v_GS_LOGICAL_DISK.FreeSpace0,
                      v_GS_LOGICAL_DISK.Size0 - v_GS_LOGICAL_DISK.FreeSpace0 as UsedSpace
                      --SUM(v_GS_LOGICAL_DISK.Size0) - v_GS_LOGICAL_DISK.FreeSpace0 as UsedSpace
                                            
FROM         v_GS_SYSTEM INNER JOIN
                      dbo.v_GS_LOGICAL_DISK ON v_GS_SYSTEM.ResourceID = v_GS_LOGICAL_DISK.ResourceID 
WHERE     (v_GS_SYSTEM.SystemRole0 LIKE 'server') and v_GS_LOGICAL_DISK.VolumeName0 IS NOT NULL

--GROUP BY v_GS_SYSTEM.Name0,v_GS_LOGICAL_DISK.FreeSpace0

order by usedSpace desc
