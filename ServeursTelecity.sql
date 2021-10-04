SELECT DISTINCT       dbo.v_GS_SYSTEM.Name0 AS [Nom de Machine], dbo.v_GS_OPERATING_SYSTEM.Description0 AS Description, 
                      dbo.v_GS_OPERATING_SYSTEM.Caption0 AS [Type de Système Exploitation], REPLACE(REPLACE(REPLACE(dbo.v_R_System.AD_Site_Name0, 
                      'Default-First-Site-Name', 'Télécity'), '7800-Clairefontaine', 'Clairefontaine'), 'FFF', 'Grenelle') AS [Site Géogr.], CONVERT(VARCHAR(10), 
                      dbo.v_GS_OPERATING_SYSTEM.InstallDate0, 120) AS [Date Installation], dbo.v_GS_OPERATING_SYSTEM.TotalVisibleMemorySize0 AS Mémoire, 
                      dbo.v_GS_COMPUTER_SYSTEM.Model0 AS [Type de Machine], ISNULL(dbo.v_GS_OPERATING_SYSTEM.CSDVersion0, 'RTM') AS [Service Pack], 
                      CONVERT(VARCHAR(16), dbo.v_GS_OPERATING_SYSTEM.LastBootUpTime0, 120) AS [Last Reboot], CONVERT(VARCHAR(10), dbo.v_GS_PC_BIOS.ReleaseDate0, 120) 
                      AS [Date de la carte Mère], CONVERT(VARCHAR(10), dbo.v_GS_WORKSTATION_STATUS.LastHWScan, 120) AS [Dernier Inventaire], 
                      dbo.v_GS_PROCESSOR.Name0 AS Processeur, REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(dbo.v_GS_VIRTUAL_MACHINE_64.PhysicalHostName0, 'HYPERV Télécity'), 
                      '0000SVIR01', 'VM-HyperV Grenelle'), '0000SVIR02', 'VM-HyperV Grenelle'), '7800SVIR01', 'VM-HyperV Clairefontaine'),'2700SVIR01', 'VM-HyperV Corse'),'9900SVIR01', 'Développement') AS [Type d'Hôte], COUNT(dbo.v_GS_PROCESSOR.Name0) 
                      AS [Nb Processeur], dbo.v_GS_PC_BIOS.SerialNumber0 as [Serial Number], vFFF.PublicProfileFirewall0 as [FWPublicProfile], vFFF.StandardProfileFirewall0 as [FWStandardProfile], vFFF.DomainProfileFirewall0 as [FWDomainProfile]
					,vFFF.BackupDB0 AS [SUPBackupDB] ,vFFF.BackupSYS0 AS [SUPBackupSYS] ,vFFF.ExploitDB0 AS [SUPExploitDB] ,vFFF.ExploitSYS0 AS [SUPExploitSYS],vFFF.WarrantyEndDate0 AS [SUPWarrantyEndDate],vFFF.WarrantyHW0 AS [SUPWarrantyHW],vFFF.WarrantySLA0 AS [SUPWarrantySLA]
				FROM dbo.v_GS_SYSTEM 
					INNER JOIN dbo.v_GS_OPERATING_SYSTEM ON dbo.v_GS_SYSTEM.ResourceID = dbo.v_GS_OPERATING_SYSTEM.ResourceID 
					INNER JOIN dbo.v_GS_WORKSTATION_STATUS ON dbo.v_GS_SYSTEM.ResourceID = dbo.v_GS_WORKSTATION_STATUS.ResourceID 
                    INNER JOIN dbo.v_GS_VIRTUAL_MACHINE_64 ON dbo.v_GS_SYSTEM.ResourceID = dbo.v_GS_VIRTUAL_MACHINE_64.ResourceID 
                    INNER JOIN dbo.v_GS_COMPUTER_SYSTEM ON dbo.v_GS_SYSTEM.ResourceID = dbo.v_GS_COMPUTER_SYSTEM.ResourceID 
                    INNER JOIN dbo.v_GS_PC_BIOS ON dbo.v_GS_SYSTEM.ResourceID = dbo.v_GS_PC_BIOS.ResourceID 
                    INNER JOIN dbo.v_R_System ON dbo.v_GS_SYSTEM.ResourceID = dbo.v_R_System.ResourceID 
                    INNER JOIN dbo.v_GS_PROCESSOR ON dbo.v_GS_SYSTEM.ResourceID = dbo.v_GS_PROCESSOR.ResourceID
                    LEFT JOIN dbo.v_GS_FFF0 vFFF on dbo.v_GS_SYSTEM.ResourceID = vFFF.ResourceID

				WHERE (dbo.v_GS_SYSTEM.SystemRole0 LIKE 'server') AND (dbo.v_GS_COMPUTER_SYSTEM.Model0 LIKE '%VMware%')  and (dbo.v_GS_SYSTEM.Name0 like 'FFF%')

				GROUP BY dbo.v_GS_SYSTEM.Name0, dbo.v_GS_OPERATING_SYSTEM.Description0, dbo.v_GS_OPERATING_SYSTEM.Caption0, 
                      dbo.v_GS_OPERATING_SYSTEM.CSDVersion0, dbo.v_R_System.AD_Site_Name0, 
                      dbo.v_GS_OPERATING_SYSTEM.InstallDate0, dbo.v_GS_OPERATING_SYSTEM.TotalVisibleMemorySize0, dbo.v_GS_COMPUTER_SYSTEM.Model0, 
                      dbo.v_GS_OPERATING_SYSTEM.CSDVersion0, dbo.v_GS_PC_BIOS.ReleaseDate0, dbo.v_GS_VIRTUAL_MACHINE_64.PhysicalHostName0, 
                      dbo.v_GS_PROCESSOR.Name0, dbo.v_GS_OPERATING_SYSTEM.LastBootUpTime0, dbo.v_GS_WORKSTATION_STATUS.LastHWScan, dbo.v_GS_PC_BIOS.SerialNumber0,vFFF.PublicProfileFirewall0, 
                      vFFF.StandardProfileFirewall0, vFFF.DomainProfileFirewall0
                      ,vFFF.BackupDB0,vFFF.BackupSYS0,vFFF.ExploitDB0,vFFF.ExploitSYS0,vFFF.WarrantyEndDate0,vFFF.WarrantyHW0,vFFF.WarrantySLA0

UNION
			SELECT DISTINCT 
                      dbo.v_GS_SYSTEM.Name0 AS [Nom de Machine], dbo.v_GS_OPERATING_SYSTEM.Description0 AS Description, 
                      dbo.v_GS_OPERATING_SYSTEM.Caption0 AS [Type de Système Exploitation], REPLACE(REPLACE(REPLACE(dbo.v_R_System.AD_Site_Name0, 
                      'Default-First-Site-Name', 'Télécity'), '7800-Clairefontaine', 'Clairefontaine'), 'FFF', 'Grenelle') AS [Site Géogr.], CONVERT(VARCHAR(10), 
                      dbo.v_GS_OPERATING_SYSTEM.InstallDate0, 120) AS [Date Installation], dbo.v_GS_OPERATING_SYSTEM.TotalVisibleMemorySize0 AS Mémoire, 
                      dbo.v_GS_COMPUTER_SYSTEM.Model0 AS [Type de Machine], ISNULL(dbo.v_GS_OPERATING_SYSTEM.CSDVersion0, 'RTM') AS [Service Pack], 
                      CONVERT(VARCHAR(16), dbo.v_GS_OPERATING_SYSTEM.LastBootUpTime0, 120) AS [Last Reboot], CONVERT(VARCHAR(10), dbo.v_GS_PC_BIOS.ReleaseDate0, 120) 
                      AS [Date de la carte Mère], CONVERT(VARCHAR(10), dbo.v_GS_WORKSTATION_STATUS.LastHWScan, 120) AS [Dernier Inventaire], 
                      dbo.v_GS_PROCESSOR.Name0 AS Processeur, REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(dbo.v_GS_VIRTUAL_MACHINE_64.PhysicalHostName0, 'Serveur Physique'), 
                      '0000SVIR01', 'VM-HyperV Grenelle'), '0000SVIR02', 'VM-HyperV Grenelle'), '7800SVIR01', 'VM-HyperV Clairefontaine'),'2700SVIR01', 'VM-HyperV Corse'),'9900SVIR01', 'Développement') AS [Type d'Hôte], COUNT(dbo.v_GS_PROCESSOR.Name0) 
                      AS [Nb Processeur] , dbo.v_GS_PC_BIOS.SerialNumber0 as [Serial Number],vFFF.PublicProfileFirewall0 as [FWPublicProfile], vFFF.StandardProfileFirewall0 as [FWStandardProfile], vFFF.DomainProfileFirewall0 as [FWDomainProfile]
                      ,vFFF.BackupDB0 AS [SUPBackupDB] ,vFFF.BackupSYS0 AS [SUPBackupSYS] ,vFFF.ExploitDB0 AS [SUPExploitDB] ,vFFF.ExploitSYS0 AS [SUPExploitSYS],vFFF.WarrantyEndDate0 AS [SUPWarrantyEndDate],vFFF.WarrantyHW0 AS [SUPWarrantyHW],vFFF.WarrantySLA0 AS [SUPWarrantySLA]

					FROM dbo.v_GS_SYSTEM 
					INNER JOIN dbo.v_GS_OPERATING_SYSTEM ON dbo.v_GS_SYSTEM.ResourceID = dbo.v_GS_OPERATING_SYSTEM.ResourceID 
                    INNER JOIN dbo.v_GS_WORKSTATION_STATUS ON dbo.v_GS_SYSTEM.ResourceID = dbo.v_GS_WORKSTATION_STATUS.ResourceID 
                    INNER JOIN dbo.v_GS_VIRTUAL_MACHINE_64 ON dbo.v_GS_SYSTEM.ResourceID = dbo.v_GS_VIRTUAL_MACHINE_64.ResourceID 
                    INNER JOIN dbo.v_GS_COMPUTER_SYSTEM ON dbo.v_GS_SYSTEM.ResourceID = dbo.v_GS_COMPUTER_SYSTEM.ResourceID 
                    INNER JOIN dbo.v_GS_PC_BIOS ON dbo.v_GS_SYSTEM.ResourceID = dbo.v_GS_PC_BIOS.ResourceID 
                    INNER JOIN dbo.v_R_System ON dbo.v_GS_SYSTEM.ResourceID = dbo.v_R_System.ResourceID 
                    INNER JOIN dbo.v_GS_PROCESSOR ON dbo.v_GS_SYSTEM.ResourceID = dbo.v_GS_PROCESSOR.ResourceID
                    LEFT JOIN dbo.v_GS_FFF0 vFFF on dbo.v_GS_SYSTEM.ResourceID = vFFF.ResourceID

				WHERE     (dbo.v_GS_SYSTEM.SystemRole0 LIKE 'server') AND (dbo.v_GS_COMPUTER_SYSTEM.Model0 NOT LIKE '%VMware%') and (dbo.v_GS_SYSTEM.Name0 like 'FFF%')

				GROUP BY dbo.v_GS_SYSTEM.Name0, dbo.v_GS_OPERATING_SYSTEM.Description0, dbo.v_GS_OPERATING_SYSTEM.Caption0, 
                      dbo.v_GS_OPERATING_SYSTEM.CSDVersion0, dbo.v_R_System.AD_Site_Name0, dbo.v_GS_VIRTUAL_MACHINE_64.PhysicalHostName0, 
                      dbo.v_GS_OPERATING_SYSTEM.InstallDate0, dbo.v_GS_OPERATING_SYSTEM.TotalVisibleMemorySize0, dbo.v_GS_COMPUTER_SYSTEM.Model0, 
                      dbo.v_GS_OPERATING_SYSTEM.CSDVersion0, dbo.v_GS_PC_BIOS.ReleaseDate0, dbo.v_GS_VIRTUAL_MACHINE_64.PhysicalHostName0, 
                      dbo.v_GS_PROCESSOR.Name0, dbo.v_GS_OPERATING_SYSTEM.LastBootUpTime0, dbo.v_GS_WORKSTATION_STATUS.LastHWScan, dbo.v_GS_PC_BIOS.SerialNumber0, 
                      vFFF.PublicProfileFirewall0, vFFF.StandardProfileFirewall0, vFFF.DomainProfileFirewall0
                      ,vFFF.BackupDB0,vFFF.BackupSYS0,vFFF.ExploitDB0,vFFF.ExploitSYS0,vFFF.WarrantyEndDate0,vFFF.WarrantyHW0,vFFF.WarrantySLA0
UNION				  
				SELECT DISTINCT 
                      dbo.v_GS_SYSTEM.Name0 AS [Nom de Machine], dbo.v_GS_OPERATING_SYSTEM.Description0 AS Description, 
                      dbo.v_GS_OPERATING_SYSTEM.Caption0 AS [Type de Système Exploitation], REPLACE(REPLACE(REPLACE(dbo.v_R_System.AD_Site_Name0, 
                      'Default-First-Site-Name', 'Télécity'), '7800-Clairefontaine', 'Clairefontaine'), 'FFF', 'Grenelle') AS [Site Géogr.], CONVERT(VARCHAR(10), 
                      dbo.v_GS_OPERATING_SYSTEM.InstallDate0, 120) AS [Date Installation], dbo.v_GS_OPERATING_SYSTEM.TotalVisibleMemorySize0 AS Mémoire, 
                      dbo.v_GS_COMPUTER_SYSTEM.Model0 AS [Type de Machine], ISNULL(dbo.v_GS_OPERATING_SYSTEM.CSDVersion0, 'RTM') AS [Service Pack], 
                      CONVERT(VARCHAR(16), dbo.v_GS_OPERATING_SYSTEM.LastBootUpTime0, 120) AS [Last Reboot], CONVERT(VARCHAR(10), dbo.v_GS_PC_BIOS.ReleaseDate0, 120) 
                      AS [Date de la carte Mère], CONVERT(VARCHAR(10), dbo.v_GS_WORKSTATION_STATUS.LastHWScan, 120) AS [Dernier Inventaire], 
                      dbo.v_GS_PROCESSOR.Name0 AS Processeur, REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(dbo.v_GS_VIRTUAL_MACHINE.PhysicalHostName0, 'Serveur Physique'), 
                      '0000SVIR01', 'VM-HyperV Grenelle'), '0000SVIR02', 'VM-HyperV Grenelle'), '7800SVIR01', 'VM-HyperV Clairefontaine'),'2700SVIR01', 'VM-HyperV Corse'),'9900SVIR01', 'Développement') AS [Type d'Hôte], COUNT(dbo.v_GS_PROCESSOR.Name0) 
                      AS [Nb Processeur], dbo.v_GS_PC_BIOS.SerialNumber0 as [Serial Number], vFFF.PublicProfileFirewall0 as [FWPublicProfile], vFFF.StandardProfileFirewall0 as [FWStandardProfile], vFFF.DomainProfileFirewall0 as [FWDomainProfile]
				,vFFF.BackupDB0 AS [SUPBackupDB] ,vFFF.BackupSYS0 AS [SUPBackupSYS] ,vFFF.ExploitDB0 AS [SUPExploitDB] ,vFFF.ExploitSYS0 AS [SUPExploitSYS],vFFF.WarrantyEndDate0 AS [SUPWarrantyEndDate],vFFF.WarrantyHW0 AS [SUPWarrantyHW],vFFF.WarrantySLA0 AS [SUPWarrantySLA]
				
					FROM dbo.v_GS_SYSTEM 
					INNER JOIN dbo.v_GS_OPERATING_SYSTEM ON dbo.v_GS_SYSTEM.ResourceID = dbo.v_GS_OPERATING_SYSTEM.ResourceID 
					INNER JOIN dbo.v_GS_WORKSTATION_STATUS ON dbo.v_GS_SYSTEM.ResourceID = dbo.v_GS_WORKSTATION_STATUS.ResourceID 
					INNER JOIN dbo.v_GS_VIRTUAL_MACHINE ON dbo.v_GS_SYSTEM.ResourceID = dbo.v_GS_VIRTUAL_MACHINE.ResourceID 
					INNER JOIN dbo.v_GS_COMPUTER_SYSTEM ON dbo.v_GS_SYSTEM.ResourceID = dbo.v_GS_COMPUTER_SYSTEM.ResourceID 
					INNER JOIN dbo.v_GS_PC_BIOS ON dbo.v_GS_SYSTEM.ResourceID = dbo.v_GS_PC_BIOS.ResourceID 
					INNER JOIN dbo.v_R_System ON dbo.v_GS_SYSTEM.ResourceID = dbo.v_R_System.ResourceID 
					INNER JOIN dbo.v_GS_PROCESSOR ON dbo.v_GS_SYSTEM.ResourceID = dbo.v_GS_PROCESSOR.ResourceID
					LEFT JOIN dbo.v_GS_FFF0 vFFF on dbo.v_GS_SYSTEM.ResourceID = vFFF.ResourceID
		
				WHERE (dbo.v_GS_SYSTEM.SystemRole0 LIKE 'server') AND (dbo.v_GS_COMPUTER_SYSTEM.Model0 NOT LIKE '%VMware%') and (dbo.v_GS_SYSTEM.Name0 like 'FFF%')

				GROUP BY dbo.v_GS_SYSTEM.Name0, dbo.v_GS_OPERATING_SYSTEM.Description0, dbo.v_GS_OPERATING_SYSTEM.Caption0, 
                      dbo.v_GS_OPERATING_SYSTEM.CSDVersion0, dbo.v_R_System.AD_Site_Name0, 
                      dbo.v_GS_OPERATING_SYSTEM.InstallDate0, dbo.v_GS_OPERATING_SYSTEM.TotalVisibleMemorySize0, dbo.v_GS_COMPUTER_SYSTEM.Model0, 
                      dbo.v_GS_OPERATING_SYSTEM.CSDVersion0, dbo.v_GS_PC_BIOS.ReleaseDate0, dbo.v_GS_VIRTUAL_MACHINE.PhysicalHostName0, 
                      dbo.v_GS_PROCESSOR.Name0, dbo.v_GS_OPERATING_SYSTEM.LastBootUpTime0, dbo.v_GS_WORKSTATION_STATUS.LastHWScan	, dbo.v_GS_PC_BIOS.SerialNumber0, 
                      vFFF.PublicProfileFirewall0, vFFF.StandardProfileFirewall0, vFFF.DomainProfileFirewall0	
                      ,vFFF.BackupDB0,vFFF.BackupSYS0,vFFF.ExploitDB0,vFFF.ExploitSYS0,vFFF.WarrantyEndDate0,vFFF.WarrantyHW0,vFFF.WarrantySLA0
	UNION				  
			SELECT DISTINCT 
                      dbo.v_GS_SYSTEM.Name0 AS [Nom de Machine], dbo.v_GS_OPERATING_SYSTEM.Description0 AS Description, 
                      dbo.v_GS_OPERATING_SYSTEM.Caption0 AS [Type de Système Exploitation], REPLACE(REPLACE(REPLACE(dbo.v_R_System.AD_Site_Name0, 
                      'Default-First-Site-Name', 'Télécity'), '7800-Clairefontaine', 'Clairefontaine'), 'FFF', 'Grenelle') AS [Site Géogr.], CONVERT(VARCHAR(10), 
                      dbo.v_GS_OPERATING_SYSTEM.InstallDate0, 120) AS [Date Installation], dbo.v_GS_OPERATING_SYSTEM.TotalVisibleMemorySize0 AS Mémoire, 
                      dbo.v_GS_COMPUTER_SYSTEM.Model0 AS [Type de Machine], ISNULL(dbo.v_GS_OPERATING_SYSTEM.CSDVersion0, 'RTM') AS [Service Pack], 
                      CONVERT(VARCHAR(16), dbo.v_GS_OPERATING_SYSTEM.LastBootUpTime0, 120) AS [Last Reboot], CONVERT(VARCHAR(10), dbo.v_GS_PC_BIOS.ReleaseDate0, 120) 
                      AS [Date de la carte Mère], CONVERT(VARCHAR(10), dbo.v_GS_WORKSTATION_STATUS.LastHWScan, 120) AS [Dernier Inventaire],  dbo.v_GS_PROCESSOR.Name0 AS Processeur, 
							ISNULL (vm.Type_dHote,'NA')	AS [Type d'Hôte], 
						COUNT(dbo.v_GS_PROCESSOR.Name0) AS [Nb Processeur], 
						dbo.v_GS_PC_BIOS.SerialNumber0 AS [Serial Number],vFFF.PublicProfileFirewall0 as [FWPublicProfile], vFFF.StandardProfileFirewall0 as [FWStandardProfile], vFFF.DomainProfileFirewall0 as [FWDomainProfile]
						,vFFF.BackupDB0 AS [SUPBackupDB] ,vFFF.BackupSYS0 AS [SUPBackupSYS] ,vFFF.ExploitDB0 AS [SUPExploitDB] ,vFFF.ExploitSYS0 AS [SUPExploitSYS],vFFF.WarrantyEndDate0 AS [SUPWarrantyEndDate],vFFF.WarrantyHW0 AS [SUPWarrantyHW],vFFF.WarrantySLA0 AS [SUPWarrantySLA]
						
			FROM dbo.v_GS_SYSTEM 
			LEFT JOIN (
				SELECT dbo.v_GS_VIRTUAL_MACHINE_64.ResourceID as ResourceID, REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(dbo.v_GS_VIRTUAL_MACHINE_64.PhysicalHostName0, 'Serveur Physique'), '0000SVIR01', 'VM-HyperV Grenelle'), '0000SVIR02', 'VM-HyperV Grenelle'), '7800SVIR01', 'VM-HyperV Clairefontaine'),'2700SVIR01', 'VM-HyperV Corse'),'9900SVIR01', 'Développement') AS Type_dHote
								FROM dbo.v_GS_VIRTUAL_MACHINE_64
								UNION 
									SELECT dbo.v_GS_VIRTUAL_MACHINE.ResourceID as ResourceID, REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(dbo.v_GS_VIRTUAL_MACHINE.PhysicalHostName0, 'Serveur Physique'), 
								'0000SVIR01', 'VM-HyperV Grenelle'), '0000SVIR02', 'VM-HyperV Grenelle'), '7800SVIR01', 'VM-HyperV Clairefontaine'),'2700SVIR01', 'VM-HyperV Corse'),'9900SVIR01', 'Développement') AS Type_dHote
								FROM dbo.v_GS_VIRTUAL_MACHINE
								) VM ON dbo.v_GS_SYSTEM.ResourceID = VM.ResourceID 
			INNER JOIN dbo.v_GS_OPERATING_SYSTEM ON dbo.v_GS_SYSTEM.ResourceID = dbo.v_GS_OPERATING_SYSTEM.ResourceID 
			INNER JOIN dbo.v_GS_WORKSTATION_STATUS ON dbo.v_GS_SYSTEM.ResourceID = dbo.v_GS_WORKSTATION_STATUS.ResourceID 
			INNER JOIN dbo.v_GS_COMPUTER_SYSTEM ON dbo.v_GS_SYSTEM.ResourceID = dbo.v_GS_COMPUTER_SYSTEM.ResourceID 
			INNER JOIN dbo.v_GS_PC_BIOS ON dbo.v_GS_SYSTEM.ResourceID = dbo.v_GS_PC_BIOS.ResourceID 
			INNER JOIN dbo.v_R_System ON dbo.v_GS_SYSTEM.ResourceID = dbo.v_R_System.ResourceID 
			INNER JOIN dbo.v_GS_PROCESSOR ON dbo.v_GS_SYSTEM.ResourceID = dbo.v_GS_PROCESSOR.ResourceID
			LEFT JOIN dbo.v_GS_FFF0 vFFF on dbo.v_GS_SYSTEM.ResourceID = vFFF.ResourceID

		WHERE     (dbo.v_GS_SYSTEM.SystemRole0 LIKE 'Server') AND (dbo.v_GS_COMPUTER_SYSTEM.Model0 NOT LIKE '%VMware%') and (dbo.v_GS_SYSTEM.Name0 like 'FFF%')
		
		GROUP BY dbo.v_GS_SYSTEM.Name0, dbo.v_GS_OPERATING_SYSTEM.Description0, dbo.v_GS_OPERATING_SYSTEM.Caption0, 
                      dbo.v_GS_OPERATING_SYSTEM.CSDVersion0, dbo.v_R_System.AD_Site_Name0, dbo.v_GS_OPERATING_SYSTEM.InstallDate0, 
                      dbo.v_GS_OPERATING_SYSTEM.TotalVisibleMemorySize0, dbo.v_GS_COMPUTER_SYSTEM.Model0, dbo.v_GS_OPERATING_SYSTEM.CSDVersion0, 
                      dbo.v_GS_PC_BIOS.ReleaseDate0,
					  vm.Type_dHote ,dbo.v_GS_PROCESSOR.Name0, dbo.v_GS_OPERATING_SYSTEM.LastBootUpTime0, 
                      dbo.v_GS_WORKSTATION_STATUS.LastHWScan, dbo.v_GS_PC_BIOS.SerialNumber0, vFFF.PublicProfileFirewall0, vFFF.StandardProfileFirewall0, vFFF.DomainProfileFirewall0
                     ,vFFF.BackupDB0,vFFF.BackupSYS0,vFFF.ExploitDB0,vFFF.ExploitSYS0,vFFF.WarrantyEndDate0,vFFF.WarrantyHW0,vFFF.WarrantySLA0 
                      