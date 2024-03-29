/****** Script for SelectTopNRows command from SSMS  ******/
SELECT 
      ENC.Caption0
      ,ENC.ChassisTypes0
      ,ENC.SerialNumber0
      , SYS.Name0
      , CSYS.Model0
      ,bios.SMBIOSBIOSVersion0
      ,bios.Description0
      ,CSYS.Manufacturer0
      ,OS.InstallDate0
  FROM [CM_STG].[dbo].[v_GS_SYSTEM_ENCLOSURE] ENC
  left join v_R_System SYS on enc.ResourceID = sys.ResourceID
  left join v_GS_COMPUTER_SYSTEM CSYS ON CSYS.ResourceID = sys.ResourceID
  left join v_GS_OPERATING_SYSTEM OS ON OS.ResourceID = sys.ResourceID
  left join v_GS_PC_BIOS BIOS ON BIOS.ResourceID = sys.ResourceID
  where ChassisTypes0 = 15
  
  order by 4
  