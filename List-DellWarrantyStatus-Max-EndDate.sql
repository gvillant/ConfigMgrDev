
SELECT SYS.Name0 as Name, sys.ResourceID
		,WAR.Service_Tag
      ,MAX(WAR.End_Date) as EndDate, war.System_Id
  FROM DellWarrantyInformation WAR
  LEFT JOIN v_GS_PC_BIOS BIOS on BIOS.SerialNumber0 = WAR.Service_Tag
  LEFT JOIN v_R_System SYS on BIOS.ResourceID = SYS.ResourceID
  WHERE Service_Level_Code <> 'D' and BIOS.ResourceID is not null
  
  GROUP BY SYS.Name0, SYS.ResourceID, BIOS.resourceID, WAR.Service_Tag,WAR.
  ORDER BY BIOS.ResourceID, Service_Tag
  