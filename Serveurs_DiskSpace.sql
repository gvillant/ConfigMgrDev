SELECT DISTINCT 
                      dbo.v_GS_SYSTEM.Name0 AS [Nom de Machine], 
                      --v_GS_LOGICAL_DISK.FreeSpace0, v_GS_LOGICAL_DISK.DriveType0,v_GS_LOGICAL_DISK.Name0,v_GS_LOGICAL_DISK.Size0,v_GS_LOGICAL_DISK.VolumeName0,
                      SUM(v_GS_LOGICAL_DISK.Size0) as SUMSize, SUM(v_GS_LOGICAL_DISK.FreeSpace0) as SUMFreeSpace,   SUM(v_GS_LOGICAL_DISK.Size0) - SUM(v_GS_LOGICAL_DISK.FreeSpace0) as SUMUsedSpace,
                      dbo.v_GS_OPERATING_SYSTEM.Description0 AS Description, 
                      dbo.v_GS_OPERATING_SYSTEM.Caption0 AS [Type de Système Exploitation], REPLACE(REPLACE(REPLACE(dbo.v_R_System.AD_Site_Name0, 
                      'Default-First-Site-Name', 'Télécity'), '7800-Clairefontaine', 'Clairefontaine'), 'FFF', 'Grenelle') AS [Site Géogr.], CONVERT(VARCHAR(10), 
                      dbo.v_GS_OPERATING_SYSTEM.InstallDate0, 120) AS [Date Installation], dbo.v_GS_OPERATING_SYSTEM.TotalVisibleMemorySize0 AS Mémoire, 
                      dbo.v_GS_COMPUTER_SYSTEM.Model0 AS [Type de Machine], ISNULL(dbo.v_GS_OPERATING_SYSTEM.CSDVersion0, 'RTM') AS [Service Pack], 
                      CONVERT(VARCHAR(16), dbo.v_GS_OPERATING_SYSTEM.LastBootUpTime0, 120) AS [Last Reboot], CONVERT(VARCHAR(10), dbo.v_GS_PC_BIOS.ReleaseDate0, 120) 
                      AS [Date de la carte Mère], CONVERT(VARCHAR(10), dbo.v_GS_WORKSTATION_STATUS.LastHWScan, 120) AS [Dernier Inventaire], 
                      dbo.v_GS_PROCESSOR.Name0 AS Processeur, REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(dbo.v_GS_VIRTUAL_MACHINE_64.PhysicalHostName0, 
                      'HYPERV Télécity'), '0000SVIR01', 'VM-HyperV Grenelle'), '0000SVIR02', 'VM-HyperV Grenelle'), '7800SVIR01', 'VM-HyperV Clairefontaine'), '2700SVIR01', 
                      'VM-HyperV Corse'), '9900SVIR01', 'Développement') AS [Type d'Hôte], COUNT(dbo.v_GS_PROCESSOR.Name0) AS [Nb Processeur], 
                      dbo.v_GS_PC_BIOS.SerialNumber0 AS [Serial Number], vFFF.PublicProfileFirewall0 AS FWPublicProfile, vFFF.StandardProfileFirewall0 AS FWStandardProfile, 
                      vFFF.DomainProfileFirewall0 AS FWDomainProfile, vFFF.BackupDB0 AS SUPBackupDB, vFFF.BackupSYS0 AS SUPBackupSYS, vFFF.ExploitDB0 AS SUPExploitDB, 
                      vFFF.ExploitSYS0 AS SUPExploitSYS, vFFF.WarrantyEndDate0 AS SUPWarrantyEndDate, vFFF.WarrantyHW0 AS SUPWarrantyHW, 
                      vFFF.WarrantySLA0 AS SUPWarrantySLA, dbo.v_GS_SYSTEM.ResourceID
FROM         dbo.v_GS_SYSTEM INNER JOIN
                      dbo.v_GS_OPERATING_SYSTEM ON dbo.v_GS_SYSTEM.ResourceID = dbo.v_GS_OPERATING_SYSTEM.ResourceID INNER JOIN
                      dbo.v_GS_WORKSTATION_STATUS ON dbo.v_GS_SYSTEM.ResourceID = dbo.v_GS_WORKSTATION_STATUS.ResourceID INNER JOIN
                      dbo.v_GS_VIRTUAL_MACHINE_64 ON dbo.v_GS_SYSTEM.ResourceID = dbo.v_GS_VIRTUAL_MACHINE_64.ResourceID INNER JOIN
                      dbo.v_GS_COMPUTER_SYSTEM ON dbo.v_GS_SYSTEM.ResourceID = dbo.v_GS_COMPUTER_SYSTEM.ResourceID INNER JOIN
                      dbo.v_GS_PC_BIOS ON dbo.v_GS_SYSTEM.ResourceID = dbo.v_GS_PC_BIOS.ResourceID INNER JOIN
                      dbo.v_R_System ON dbo.v_GS_SYSTEM.ResourceID = dbo.v_R_System.ResourceID INNER JOIN
                      dbo.v_GS_PROCESSOR ON dbo.v_GS_SYSTEM.ResourceID = dbo.v_GS_PROCESSOR.ResourceID INNER JOIN
                      dbo.v_GS_LOGICAL_DISK ON dbo.v_GS_SYSTEM.ResourceID = dbo.v_GS_LOGICAL_DISK.ResourceID LEFT OUTER JOIN
                      dbo.v_GS_FFF0 AS vFFF ON dbo.v_GS_SYSTEM.ResourceID = vFFF.ResourceID
WHERE     (dbo.v_GS_SYSTEM.SystemRole0 LIKE 'server')
GROUP BY dbo.v_GS_SYSTEM.Name0, dbo.v_GS_OPERATING_SYSTEM.Description0, dbo.v_GS_OPERATING_SYSTEM.Caption0, 
                      dbo.v_GS_OPERATING_SYSTEM.CSDVersion0, dbo.v_R_System.AD_Site_Name0, dbo.v_GS_OPERATING_SYSTEM.InstallDate0, 
                      dbo.v_GS_OPERATING_SYSTEM.TotalVisibleMemorySize0, dbo.v_GS_COMPUTER_SYSTEM.Model0, dbo.v_GS_OPERATING_SYSTEM.CSDVersion0, 
                      dbo.v_GS_PC_BIOS.ReleaseDate0, dbo.v_GS_VIRTUAL_MACHINE_64.PhysicalHostName0, dbo.v_GS_PROCESSOR.Name0, 
                      dbo.v_GS_OPERATING_SYSTEM.LastBootUpTime0, dbo.v_GS_WORKSTATION_STATUS.LastHWScan, dbo.v_GS_PC_BIOS.SerialNumber0, 
                      vFFF.PublicProfileFirewall0, vFFF.StandardProfileFirewall0, vFFF.DomainProfileFirewall0, vFFF.BackupDB0, vFFF.BackupSYS0, vFFF.ExploitDB0, vFFF.ExploitSYS0, 
                      vFFF.WarrantyEndDate0, vFFF.WarrantyHW0, vFFF.WarrantySLA0, dbo.v_GS_SYSTEM.ResourceID
                      --, v_GS_LOGICAL_DISK.FreeSpace0, v_GS_LOGICAL_DISK.DriveType0,v_GS_LOGICAL_DISK.Name0,v_GS_LOGICAL_DISK.Size0,v_GS_LOGICAL_DISK.VolumeName0