
--/*
declare @BaselineName as varchar(250)
Set @BaselineName = 'DCM-W7-Laptops' -- 
declare @CIContentVersion as int
Set @CIContentVersion = 3
--*/



SELECT
v_R_System.Name0 AS 'Computer Name',
v_CICurrentComplianceStatus.CI_CurrentComplianceStatusID AS 'Compliance State Name',
v_CICurrentComplianceStatus.ComplianceState AS 'Compliance State',
v_LocalizedCIProperties_SiteLoc.DisplayName AS 'DCM Baseline Name',
v_ConfigurationItems.CIVersion AS 'DCM Baseline Content Version'
FROM
v_BaselineTargetedComputers
INNER JOIN v_R_System ON v_R_System.ResourceID = v_BaselineTargetedComputers.ResourceID
INNER JOIN v_ConfigurationItems ON v_ConfigurationItems.CI_ID = v_BaselineTargetedComputers.CI_ID
INNER JOIN v_CICurrentComplianceStatus ON v_CICurrentComplianceStatus.CI_ID = v_ConfigurationItems.CI_ID AND v_CICurrentComplianceStatus.ResourceID = v_BaselineTargetedComputers.ResourceID
INNER JOIN v_LocalizedCIProperties_SiteLoc ON v_LocalizedCIProperties_SiteLoc.CI_ID = v_ConfigurationItems.CI_ID
WHERE
v_LocalizedCIProperties_SiteLoc.DisplayName = @BaselineName
--AND v_ConfigurationItems.CIVersion = @CIContentVersion

