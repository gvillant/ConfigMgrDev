
--/*

DECLARE @CollectionID as varchar(8)
SET @CollectionID = 'PP1009C1' --'U - APP - MyApps - Univiewer Web Console' -- SMS00002 'All Users'
--*/

SELECT DISTINCT  
	USR.Unique_User_Name0,  
	
	--Get UDA Count
	(SELECT count(UDA.UniqueUserName) 
		FROM v_UserMachineRelationship UDA
        LEFT JOIN v_UserMachineTypeRelation UMTR on UDA.RelationshipResourceID = UMTR.RelationshipResourceID  
        WHERE UDA.UniqueUserName = USR.Unique_User_Name0 and UMTR.RelationshipResourceID IS NOT NULL) as UDACount,
	
	--Get UDA list and concatenate
	SUBSTRING(
		(SELECT ', '+UDA.MachineResourceName as [text()]
            FROM v_UserMachineRelationship UDA 
            LEFT JOIN v_UserMachineTypeRelation  umtr on uda.RelationshipResourceID = umtr.RelationshipResourceID  
            WHERE UDA.UniqueUserName = USR.Unique_User_Name0 and umtr.RelationshipResourceID IS NOT NULL
            ORDER BY UDA.UniqueUserName
            For XML PATH ('')), 2, 1000) as UDA,
	
	USR.Full_User_Name0, USR.Mail0

	FROM v_R_User USR

	LEFT JOIN v_FullCollectionMembership FCM on USR.ResourceID = FCM.ResourceID 
	
	WHERE FCM.CollectionID = @CollectionID 
