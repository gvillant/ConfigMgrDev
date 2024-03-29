SELECT  SYS.NAME0
		,WARMAX.Service_Tag
		,BIOS.SerialNumber0
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
  LEFT JOIN v_GS_PC_BIOS BIOS on BIOS.ResourceID = SYS.ResourceID
  LEFT JOIN (
			SELECT Service_Tag
			,MAX(End_Date) as EndDate
			FROM DellWarrantyInformation
			WHERE Service_Level_Code <> 'D'
			GROUP BY Service_Tag
			) WARMAX ON BIOS.SerialNumber0 = WARMAX.Service_Tag
	LEFT JOIN DellWarrantyInformation WAR on (WARMAX.Service_Tag = BIOS.SerialNumber0 and WARMAX.EndDate = WAR.End_Date and SYS.ResourceID = BIOS.ResourceID)
	    
  --LEFT JOIN DellWarrantyInformation WAR on BIOS.SerialNumber0 = WAR.Service_Tag
  WHERE SYS.Name0 = 'FRS02547' 
  