--select or delete all duplicate records with Decommissioned0 = 1 AND t3.sms_unique_identifier0 IS NOT NULL

--delete 
select * from System_DISC where itemkey in (
select itemkey from System_DISC t3 where Name0  in (

select distinct T2.Name0 from (
		select sms_unique_identifier0,Name0  
		from System_DISC 
		GROUP BY sms_unique_identifier0, Name0
		HAVING COUNT(*) >=2) T1
		join 
		System_DISC T2 ON 
		T1.sms_unique_identifier0 = T2.sms_unique_identifier0 
		and 
		T1.Name0 = T2.Name0
		where t3.Decommissioned0 = 1 AND t3.sms_unique_identifier0 IS NOT NULL
		)
		-- sms_unique_identifier0 = ('GUID:ee68813c-d86a-49d7-b2a8-cc95eeffa7d5')
		--Decommissioned0 = '1' --AND Obsolete0 = '1'
		--and sms_unique_identifier0 is not null
		--order by 1
		)