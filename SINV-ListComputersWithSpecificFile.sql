select distinct SYS.Name0 as Computer, 
USR.Name0 as FullName,USR.givenName0 as GivenName,USR.sn0 as LastName, USR.Unique_User_Name0, USR.User_Account_Control0 as UAC,
SF.FileName, SF.FileVersion,UPPER( right(SF.FileName,3)) as Extension,
SF.ModifiedDate as 'Inventoried Date',SF.FileModifiedDate as 'Modified Date', SF.CreationDate as 'Creation Date',
SF.Filepath,SF.FileSize/1024/1024 as FileSizeMB, SF.FileSize/1024 as FileSizeKB

FROM v_R_System SYS 
LEFT JOIN v_GS_SoftwareFile SF on SYS.ResourceID = SF.ResourceID
LEFT JOIN v_FullCollectionMembership FCM on SYS.ResourceID = FCM.ResourceID
LEFT JOIN v_R_User USR on SYS.User_Name0 = USR.User_Name0

--where CollectionID='STG0073C' -- XP IE,Lemgo & US
--where CollectionID='STG0030A' -- All Systems Domain IE
 where SF.FileName like 'iexplore.exe' --
 and CollectionID='FFF0035C' --
 and SF.Filepath like 'C:\Program Files\Internet Explorer\%'
 AND SF.FileVersion like '11%'
--where SF.FileName like '%.exe' and CollectionID='STG0073C' --and SF.Filepath like 'C:\documents and settings\%'

--and SYS.Name0 = 'tcie158'

Order by SF.FileVersion, SYS.Name0, SF.FileName

