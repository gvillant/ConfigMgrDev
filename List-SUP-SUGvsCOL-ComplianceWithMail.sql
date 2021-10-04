declare @AuthListLocalID as int
/*
declare @AuthListID as varchar(250)
declare @CollID as varchar(10)
Set @CollID = 'STG00728' -- INT US Collection
Set @AuthListID = 'ScopeId_CFD257E3-A5C7-4E0B-9714-A19B7B7C0B10/AuthList_A1DF5C7C-B119-4AE2-B9EB-0E237A0DB95D' -- is Baseline
--'ScopeId_CFD257E3-A5C7-4E0B-9714-A19B7B7C0B10/AuthList_4D58C7D7-E0A9-4CF2-B8E6-3212427FC290'
*/
select @AuthListLocalID=CI_ID from v_AuthListInfo where CI_UniqueID=@AuthListID


select
 sys.Name0, sys.User_Name0 as UserName, usr.Mail0 as Mail, uss.LastScanTime, ucs.status, 
 CASE ucs.status
	WHEN '0' THEN 'Unknown'
	WHEN '1' THEN ''
	WHEN '2' THEN 'Required'
	WHEN '3' THEN 'Installed / Not Applicable'
	END As Statut

From v_Update_ComplianceStatusAll UCS
LEFT join v_r_system sys on ucs.resourceid=sys.resourceid
LEFT join v_FullCollectionMembership fcm on ucs.resourceid=fcm.resourceid
LEFT join v_collection coll on coll.collectionid=fcm.collectionid
LEFT join v_AuthListInfo LI on ucs.ci_id=li.ci_id
LEFT join v_UpdateScanStatus uss on uss.ResourceID = sys.ResourceID
LEFT join v_R_User usr on sys.User_Name0 = usr.User_Name0 and sys.Resource_Domain_OR_Workgr0 = usr.Windows_NT_Domain0
where li.CI_ID = @AuthListLocalID  and coll.CollectionID = @CollID --and ucs.status=3
--group by li.title,coll.name
order by 1