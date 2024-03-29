--Tous les utilisateurs ayant lancé Visio
SELECT 
      [LastUsedTime0]
      ,DATEDIFF(DAY,[LastUsedTime0],GETDATE()) as NoUsedSinceDays
      ,CLISUM.LastHW
      ,[LastUserName0]
      ,sys.Name0
      ,[CompanyName0]
      ,[ExplorerFileName0]
      ,[FileDescription0]
      ,[FileVersion0]
      ,[FolderPath0]
      ,[LaunchCount0]
      ,[msiDisplayName0]
      ,[msiPublisher0]
      ,[msiVersion0]
      ,[OriginalFileName0]
      ,[ProductCode0]
      ,[ProductName0]
      ,[ProductVersion0]
  FROM [v_GS_CCM_RECENTLY_USED_APPS] RUA
  LEFT JOIN v_R_System SYS on RUA.ResourceID = SYS.ResourceID
  LEFT JOIN v_CH_ClientSummary CLISUM on RUA.ResourceID = CLISUM.ResourceID
  
 where ExplorerFileName0 = 'Visio.exe'
	AND FolderPath0 ='C:\Program Files (x86)\Microsoft Office\Office15\'
	--AND DATEDIFF(DAY,[LastUsedTime0],GETDATE()) > 180
	--AND LastUserName0 = 'STAGO\pacielld'
 ORDER BY 5