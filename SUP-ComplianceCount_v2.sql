declare @AuthListLocalID as int

declare @AuthListID as varchar(250)
declare @CollID as varchar(10)
Set @CollID = 'STG00077'
Set @AuthListID = 'ScopeId_CFD257E3-A5C7-4E0B-9714-A19B7B7C0B10/AuthList_cf68e7f3-c6eb-4858-81d8-d6b183d5a4ba'

select @AuthListLocalID=CI_ID from v_AuthListInfo where CI_UniqueID=@AuthListID



select
count(*) [Total Clients], li.title,coll.name,
SUM (CASE WHEN ucs.status=3 or ucs.status=1  then 1 ELSE 0 END ) as 'Installed / Not Applicable',
sum( case When ucs.status=2 Then 1 ELSE 0 END ) as 'Required',
sum( case When ucs.status=0 Then 1 ELSE 0 END ) as 'Unknown',
round((CAST(SUM (CASE WHEN ucs.status=3 or ucs.status=1 THEN 1 ELSE 0 END) as float)/count(*) )*100,2) as 'Success %',
	round((CAST(count(case when ucs.status not in('3','1') THEN '*' end) as float)/count(*))*100,2) as 'Not Success%'
	From v_Update_ComplianceStatusAll UCS
inner join v_r_system sys on ucs.resourceid=sys.resourceid
inner join v_FullCollectionMembership fcm on ucs.resourceid=fcm.resourceid
inner join v_collection coll on coll.collectionid=fcm.collectionid
inner join v_AuthListInfo LI on ucs.ci_id=li.ci_id
where li.CI_ID = @AuthListLocalID  and coll.CollectionID = @CollID -- and ucs.status = 2
group by li.title,coll.name
order by 1
