/****** Script for SelectTopNRows command from SSMS  ******/
SELECT [Name0]as Name
      ,MAX (IP.IP_Addresses0) as IP
      ,MAX (SUB.IP_Subnets0)as Subnet
      ,MAX (BDY.DisplayName) as Location
      ,[AD_Site_Name0] as SiteAD
      ,[Distinguished_Name0] as DN
      ,[Last_Logon_Timestamp0] as LastLogon
      ,[Operating_System_Name_and0] as OSFull
      ,[operatingSystem0] as OS
      ,[operatingSystemServicePac0] as SP
      ,[Resource_Domain_OR_Workgr0] as Domain
      ,[User_Account_Control0] as UAC
      ,[Creation_Date0] as CreationDate
  FROM [v_R_System] SYS
  LEFT join v_RA_System_IPAddresses IP on IP.ResourceID = SYS.ResourceID
  LEFT join v_RA_System_IPSubnets SUB on SUB.ResourceID = SYS.ResourceID
  LEFT join vSMS_Boundary BDY on SUB.IP_Subnets0 =BDY.Value
  WHERE SYS.Operating_System_Name_and0 = 'Microsoft Windows NT Workstation 5.1' AND SYS.operatingSystemServicePac0 <> 'Service Pack 3' AND SYS.operatingSystem0 <> 'Windows 7 Professional'
  GROUP BY SYS.[ResourceID]
      ,[Name0]
      ,[AD_Site_Name0]
      ,[Distinguished_Name0]
      ,[Last_Logon_Timestamp0]
      ,[Operating_System_Name_and0]
      ,[operatingSystem0]
      ,[operatingSystemServicePac0]
      ,[Resource_Domain_OR_Workgr0]
      ,[User_Account_Control0]
      ,[Creation_Date0]
  Order by SYS.AD_Site_Name0
