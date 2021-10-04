select SYS.Name0, DISK.Model0, DISK.Size0, CS.Model0, SYS.operatingSystem0, BIOS.SerialNumber0, OS.Version0
from v_R_System SYS
LEFT JOIN  v_gs_disk DISK ON SYS.ResourceID = DISK.ResourceID
LEFT JOIN v_GS_COMPUTER_SYSTEM CS ON SYS.ResourceID = CS.ResourceID
LEFT JOIN v_GS_PC_BIOS BIOS ON SYS.ResourceID = BIOS.ResourceID
LEFT JOIN v_GS_OPERATING_SYSTEM OS ON SYS.ResourceID = OS.ResourceID

WHERE DISK.Model0 like '%KSG60Z%'
ORDER BY 4