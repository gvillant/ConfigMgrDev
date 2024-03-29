
SELECT PKG.PackageID
      ,PKG.Name
      ,PKG.Version
      ,PKG.Language
      ,PKG.Manufacturer
      ,PKG.Description
      ,FOL.Name
      ,PKG.PkgSourceFlag
      ,PKG.PkgSourcePath
      ,PKG.SourceVersion
      ,PKG.SourceDate
      ,PKG.LastRefreshTime
      ,PKG.PkgFlags
      ,PKG.PackageType
      ,PKG2.SourceSize, PKG2.SourceCompSize
  
  	FROM v_Package PKG
  	LEFT JOIN v_SmsPackage PKG2 on PKG.PackageID = PKG2.PkgID
	LEFT JOIN vFolderMembers FOLM on PKG.PackageID = FOLM.InstanceKey
	LEFT JOIN vsms_folders FOL on FOLM.ContainerNodeID = FOL.ContainerNodeID
	
	WHERE PKG.PackageType = 0 
	--and fol.Name = '_Corbeille'
	
	ORDER BY FOL.Name, PKG.Name
	