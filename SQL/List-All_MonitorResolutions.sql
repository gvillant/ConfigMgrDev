select SYS.Name0, 
MON.Name0, 
MON.MonitorManufacturer0, 
MON.ScreenHeight0, 
MON.ScreenWidth0 
from  v_R_System SYS
inner join v_GS_DESKTOP_MONITOR MON on MON.ResourceID = SYS.ResourceId 
where MON.DeviceID0 = 'DesktopMonitor1' 
or MON.DeviceID0 = 'DesktopMonitor2' 
or MON.DeviceID0 = 'DesktopMonitor3' 
or MON.DeviceID0 = 'DesktopMonitor4' 
order by SYS.Name0
