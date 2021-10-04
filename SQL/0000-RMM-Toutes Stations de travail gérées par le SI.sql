SELECT DISTINCT 
	TOP (100) PERCENT dbo.v_GS_COMPUTER_SYSTEM.Name0 AS [Nom Ordinateur], 
    dbo.v_GS_SYSTEM_ENCLOSURE.SerialNumber0 AS [Numéro de Série], 
	dbo.v_GS_COMPUTER_SYSTEM.Model0 AS [Modele Ordinateur], 
	REPLACE(dbo.v_GS_SYSTEM_CONSOLE_USAGE.TopConsoleUser0, 'fff_lan\', '') AS [Top Utilisateur],
	REPLACE(dbo.v_GS_COMPUTER_SYSTEM.UserName0, 'fff_lan\', '') AS [Dernier Utilisateur],
	CONVERT(VARCHAR(10), dbo.v_GS_DELL_Chassis0.FirstPowerOnDate0, 111) AS [Date du Premier Boot], 
	CONVERT(VARCHAR(10), dbo.v_GS_PC_BIOS.ReleaseDate0, 111) AS [Date du BIOS], 
-- Fixed 26/11/2014 by Gaetan - error with conversion to smallint ... 
	
	NULL AS [Date de la fabrication],
/*	ISNULL(CONVERT(VARCHAR(10), dbo.v_GS_DELL_Chassis0.ManufactureDate0, 111), 
		CASE dbo.v_GS_COMPUTER_SYSTEM.Manufacturer0 
			WHEN 'Hewlett-Packard' THEN CONVERT(VARCHAR(4), 2000 + (
				CASE 
					WHEN CONVERT(smallint, substring(dbo.v_GS_SYSTEM_ENCLOSURE.SerialNumber0, 4, 1)) <= CONVERT(smallint, substring(CONVERT(VARCHAR(10), 
		 GetDate(), 101), 
		 { fn LENGTH(CONVERT(VARCHAR(10), GetDate(), 101)) }, 1)) THEN CONVERT(smallint, substring(CONVERT(VARCHAR(10), GetDate(), 101),
         { fn LENGTH(CONVERT(VARCHAR(10), GetDate(), 101)) } - 1, 1) + substring(dbo.v_GS_SYSTEM_ENCLOSURE.SerialNumber0, 4, 1)) 
		 			WHEN CONVERT(smallint, substring(dbo.v_GS_SYSTEM_ENCLOSURE.SerialNumber0, 4, 1)) > CONVERT(smallint, substring(CONVERT(VARCHAR(10), GetDate(), 101), 
         { fn LENGTH(CONVERT(VARCHAR(10), GetDate(), 101)) }, 1)) THEN CONVERT(VARCHAR(4), CONVERT(smallint, substring(CONVERT(VARCHAR(10), GetDate(), 101), 
         { fn LENGTH(CONVERT(VARCHAR(10), GetDate(), 101)) } - 1, 1)) - 1) + substring(dbo.v_GS_SYSTEM_ENCLOSURE.SerialNumber0, 4, 1) END)) + '/' + substring(CONVERT(VARCHAR(10), CONVERT(DateTime, '01/01/' + CONVERT(VARCHAR(4), 2000 + (CASE WHEN CONVERT(smallint, 
                      substring(dbo.v_GS_SYSTEM_ENCLOSURE.SerialNumber0, 4, 1)) <= CONVERT(smallint, substring(CONVERT(VARCHAR(10), GetDate(), 101), 
                      { fn LENGTH(CONVERT(VARCHAR(10), GetDate(), 101)) }, 1)) THEN CONVERT(smallint, substring(CONVERT(VARCHAR(10), GetDate(), 101), 
                      { fn LENGTH(CONVERT(VARCHAR(10), GetDate(), 101)) } - 1, 1) + substring(dbo.v_GS_SYSTEM_ENCLOSURE.SerialNumber0, 4, 1)) 
					WHEN CONVERT(smallint, 
                      substring(dbo.v_GS_SYSTEM_ENCLOSURE.SerialNumber0, 4, 1)) > CONVERT(smallint, substring(CONVERT(VARCHAR(10), GetDate(), 101), 
                      { fn LENGTH(CONVERT(VARCHAR(10), GetDate(), 101)) }, 1)) THEN CONVERT(VARCHAR(4), CONVERT(smallint, substring(CONVERT(VARCHAR(10), GetDate(), 101), 
                      { fn LENGTH(CONVERT(VARCHAR(10), GetDate(), 101)) } - 1, 1)) - 1) + substring(dbo.v_GS_SYSTEM_ENCLOSURE.SerialNumber0, 4, 1) END)), 101) 
                      + (CONVERT(smallint, substring(dbo.v_GS_SYSTEM_ENCLOSURE.SerialNumber0, 5, 2)) * 5.5), 101), 1, 2) + '/01' ELSE NULL END) AS [Date de la fabrication],
 */   
	CONVERT(VARCHAR(10), dbo.v_GS_OPERATING_SYSTEM.InstallDate0, 111) AS [Date Installation],
	dbo.v_GS_OPERATING_SYSTEM.Caption0 AS [Systeme Exploitation], 
	CONVERT(VARCHAR(10), dbo.v_GS_OPERATING_SYSTEM.LastBootUpTime0, 111) AS [Date du dernier reboot], 
	CONVERT(VARCHAR(10), dbo.v_GS_WORKSTATION_STATUS.LastHWScan, 111) AS [Date du dernier inventaire], 
    dbo.v_GS_COMPUTER_SYSTEM.Manufacturer0 AS Fabriquant, 
	REPLACE(REPLACE(dbo.v_R_System.Client0, '0', 'Hors Connexion'), '1', 'En ligne') AS Statut, 
    CASE dbo.v_GS_NETWORK_ADAPTER_CONFIGURATION.DefaultIPGateway0 
			WHEN '10.0.0.126' THEN 'Publicis Bastille' WHEN '10.78.0.254' THEN 'Clairefontaine' WHEN '10.78.3.254'
                       THEN 'Clairefontaine' WHEN '10.78.2.254' THEN 'Clairefontaine' WHEN '10.75.2.254' THEN 'Associations' WHEN '10.75.5.254' THEN 'Rez de chaussé' WHEN '10.75.6.254'
                       THEN '1er étage' WHEN '10.75.100.254' THEN 'Informatique' WHEN '10.75.7.254' THEN '2èm étage' WHEN '10.75.8.254' THEN '3ème étage' WHEN '10.75.10.254' THEN
                       'Accueil' WHEN '10.75.0.254' THEN 'VLAN Serveurs FFF' ELSE 'Extérieur' END AS emplacement, 
	dbo.v_GS_PC_BIOS.SMBIOSBIOSVersion0 AS [Version du Bios], 
    CASE CONVERT(VARCHAR, dbo.v_R_System.AMTStatus0) 
            WHEN 0 THEN 'Inconnu' WHEN 1 THEN 'Detected' WHEN 2 THEN 'Non Provisionné' WHEN 3 THEN 'Provisionné' ELSE '' END AS AMT

FROM    dbo.v_R_System LEFT OUTER JOIN
                      dbo.v_GS_DELL_Chassis0 ON dbo.v_R_System.ResourceID = dbo.v_GS_DELL_Chassis0.ResourceID AND 
                      dbo.v_GS_DELL_Chassis0.CreationClassName0 = 'DCIM_Chassis' LEFT OUTER JOIN
                      dbo.v_GS_COMPUTER_SYSTEM ON dbo.v_R_System.ResourceID = dbo.v_GS_COMPUTER_SYSTEM.ResourceID INNER JOIN
                      dbo.v_GS_OPERATING_SYSTEM ON dbo.v_R_System.ResourceID = dbo.v_GS_OPERATING_SYSTEM.ResourceID INNER JOIN
                      dbo.v_GS_WORKSTATION_STATUS ON dbo.v_R_System.ResourceID = dbo.v_GS_WORKSTATION_STATUS.ResourceID INNER JOIN
                      dbo.v_GS_PC_BIOS ON dbo.v_R_System.ResourceID = dbo.v_GS_PC_BIOS.ResourceID INNER JOIN
                      dbo.v_GS_COMPUTER_SYSTEM AS v_GS_COMPUTER_SYSTEM_1 ON dbo.v_R_System.ResourceID = v_GS_COMPUTER_SYSTEM_1.ResourceID INNER JOIN
                      dbo.v_GS_SYSTEM_ENCLOSURE ON dbo.v_R_System.ResourceID = dbo.v_GS_SYSTEM_ENCLOSURE.ResourceID INNER JOIN
                      dbo.v_GS_NETWORK_ADAPTER_CONFIGURATION ON dbo.v_R_System.ResourceID = dbo.v_GS_NETWORK_ADAPTER_CONFIGURATION.ResourceID LEFT OUTER JOIN
                      dbo.v_GS_SYSTEM_CONSOLE_USAGE ON dbo.v_R_System.ResourceID = dbo.v_GS_SYSTEM_CONSOLE_USAGE.ResourceID INNER JOIN
                      dbo.v_GS_SYSTEM ON dbo.v_R_System.ResourceID = dbo.v_GS_SYSTEM.ResourceID
WHERE     (dbo.v_GS_SYSTEM.SystemRole0 = 'Workstation') AND (dbo.v_R_System.Name0 NOT LIKE '7400%') AND (dbo.v_R_System.Name0 NOT LIKE '8000%') AND 
                      (dbo.v_R_System.Name0 NOT LIKE '5600%') AND (dbo.v_GS_NETWORK_ADAPTER_CONFIGURATION.DefaultIPGateway0 IN ('10.78.0.254', '10.78.2.254', '10.78.3.254', 
                      '10.75.0.254', '10.75.2.254', '10.75.5.254', '10.75.6.254', '10.75.7.254', '10.75.8.254', '10.75.10.254', '10.75.100.254', '10.05.0.254', '10.27.0.254', '10.99.0.254', 
                      '10.74.0.254', '10.80.254', '10.56.0.254', '10.6.1.254')) AND (dbo.v_GS_NETWORK_ADAPTER_CONFIGURATION.MACAddress0 IS NOT NULL) OR
                      (dbo.v_GS_SYSTEM.SystemRole0 = 'Workstation') AND (dbo.v_R_System.Name0 NOT LIKE '7400%') AND (dbo.v_R_System.Name0 NOT LIKE '8000%') AND 
                      (dbo.v_R_System.Name0 NOT LIKE '5600%') AND (dbo.v_GS_NETWORK_ADAPTER_CONFIGURATION.DefaultIPGateway0 NOT IN ('10.05.0.254', '10.27.0.254', '10.99.0.254', 
                      '10.74.0.254', '10.80.254', '10.56.0.254', '10.6.1.254')) AND (dbo.v_GS_NETWORK_ADAPTER_CONFIGURATION.MACAddress0 IS NOT NULL) AND
                          ((SELECT     COUNT(*) AS Expr1
                              FROM         dbo.v_GS_NETWORK_ADAPTER_CONFIGURATION AS gnac
                              WHERE     (ResourceID = dbo.v_R_System.ResourceID) AND (MACAddress0 IS NOT NULL)) <= 1) OR
                      (dbo.v_GS_SYSTEM.SystemRole0 = 'Workstation') AND (dbo.v_R_System.Name0 NOT LIKE '7400%') AND (dbo.v_R_System.Name0 NOT LIKE '8000%') AND 
                      (dbo.v_R_System.Name0 NOT LIKE '5600%') AND (dbo.v_GS_NETWORK_ADAPTER_CONFIGURATION.DefaultIPGateway0 NOT IN ('10.05.0.254', '10.27.0.254', '10.99.0.254', 
                      '10.74.0.254', '10.80.254', '10.56.0.254', '10.6.1.254')) AND (dbo.v_GS_NETWORK_ADAPTER_CONFIGURATION.MACAddress0 IS NOT NULL) AND 
                      (ISNULL(dbo.v_GS_NETWORK_ADAPTER_CONFIGURATION.DefaultIPGateway0, N'XXXXXX') NOT IN ('10.78.0.254', '10.78.2.254', '10.78.3.254', '10.75.0.254', '10.75.2.254', 
                      '10.75.5.254', '10.75.6.254', '10.75.7.254', '10.75.8.254', '10.75.10.254', '10.75.100.254', '10.05.0.254', '10.27.0.254', '10.99.0.254', '10.74.0.254', '10.80.254', 
                      '10.56.0.254', '10.6.1.254')) AND (NOT EXISTS
                          (SELECT     NULL AS Expr1
                            FROM          dbo.v_GS_NETWORK_ADAPTER_CONFIGURATION AS gnac
                            WHERE      (ResourceID = dbo.v_R_System.ResourceID) AND (MACAddress0 IS NOT NULL) AND (DefaultIPGateway0 IN ('10.78.0.254', '10.78.2.254', '10.78.3.254', 
                                                   '10.75.0.254', '10.75.2.254', '10.75.5.254', '10.75.6.254', '10.75.7.254', '10.75.8.254', '10.75.10.254', '10.75.100.254', '10.05.0.254', '10.27.0.254', 
                                                   '10.99.0.254', '10.74.0.254', '10.80.254', '10.56.0.254', '10.6.1.254'))))
ORDER BY [Nom Ordinateur]