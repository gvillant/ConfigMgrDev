

-- Tous les postes avec Viso.exe avec dernière date d'utilisation
SELECT SYS.Name0, 
      DATEDIFF(DAY,[LastUsedTime0],GETDATE()) as NoUsedSinceDays,
      RUA.LastUsedTime0,RUA.LastUserName0,
      
		SUBSTRING(
        (
            Select ', '+UDA.UniqueUserName  AS [text()]
            From v_UserMachineRelationship UDA 
            LEFT JOIN v_UserMachineTypeRelation  umtr on uda.RelationshipResourceID = umtr.RelationshipResourceID  
            Where UDA.MachineResourceID = SYS.ResourceID and umtr.RelationshipResourceID IS NOT NULL
            ORDER BY UDA.UniqueUserName
            For XML PATH ('')
        ), 2, 1000) as UDA,
    (Select count(UDA.UniqueUserName) 
    From v_UserMachineRelationship UDA
            LEFT JOIN v_UserMachineTypeRelation  umtr on uda.RelationshipResourceID = umtr.RelationshipResourceID  
            Where UDA.MachineResourceID = SYS.ResourceID and umtr.RelationshipResourceID IS NOT NULL) as UDACount
        
  FROM v_GS_SoftwareFile SINV
  LEFT JOIN v_R_System SYS on SINV.ResourceID = SYS.ResourceID
  LEFT JOIN v_GS_CCM_RECENTLY_USED_APPS RUA on (RUA.ResourceID = SYS.ResourceID AND (RUA.ExplorerFileName0 = 'Visio.exe' or RUA.ExplorerFileName0 IS NULL)AND (RUA.FolderPath0 ='C:\Program Files (x86)\Microsoft Office\Office15\' or RUA.FolderPath0 IS NULL))
  WHERE 
	SINV.FileName = 'Visio.exe'
	AND SINV.FilePath ='C:\Program Files (x86)\Microsoft Office\Office15\'
	AND (DATEDIFF(DAY,[LastUsedTime0],GETDATE()) > 180 or DATEDIFF(DAY,[LastUsedTime0],GETDATE()) IS NULL)
ORDER BY 1
	