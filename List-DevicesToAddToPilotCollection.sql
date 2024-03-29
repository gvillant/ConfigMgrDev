
-- 'STG0082F' > SUP_Users_Pilote
-- 'STG00077' > SUP_Clients-OS-Pilote


SELECT  umr.MachineResourceName
  FROM v_R_System sys
  
  LEFT JOIN [v_UserMachineRelationship] umr on umr.MachineResourceID = sys.ResourceID
  LEFT JOIN v_UserMachineTypeRelation umtr on umtr.RelationshipResourceID = umr.RelationshipResourceID
  
  WHERE umtr.RelationshipResourceID is not null
	--and umr.[UniqueUserName] =  'stago\melotf' 
		AND umr.UniqueUserName in ( 
			SELECT Unique_User_Name0
			FROM v_R_User USR
			LEFT JOIN v_FullCollectionMembership FCM on USR.ResourceID = FCM.ResourceID
			WHERE FCM.CollectionID = 'STG0082F' ) 
		AND sys.Name0 not in (
			SELECT Name0
			FROM v_R_System sys
			LEFT JOIN v_FullCollectionMembership FCM on sys.ResourceID = FCM.ResourceID
			WHERE FCM.CollectionID = 'STG00077' )
