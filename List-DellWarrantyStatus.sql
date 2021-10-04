SELECT     
v_GS_COMPUTER_SYSTEM.Name0 AS Name, 
DellWarrantyInformation.Service_Tag AS [Serial Number], 
DellWarrantyInformation.Build, DellWarrantyInformation.Region, 
DellWarrantyInformation.LOB AS [Line of Business], 
DellWarrantyInformation.System_Model AS [System Model], 
CONVERT(varchar,DellWarrantyInformation.Ship_Date, 101) AS [Dell Ship Date], 
DellWarrantyInformation.Service_Level_Code AS [Service Level Code], 
DellWarrantyInformation.Service_Level_Description AS [Service Level Description], 
DellWarrantyInformation.Provider, 
CONVERT(varchar, DellWarrantyInformation.Start_Date, 101) AS [Warranty Start Date], 
CONVERT(varchar, DellWarrantyInformation.End_Date, 101) AS [Warranty End Date], 
DellWarrantyInformation.Days_Left AS [Warranty Days Left], 
DellWarrantyInformation.Entitlement_Type, 
CONVERT(varchar, v_GS_WORKSTATION_STATUS.LastHWScan, 101) AS [Last Hardware Scan], 
v_GS_SYSTEM_CONSOLE_USAGE.TopConsoleUser0

FROM         DellWarrantyInformation 
	LEFT OUTER JOIN
                      v_GS_SYSTEM_ENCLOSURE ON DellWarrantyInformation.Service_Tag = v_GS_SYSTEM_ENCLOSURE.SerialNumber0 
	LEFT OUTER JOIN
                      v_GS_COMPUTER_SYSTEM ON v_GS_SYSTEM_ENCLOSURE.ResourceID = v_GS_COMPUTER_SYSTEM.ResourceID 
	LEFT OUTER JOIN
                      v_GS_WORKSTATION_STATUS ON v_GS_SYSTEM_ENCLOSURE.ResourceID = v_GS_WORKSTATION_STATUS.ResourceID 
	LEFT OUTER JOIN
                      v_GS_SYSTEM_CONSOLE_USAGE ON v_GS_SYSTEM_ENCLOSURE.ResourceID = v_GS_SYSTEM_CONSOLE_USAGE.ResourceID
		
WHERE  DellWarrantyInformation.Entitlement_Type IS NOT NULL
