



SELECT  ServiceTag
      ,MAX(WarrantyEndDate) AS WarrantyEndDate
	  ,MAX(ServiceLevelDescription) AS ServiceLevelDescription
  
  FROM DellWarrantyInformation
  WHERE ServiceLevelCode not in ('D')-- and entitlementType = 'Active'
  GROUP BY ServiceTag

  order by servicetag
