declare @AuthListLocalID as int
--/*
declare @AuthListID as varchar(250)
declare @CollID as varchar(10)
Set @CollID = 'STG00728' -- INT US Collection
Set @AuthListID = 'ScopeId_CFD257E3-A5C7-4E0B-9714-A19B7B7C0B10/AuthList_A1DF5C7C-B119-4AE2-B9EB-0E237A0DB95D' -- is Baseline
--'ScopeId_CFD257E3-A5C7-4E0B-9714-A19B7B7C0B10/AuthList_4D58C7D7-E0A9-4CF2-B8E6-3212427FC290'
--*/
select @AuthListLocalID=CI_ID from v_AuthListInfo where CI_UniqueID=@AuthListID



select
count(*) [Total Clients], li.title,coll.name,
SUM (CASE WHEN ucs.status=3 or ucs.status=1  then 1 ELSE 0 END ) as 'Installed / Not Applicable',
sum( case When ucs.status=2 Then 1 ELSE 0 END ) as 'Required',
sum( case When ucs.status=0 Then 1 ELSE 0 END ) as 'Unknown',
round((CAST(SUM (CASE WHEN ucs.status=3 or ucs.status=1 THEN 1 ELSE 0 END) as float)/count(*) )*100,2) as 'Success %',
	round((CAST(count(case when ucs.status not in('3','1') THEN '*' end) as float)/count(*))*100,2) as 'Not Success%'
	From v_Update_ComplianceStatusAll UCS
left join v_r_system sys on ucs.resourceid=sys.resourceid
left join v_FullCollectionMembership fcm on ucs.resourceid=fcm.resourceid
left join v_collection coll on coll.collectionid=fcm.collectionid
left join v_AuthListInfo LI on ucs.ci_id=li.ci_id
where li.CI_ID = @AuthListLocalID  and coll.CollectionID = @CollID -- and ucs.status = 2
group by li.title,coll.name
order by 1