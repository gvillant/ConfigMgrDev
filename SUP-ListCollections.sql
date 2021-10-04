Select 
CollectionID, 
Name 
from 
v_Collection
WHERE
CollectionID = 'FFF0009C' -- 7800
OR 
CollectionID = 'FFF0009B' -- 0000

--CollectionID = 'EAS0001F' -- BO Servers
--OR 
--CollectionID = 'EAS0002C' -- BO Servers in prod
--OR 
--CollectionID = 'EAS00023' -- BO Servers NOT in prod

ORDER BY CollectionID