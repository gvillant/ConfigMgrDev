select 
COL.collectionname as [CollectionName], 
FOL.Name as[FolderName], 
FOLM.ContainerNodeID as [FolderID], 
COL.siteid as [CollectionID]

from vcollections COL
LEFT join vFolderMembers FOLM on COL.siteid = FOLM.InstanceKey
LEFT join vsms_folders FOL on FOLM.ContainerNodeID = FOL.ContainerNodeID

where FOLM.ObjectTypeName = 'SMS_Collection_Device' 

--AND FOL.Name = 'Rapports' 