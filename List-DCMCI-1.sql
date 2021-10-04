SELECT DISTINCT DisplayName
 FROM v_LocalizedCIProperties_SiteLoc CIPROP
 left join v_CISettings CISET on CISET.CI_ID = CIPROP.CI_ID
 
  where SourceType in ('0','4','9') 
  
  