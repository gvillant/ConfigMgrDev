select 
COL.collectionname as [Name], 
FOL.Name as[FolderName], 
FOLM.ContainerNodeID as [FolderID], 
COL.siteid as [CollectionID]

from vcollections COL
LEFT join vFolderMembers FOLM on COL.siteid = FOLM.InstanceKey
LEFT join vsms_folders FOL on FOLM.ContainerNodeID = FOL.ContainerNodeID

where FOLM.ObjectTypeName = 'SMS_Collection_Device' AND (FOL.Name != '_OLD' AND CollectionName LIKE 'FFF-SUP%') 
OR

(COL.siteid = 'FFF0009C' -- 7800
OR 
COL.siteid = 'FFF0009B') -- 0000
