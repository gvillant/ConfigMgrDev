declare @AuthListLocalID as int
/*
declare @AuthListID as varchar(250)
declare @CollID as varchar(10)
Set @CollID = 'FFF00275'
Set @AuthListID = 'ScopeId_25A690F5-780E-4EBE-8F34-3E95034EC5EE/AuthList_B014BABB-6355-4B3A-A628-7B36F2F1A1C1'
*/
select @AuthListLocalID=CI_ID from v_AuthListInfo where CI_UniqueID=@AuthListID


select
 sys.Name0, ucs.status, 
 CASE ucs.status
	WHEN '0' THEN 'Unknown'
	WHEN '1' THEN ''
	WHEN '2' THEN 'Required'
	WHEN '3' THEN 'Installed / Not Applicable'
	END As Statut

From v_Update_ComplianceStatusAll UCS
inner join v_r_system sys on ucs.resourceid=sys.resourceid
inner join v_FullCollectionMembership fcm on ucs.resourceid=fcm.resourceid
inner join v_collection coll on coll.collectionid=fcm.collectionid
inner join v_AuthListInfo LI on ucs.ci_id=li.ci_id
where li.CI_ID = @AuthListLocalID  and coll.CollectionID = @CollID --and ucs.status=3
--group by li.title,coll.name
order by 1


