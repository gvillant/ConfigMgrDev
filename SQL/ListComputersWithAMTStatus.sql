--/*
declare @CollID as varchar(10)
set @CollID = 'SMS00001' -- All systems
--set @CollID = 'FFF0027D' -- AMT 9 avec LMS
--*/

Select  
SYS.Name0 as Name,
CASE SYS.AMTStatus0 
	WHEN 0 THEN 
		CASE ISNULL(AMT.AMT0,'0')
			WHEN '0' THEN 'Not supported'
			ELSE '0 - vPRO detected'
			END 
	WHEN 1 THEN '1 - Detected'
	WHEN 2 THEN '2 - Not Provisioned (Version 9.x)'
	WHEN 3 THEN '3 - SCCM Provisoned'
	WHEN 4 THEN '4 - INTEL Provisioned'
	ELSE CASE ISNULL(AMT.AMT0,'0')
		WHEN '0' THEN '0 - Unknown (no discovery)'
		ELSE '0 - Version OK, AMTStatus Unknown'
		END
	END as [StatusDetails],
CASE SYS.AMTStatus0 
	WHEN 3 THEN 'OK'
	WHEN 4 THEN 'OK'
	ELSE 'HS'
	END as [Status],
SYS.AMTStatus0 as AMTStatus,
AMT.AMT0 as AMTVersion, AMT.ProvisionState0 as ProvisionState,
ITLOS.LMSVersion0 as LMS, ITLOS.IsMEIEnabled0 as MEIEnabled,
SCSProfileName0 as SCSProfile,ITLMgt.AMTControlMode0 as ControlMode,--ITLMgt.AMTConfigurationMode0,ITLMgt.AMTConfigurationState0 ,
CSYS.Manufacturer0 as Manufacturer, CSYS.Model0 as Model, BIOS.SerialNumber0 as Serial, OPSYS.InstallDate0 as InstallDate,
HWSCAN.LastHWScan, 
SYS.User_Name0 as UserName,
SYS.Operating_System_Name_and0 as OSFull,
SYS.Client_Version0 as ClientVersion


from v_R_System SYS
LEFT JOIN V_GS_AMT_AGENT AMT on AMT.ResourceID = SYS.ResourceId 
LEFT JOIN v_GS_Intel_AMT_GeneralInfo0 ITLINF on SYS.ResourceID = ITLINF.ResourceID
LEFT JOIN v_GS_Intel_AMT_ConfigurationInfo0 ITLCFG on SYS.ResourceID = ITLCFG.ResourceID
LEFT JOIN v_GS_Intel_AMT_OSInfo0 ITLOS on SYS.ResourceID = ITLOS.ResourceID
LEFT JOIN v_GS_Intel_AMT_ManageabilityInfo_ManagementSettings0 ITLMgt on SYS.ResourceID = ITLMgt.ResourceID
LEFT JOIN  v_GS_COMPUTER_SYSTEM CSYS on SYS.ResourceID = CSYS.ResourceID
LEFT JOIN v_GS_OPERATING_SYSTEM OPSYS on SYS.ResourceID=OPSYS.ResourceID
LEFT JOIN v_GS_WORKSTATION_STATUS HWSCAN on SYS.ResourceID = HWSCAN.ResourceID
LEFT JOIN v_GS_LastSoftwareScan SWSCAN on SYS.ResourceID = SWSCAN.ResourceID
LEFT JOIN v_GS_PC_BIOS BIOS on SYS.ResourceID = BIOS.ResourceID 
LEFT JOIN v_FullCollectionMembership FCM on FCM.ResourceID = SYS.ResourceID 

--WHERE sys.Name0 like '0000Chb%'

--WHERE ProvisionState0 = 1
--WHERE AMT0 like '9.%'

--is null and AMT0 is not null
--WHERE IsMEIEnabled0 =1
--WHERE LMSVersion0 is not null
and FCM.CollectionID = @CollID
/*
where 
AMT.AMT0 >= '0' 
and (SYS.AMTStatus0 != '3' or SYS.AMTStatus0 is NULL)  
*/

order by StatusDetails, SYS.Name0

 
