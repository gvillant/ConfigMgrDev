

select SYS.ResourceID, sys.Netbios_Name0, SWSCAN.LastScanDate, SYS.Operating_System_Name_and0, STA.Version0

From v_R_System_Valid SYS
LEFT JOIN v_GS_LastSoftwareScan  SWSCAN		on SYS.ResourceID = SWSCAN.ResourceID 
LEFT JOIN v_GS_WORKSTATION_STATUS  HWSCAN	on SYS.ResourceID = HWSCAN.ResourceID 
LEFT JOIN v_GS_STAGO_OS_Deployment0 STA on SYS.ResourceID = STA.ResourceID
	where sys.ResourceID not in (
				select SYS.ResourceID
				From v_R_System_Valid SYS
				LEFT JOIN v_GS_SoftwareFile SF on SYS.ResourceID = SF.ResourceID
				where SF.FileName ='outlook.exe' and SF.FilePath = 'C:\Program Files (x86)\Microsoft Office\Office15\')
			AND SYS.Operating_System_Name_and0 like '%6.1%'
			AND STA.Version0 not like '04.%'
			AND SWSCAN.LastScanDate IS NOT NULL

order by STA.Version0, Netbios_Name0
