

WITH ClientOS (Domain, OS) AS (
			SELECT 
				  sys.Resource_Domain_OR_Workgr0 as Domain,
				  CASE sys.Operating_System_Name_and0 
				  WHEN 'Microsoft Windows NT Workstation 5.1' THEN 'Windows XP'
				  WHEN 'Microsoft Windows NT Workstation 6.1' THEN 'Windows 7'
				  WHEN 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' THEN 'Windows 7'
				  ELSE 'Unknown'
				  END as OS
				  
  FROM v_R_System_Valid sys 
  WHERE sys.Operating_System_Name_and0 like '%Workstation%'
	)

  SELECT Domain , OS, COUNT(OS) FROM ClientOS
  
  GROUP BY Domain, OS
  ORDER BY Domain, OS
  