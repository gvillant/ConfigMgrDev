

SELECT gss.Name0 AS [Nom Machine], C.CollectionName as [Site], SYS.User_Name0 AS [Nom Utilisateur],
	--MAX(ARP.InstallDate0),
	 COUNT(arp.DisplayName0)
	--ARP.Version0 as Version

FROM v_R_System SYS
	LEFT JOIN v_GS_SYSTEM GSS ON SYS.ResourceID = GSS.ResourceID
	LEFT JOIN v_GS_ADD_REMOVE_PROGRAMS ARP ON SYS.ResourceID = ARP.ResourceID 
	LEFT JOIN v_FullCollectionMembership_Valid COL ON SYS.ResourceID = COL.ResourceID
	LEFT JOIN vCollections C ON COL.CollectionID = C.SiteID
	
WHERE 
	(arp.DisplayName0 like 'Microsoft Office Professional%' 
			or	arp.DisplayName0 like 'Microsoft Office Stand%')  
	AND (C.CollectionName in ('0000-MADMR-Workstations (All)','7800-MADMR-Workstations (All)'))  and arp.ProdID0 <> 'STANDARD'
	
	GROUP BY gss.Name0, C.CollectionName, SYS.User_Name0
	HAVING (count(arp.DisplayName0) > 1 )
	
	ORDER BY [Nom Machine]

	
	