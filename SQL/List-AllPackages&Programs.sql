
SELECT PKG.PackageID
      ,PKG.Name
      ,PKG.Version
      ,PKG.Language
      ,PKG.Manufacturer
      ,PKG.Description
      ,FOL.Name as Folder
      ,PROG.ProgramID
      ,PROG.PkgID
      ,PROG.Name as ProgName
      ,PROG.Command
      ,PROG.Comment
      ,PROG.Description as ProgDescription
      ,PROG.DiskReq
      ,PROG.RemovalKey
      ,PROG.ProgramFlags
      ,PROG.Duration
      ,PKG.PkgSourceFlag
      ,PKG.PkgSourcePath
      ,PKG.SourceVersion
      ,PKG.SourceDate
      ,PKG.LastRefreshTime
      ,PKG.PkgFlags
      ,PKG.PackageType
      ,PKG2.SourceSize/1024 as SourceSize
      ,PKG2.SourceCompSize
  
  	FROM v_Package PKG
  	LEFT JOIN v_SmsPackage PKG2 on PKG.PackageID = PKG2.PkgID
  	LEFT JOIN PkgPrograms PROG on PKG.PackageID = PROG.PkgID
	LEFT JOIN vFolderMembers FOLM on PKG.PackageID = FOLM.InstanceKey
	LEFT JOIN vsms_folders FOL on FOLM.ContainerNodeID = FOL.ContainerNodeID
	
	WHERE PKG.PackageType = 0 
	--and fol.Name = '_Corbeille'
	
	ORDER BY FOL.Name, PKG.Name
	