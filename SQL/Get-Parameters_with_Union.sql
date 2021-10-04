select DISTINCT

CAT.CategoryName as Tag1,
CONVERT(VARCHAR,ISC.Tag1ID) as Tag1ID, 
CAT.CategoryName as TagValue

FROM v_GS_INSTALLED_SOFTWARE_CATEGORIZED ISC
LEFT JOIN v_LU_Category_Editable CAT on CAT.CategoryID = ISC.Tag1ID
where ISC.Tag1ID is not null 
/*
FROM v_LU_Category_Editable CAT
where CAT.Type = 2
*/
UNION ALL Select 'All','*','*'
order by 1,2

