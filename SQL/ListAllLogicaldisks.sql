/****** Script for SelectTopNRows command from SSMS  ******/
SELECT ldisk.ResourceID
	  ,SYS.Name0
      ,ldisk.Description0
      ,ldisk.DeviceID0
      ,ldisk.DriveType0
      ,ldisk.FileSystem0
      ,ldisk.FreeSpace0
      ,ldisk.Size0
      ,ldisk.Status0
      ,ldisk.SystemName0
      ,ldisk.VolumeName0
  FROM v_R_System SYS
  LEFT JOIN  v_GS_LOGICAL_DISK ldisk ON SYS.ResourceID = LDISK.ResourceID
  where ldisk.DriveType0 = 0 or ldisk.DriveType0 = 3
  order by sys.Name0, ldisk.DriveType0