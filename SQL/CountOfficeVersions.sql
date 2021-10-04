--Add/Remove Programs not in master
Select count(*) as count, arp.DisplayName0, arp.Publisher0 , arp.Version0


FROM v_Add_Remove_Programs arp

where 
	arp.DisplayName0 like 'Microsoft Office Professional%' 
or	arp.DisplayName0 like 'Microsoft Office Stand%' 


Group by arp.DisplayName0, arp.Publisher0 , arp.Version0

ORDER BY arp.displayName0, arp.publisher0, count(*) desc
