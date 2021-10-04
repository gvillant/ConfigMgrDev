
SELECT  SYS.NAME0
		,WARMAX.Service_Tag
      ,WAR.System_Id
      ,WAR.Build
      ,WAR.Region
      ,WAR.LOB
      ,WAR.System_Model
      ,WAR.Ship_Date
      ,WAR.Service_Level_Code
      ,WAR.Service_Level_Description
      ,WAR.Provider
      ,WAR.Start_Date
      ,WAR.End_Date as EndDate
      ,WAR.Days_Left
      ,WAR.Entitlement_Type
  
  FROM v_R_System SYS
  LEFT JOIN (
			SELECT SYS.Name0 as Name, sys.ResourceID
			,WAR.Service_Tag
			,MAX(WAR.End_Date) as EndDate
			FROM DellWarrantyInformation WAR
			LEFT JOIN v_GS_PC_BIOS BIOS on BIOS.SerialNumber0 = WAR.Service_Tag
			LEFT JOIN v_R_System SYS on BIOS.ResourceID = SYS.ResourceID
			WHERE Service_Level_Code <> 'D' and BIOS.ResourceID is not null and SYS.ResourceID IS NOT NULL
			GROUP BY SYS.Name0, SYS.ResourceID, BIOS.resourceID, WAR.Service_Tag
			) WARMAX ON SYS.ResourceID = WARMAX.ResourceID
	LEFT JOIN DellWarrantyInformation WAR on (WARMAX.Service_Tag = WAR.Service_Tag and WARMAX.EndDate = WAR.End_Date)
	    
  --LEFT JOIN DellWarrantyInformation WAR on BIOS.SerialNumber0 = WAR.Service_Tag
  --WHERE SYS.Name0 = 'FRS02547' 
  ORDER BY SYS.Name0
  


