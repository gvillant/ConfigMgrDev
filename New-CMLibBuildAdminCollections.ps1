#############################################################################
# Author  : Benoit Lecours 
# Website : www.SystemCenterDudes.com
# Twitter : @scdudes
#
# Version : 1.0
# Created : 2014/07/17
# Modified : 
# 2014/08/14 - Added Collection 34,35,36
# 2014/09/23 - Changed collection 4 to CU3 instead of CU2
# 2015/01/30 - Improve Android collection
# 2015/02/03 - Changed collection 4 to CU4 instead of CU3
# 2015/05/06 - Changed collection 4 to CU5 instead of CU4
# 2015/05/06 - Changed collection 4 to SP1 instead of CU5
#            - Add collections 37 to 42
# 2015/08/04 - Add collection 43,44
#            - Changed collection 4 to SP1 CU1 instead of SP1
# 2015/08/06 - Change collection 22 query
# 2015/08/12 - Added Windows 10 - Collection 45
#
# Purpose : This script create a set of SCCM collections and move it in an "Operational" folder
#
#############################################################################

#Load Configuration Manager PowerShell Module
Import-module ($Env:SMS_ADMIN_UI_PATH.Substring(0,$Env:SMS_ADMIN_UI_PATH.Length-5) + '\ConfigurationManager.psd1')

#Get SiteCode
$SiteCode = Get-PSDrive -PSProvider CMSITE
Set-location $SiteCode":"

#Refresh Schedule
$Schedule = New-CMSchedule –RecurInterval Days –RecurCount 7

#List of Collections Query
$Collection1 = @{Name = "All Clients"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.Client = 1"}
$Collection2 = @{Name = "All Clients Inactive"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_CH_ClientSummary on SMS_G_System_CH_ClientSummary.ResourceId = SMS_R_System.ResourceId where SMS_G_System_CH_ClientSummary.ClientActiveStatus = 0 and SMS_R_System.Client = 1 and SMS_R_System.Obsolete = 0"}
$Collection3 = @{Name = "All Clients Active"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_CH_ClientSummary on SMS_G_System_CH_ClientSummary.ResourceId = SMS_R_System.ResourceId where SMS_G_System_CH_ClientSummary.ClientActiveStatus = 1 and SMS_R_System.Client = 1 and SMS_R_System.Obsolete = 0"}
$Collection4 = @{Name = "All Clients Non R2 SP1 CU1"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ClientVersion != '5.00.8239.1203'"}
$Collection5 = @{Name = "All Clients Not Reporting HW since 14 days"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where ResourceId in (select SMS_R_System.ResourceID from SMS_R_System inner join SMS_G_System_WORKSTATION_STATUS on SMS_G_System_WORKSTATION_STATUS.ResourceID = SMS_R_System.ResourceId where DATEDIFF(dd,SMS_G_System_WORKSTATION_STATUS.LastHardwareScan,GetDate()) > 14)"}
$Collection6 = @{Name = "All Systems Non Client"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.Client = 0 OR SMS_R_System.Client is NULL"}
$Collection7 = @{Name = "All Systems Obsolete"; Query = "select *  from  SMS_R_System where SMS_R_System.Obsolete = 1"}
$Collection8 = @{Name = "All Workstations Active"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_CH_ClientSummary on SMS_G_System_CH_ClientSummary.ResourceId = SMS_R_System.ResourceId where (SMS_R_System.OperatingSystemNameandVersion like 'Microsoft Windows NT%Workstation%' or SMS_R_System.OperatingSystemNameandVersion = 'Windows 7 Entreprise 6.1') and SMS_G_System_CH_ClientSummary.ClientActiveStatus = 1 and SMS_R_System.Client = 1 and SMS_R_System.Obsolete = 0"}
$Collection9 = @{Name = "All Laptops"; Query = "select SMS_R_System.ResourceId, SMS_R_System.ResourceType, SMS_R_System.Name, SMS_R_System.SMSUniqueIdentifier, SMS_R_System.ResourceDomainORWorkgroup, SMS_R_System.Client from  SMS_R_System inner join SMS_G_System_SYSTEM_ENCLOSURE on SMS_G_System_SYSTEM_ENCLOSURE.ResourceID = SMS_R_System.ResourceId where SMS_G_System_SYSTEM_ENCLOSURE.ChassisTypes in ('8', '9', '10', '11', '12', '14', '18', '21')"}
$Collection10 = @{Name = "All Servers"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where OperatingSystemNameandVersion like '%Server%'"}
$Collection11 = @{Name = "All Servers Physical"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ResourceId not in (select SMS_R_SYSTEM.ResourceID from SMS_R_System inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_R_System.IsVirtualMachine = 'True') and SMS_R_System.OperatingSystemNameandVersion like 'Microsoft Windows NT%Server%'"}
$Collection12 = @{Name = "All Servers Virtual"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.IsVirtualMachine = 'True' and SMS_R_System.OperatingSystemNameandVersion like 'Microsoft Windows NT%Server%'"}
$Collection13 = @{Name = "All Workstations"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where OperatingSystemNameandVersion like '%Workstation%'"}
$Collection14 = @{Name = "All Windows 7 Workstations"; Query = "select SMS_R_System.ResourceID,SMS_R_System.ResourceType,SMS_R_System.Name,SMS_R_System.SMSUniqueIdentifier,SMS_R_System.ResourceDomainORWorkgroup,SMS_R_System.Client from SMS_R_System where OperatingSystemNameandVersion like '%Workstation 6.1%'"}
$Collection15 = @{Name = "All Windows 8 Workstations"; Query = "select SMS_R_System.ResourceID,SMS_R_System.ResourceType,SMS_R_System.Name,SMS_R_System.SMSUniqueIdentifier,SMS_R_System.ResourceDomainORWorkgroup,SMS_R_System.Client from SMS_R_System where OperatingSystemNameandVersion like '%Workstation 6.2%'"}
$Collection16 = @{Name = "All Windows 8.1 Workstations"; Query = "select SMS_R_System.ResourceID,SMS_R_System.ResourceType,SMS_R_System.Name,SMS_R_System.SMSUniqueIdentifier,SMS_R_System.ResourceDomainORWorkgroup,SMS_R_System.Client from SMS_R_System where OperatingSystemNameandVersion like '%Workstation 6.3%'"}
$Collection17 = @{Name = "All Windows XP Workstation"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System   where OperatingSystemNameandVersion like '%Workstation 5.1%' or OperatingSystemNameandVersion like '%Workstation 5.2%'"}
$Collection18 = @{Name = "All Windows 2008 and 2008 R2"; Query = "select SMS_R_System.ResourceID,SMS_R_System.ResourceType,SMS_R_System.Name,SMS_R_System.SMSUniqueIdentifier,SMS_R_System.ResourceDomainORWorkgroup,SMS_R_System.Client from SMS_R_System where OperatingSystemNameandVersion like '%Server 6.0%' or OperatingSystemNameandVersion like '%Server 6.1%'"}
$Collection19 = @{Name = "All Windows 2012 and 2012 R2"; Query = "select SMS_R_System.ResourceID,SMS_R_System.ResourceType,SMS_R_System.Name,SMS_R_System.SMSUniqueIdentifier,SMS_R_System.ResourceDomainORWorkgroup,SMS_R_System.Client from SMS_R_System where OperatingSystemNameandVersion like '%Server 6.2%' or OperatingSystemNameandVersion like '%Server 6.3%'"}
$Collection20 = @{Name = "All Windows 2003 and 2003 R2"; Query = "select SMS_R_System.ResourceID,SMS_R_System.ResourceType,SMS_R_System.Name,SMS_R_System.SMSUniqueIdentifier,SMS_R_System.ResourceDomainORWorkgroup,SMS_R_System.Client from SMS_R_System where OperatingSystemNameandVersion like '%Server 5.2%'"}
$Collection21 = @{Name = "All Systems Created Since 24h"; Query = "select SMS_R_System.Name, SMS_R_System.CreationDate FROM SMS_R_System WHERE DateDiff(dd,SMS_R_System.CreationDate, GetDate()) <= 1"}
$Collection22 = @{Name = "All Systems with SCCM Console"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_ADD_REMOVE_PROGRAMS on SMS_G_System_ADD_REMOVE_PROGRAMS.ResourceID = SMS_R_System.ResourceId where SMS_G_System_ADD_REMOVE_PROGRAMS.DisplayName like '%Configuration Manager Console%'"}
$Collection23 = @{Name = "All SCCM Site System"; Query = "select SMS_R_System.ResourceId, SMS_R_System.ResourceType, SMS_R_System.Name, SMS_R_System.SMSUniqueIdentifier, SMS_R_System.ResourceDomainORWorkgroup, SMS_R_System.Client from  SMS_R_System where SMS_R_System.SystemRoles = 'SMS Site System'"}
$Collection24 = @{Name = "All SCCM Site Server"; Query = "select SMS_R_System.ResourceId, SMS_R_System.ResourceType, SMS_R_System.Name, SMS_R_System.SMSUniqueIdentifier, SMS_R_System.ResourceDomainORWorkgroup, SMS_R_System.Client from  SMS_R_System where SMS_R_System.SystemRoles = 'SMS Site Server'"}
$Collection25 = @{Name = "All SCCM Distribution Points"; Query = "select SMS_R_System.ResourceId, SMS_R_System.ResourceType, SMS_R_System.Name, SMS_R_System.SMSUniqueIdentifier, SMS_R_System.ResourceDomainORWorkgroup, SMS_R_System.Client from  SMS_R_System where SMS_R_System.SystemRoles = 'SMS Distribution Point'"}
$Collection26 = @{Name = "All Windows Update Agent Version Outdated - Win7 RTM and lower"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_WINDOWSUPDATEAGENTVERSION on SMS_G_System_WINDOWSUPDATEAGENTVERSION.ResourceID = SMS_R_System.ResourceId inner join SMS_G_System_OPERATING_SYSTEM on SMS_G_System_OPERATING_SYSTEM.ResourceID = SMS_R_System.ResourceId where SMS_G_System_WINDOWSUPDATEAGENTVERSION.Version < '7.6.7600.256' and SMS_G_System_OPERATING_SYSTEM.Version <= '6.1.7600'"}
$Collection27 = @{Name = "All Windows Update Agent Version Outdated - Win7 SP1 and higher"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_WINDOWSUPDATEAGENTVERSION on SMS_G_System_WINDOWSUPDATEAGENTVERSION.ResourceID = SMS_R_System.ResourceId inner join SMS_G_System_OPERATING_SYSTEM on SMS_G_System_OPERATING_SYSTEM.ResourceID = SMS_R_System.ResourceId where SMS_G_System_WINDOWSUPDATEAGENTVERSION.Version < '7.6.7600.320' and SMS_G_System_OPERATING_SYSTEM.Version >= '6.1.7601'"}
$Collection28 = @{Name = "Mobile Devices - All Android"; Query = "SELECT SMS_R_System.ResourceId, SMS_R_System.ResourceType, SMS_R_System.Name, SMS_R_System.SMSUniqueIdentifier, SMS_R_System.ResourceDomainORWorkgroup, SMS_R_System.Client FROM SMS_R_System INNER JOIN SMS_G_System_DEVICE_OSINFORMATION ON SMS_G_System_DEVICE_OSINFORMATION.ResourceID = SMS_R_System.ResourceId WHERE SMS_G_System_DEVICE_OSINFORMATION.Platform like 'Android%'"}
$Collection29 = @{Name = "Mobile Devices - All Iphone"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_DEVICE_COMPUTERSYSTEM on SMS_G_System_DEVICE_COMPUTERSYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_G_System_DEVICE_COMPUTERSYSTEM.DeviceModel like '%Iphone%'"}
$Collection30 = @{Name = "Mobile Devices - All Ipad"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_DEVICE_COMPUTERSYSTEM on SMS_G_System_DEVICE_COMPUTERSYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_G_System_DEVICE_COMPUTERSYSTEM.DeviceModel like '%Ipad%'"}
$Collection31 = @{Name = "Mobile Devices - All Windows 8"; Query = "select SMS_R_System.ResourceId, SMS_R_System.ResourceType, SMS_R_System.Name, SMS_R_System.SMSUniqueIdentifier, SMS_R_System.ResourceDomainORWorkgroup, SMS_R_System.Client from SMS_R_System inner join SMS_G_System_DEVICE_OSINFORMATION on SMS_G_System_DEVICE_OSINFORMATION.ResourceID = SMS_R_System.ResourceId where SMS_G_System_DEVICE_OSINFORMATION.Platform like 'Windows Phone' and SMS_G_System_DEVICE_OSINFORMATION.Version like '8.0%'"}
$Collection32 = @{Name = "Mobile Devices - All Windows 8.1"; Query = "select SMS_R_System.ResourceId, SMS_R_System.ResourceType, SMS_R_System.Name, SMS_R_System.SMSUniqueIdentifier, SMS_R_System.ResourceDomainORWorkgroup, SMS_R_System.Client from SMS_R_System inner join SMS_G_System_DEVICE_OSINFORMATION on SMS_G_System_DEVICE_OSINFORMATION.ResourceID = SMS_R_System.ResourceId where SMS_G_System_DEVICE_OSINFORMATION.Platform like 'Windows Phone' and SMS_G_System_DEVICE_OSINFORMATION.Version like '8.1%'"}
$Collection33 = @{Name = "Mobile Devices - All Windows RT"; Query = "select SMS_R_System.ResourceId, SMS_R_System.ResourceType, SMS_R_System.Name, SMS_R_System.SMSUniqueIdentifier, SMS_R_System.ResourceDomainORWorkgroup, SMS_R_System.Client from SMS_R_System inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_G_System_COMPUTER_SYSTEM.Model like 'Surface%'"}
$Collection34 = @{Name = "All Systems Disabled"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.UserAccountControl ='4098'"}
$Collection35 = @{Name = "All Clients x86"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceID = SMS_R_System.ResourceId where SMS_G_System_COMPUTER_SYSTEM.SystemType = 'X86-based PC'"}
$Collection36 = @{Name = "All Clients x64"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceID = SMS_R_System.ResourceId where SMS_G_System_COMPUTER_SYSTEM.SystemType = 'X64-based PC'"}
$Collection37 = @{Name = "All Clients R2 CU1"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ClientVersion = '5.00.7958.1203'"}
$Collection38 = @{Name = "All Clients R2 CU2"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ClientVersion = '5.00.7958.1303'"}
$Collection39 = @{Name = "All Clients R2 CU3"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ClientVersion = '5.00.7958.1401'"}
$Collection40 = @{Name = "All Clients R2 CU4"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ClientVersion = '5.00.7958.1501'"}
$Collection41 = @{Name = "All Clients R2 CU5"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ClientVersion = '5.00.7958.1604'"}
$Collection42 = @{Name = "All Clients R2 CU0"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ClientVersion = '5.00.7958.1000'"}
$Collection43 = @{Name = "All Clients R2 SP1"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ClientVersion = '5.00.8239.1000'"}
$Collection44 = @{Name = "All Clients R2 SP1 CU1"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ClientVersion = '5.00.8239.1203'"}
$Collection45 = @{Name = "All Windows 10 Workstations"; Query = "select SMS_R_System.ResourceID,SMS_R_System.ResourceType,SMS_R_System.Name,SMS_R_System.SMSUniqueIdentifier,SMS_R_System.ResourceDomainORWorkgroup,SMS_R_System.Client from SMS_R_System where OperatingSystemNameandVersion like '%Workstation 10.0%'"}

#Create Defaut Folder 
$CollectionFolder = @{Name = "Operational"; ObjectType = 5000; ParentContainerNodeId = 0}
Set-WmiInstance -Namespace "root\sms\site_$($SiteCode.Name)" -Class "SMS_ObjectContainerNode" -Arguments $CollectionFolder

#Create Default limiting collections
$LimitingCollection = "All Systems"

#Create Collection

New-CMDeviceCollection -Name $Collection1.Name -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection1.Name -QueryExpression $Collection1.Query -RuleName $Collection1.Name

New-CMDeviceCollection -Name $Collection2.Name -LimitingCollectionName $Collection1.Name -RefreshSchedule $Schedule -RefreshType 2
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection2.Name -QueryExpression $Collection2.Query -RuleName $Collection2.Name

New-CMDeviceCollection -Name $Collection3.Name -LimitingCollectionName $Collection1.Name -RefreshSchedule $Schedule -RefreshType 2
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection3.Name -QueryExpression $Collection3.Query -RuleName $Collection3.Name

New-CMDeviceCollection -Name $Collection4.Name -LimitingCollectionName $Collection1.Name -RefreshSchedule $Schedule -RefreshType 2
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection4.Name -QueryExpression $Collection4.Query -RuleName $Collection4.Name

New-CMDeviceCollection -Name $Collection5.Name -LimitingCollectionName $Collection1.Name -RefreshSchedule $Schedule -RefreshType 2
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection5.Name -QueryExpression $Collection5.Query -RuleName $Collection5.Name

New-CMDeviceCollection -Name $Collection6.Name -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection6.Name -QueryExpression $Collection6.Query -RuleName $Collection6.Name

New-CMDeviceCollection -Name $Collection7.Name -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection7.Name -QueryExpression $Collection7.Query -RuleName $Collection7.Name

New-CMDeviceCollection -Name $Collection8.Name -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection8.Name -QueryExpression $Collection8.Query -RuleName $Collection8.Name

New-CMDeviceCollection -Name $Collection9.Name -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection9.Name -QueryExpression $Collection9.Query -RuleName $Collection9.Name

New-CMDeviceCollection -Name $Collection10.Name -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection10.Name -QueryExpression $Collection10.Query -RuleName $Collection10.Name

New-CMDeviceCollection -Name $Collection11.Name -LimitingCollectionName $Collection10.Name -RefreshSchedule $Schedule -RefreshType 2
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection11.Name -QueryExpression $Collection11.Query -RuleName $Collection11.Name

New-CMDeviceCollection -Name $Collection12.Name -LimitingCollectionName $Collection10.Name -RefreshSchedule $Schedule -RefreshType 2
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection12.Name -QueryExpression $Collection12.Query -RuleName $Collection12.Name

New-CMDeviceCollection -Name $Collection13.Name -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection13.Name -QueryExpression $Collection13.Query -RuleName $Collection13.Name

New-CMDeviceCollection -Name $Collection14.Name -LimitingCollectionName $Collection13.Name -RefreshSchedule $Schedule -RefreshType 2
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection14.Name -QueryExpression $Collection14.Query -RuleName $Collection14.Name

New-CMDeviceCollection -Name $Collection15.Name -LimitingCollectionName $Collection13.Name -RefreshSchedule $Schedule -RefreshType 2
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection15.Name -QueryExpression $Collection15.Query -RuleName $Collection15.Name

New-CMDeviceCollection -Name $Collection16.Name -LimitingCollectionName $Collection13.Name -RefreshSchedule $Schedule -RefreshType 2
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection16.Name -QueryExpression $Collection16.Query -RuleName $Collection16.Name

New-CMDeviceCollection -Name $Collection17.Name -LimitingCollectionName $Collection13.Name -RefreshSchedule $Schedule -RefreshType 2
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection17.Name -QueryExpression $Collection17.Query -RuleName $Collection17.Name

New-CMDeviceCollection -Name $Collection18.Name -LimitingCollectionName $Collection10.Name -RefreshSchedule $Schedule -RefreshType 2
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection18.Name -QueryExpression $Collection18.Query -RuleName $Collection18.Name

New-CMDeviceCollection -Name $Collection19.Name -LimitingCollectionName $Collection10.Name -RefreshSchedule $Schedule -RefreshType 2
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection19.Name -QueryExpression $Collection19.Query -RuleName $Collection19.Name

New-CMDeviceCollection -Name $Collection20.Name -LimitingCollectionName $Collection10.Name -RefreshSchedule $Schedule -RefreshType 2
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection20.Name -QueryExpression $Collection20.Query -RuleName $Collection20.Name

New-CMDeviceCollection -Name $Collection21.Name -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection21.Name -QueryExpression $Collection21.Query -RuleName $Collection21.Name

New-CMDeviceCollection -Name $Collection22.Name -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection22.Name -QueryExpression $Collection22.Query -RuleName $Collection22.Name

New-CMDeviceCollection -Name $Collection23.Name -LimitingCollectionName $Collection10.Name -RefreshSchedule $Schedule -RefreshType 2
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection23.Name -QueryExpression $Collection23.Query -RuleName $Collection23.Name

New-CMDeviceCollection -Name $Collection24.Name -LimitingCollectionName $Collection10.Name -RefreshSchedule $Schedule -RefreshType 2
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection24.Name -QueryExpression $Collection24.Query -RuleName $Collection24.Name

New-CMDeviceCollection -Name $Collection25.Name -LimitingCollectionName $Collection10.Name -RefreshSchedule $Schedule -RefreshType 2
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection25.Name -QueryExpression $Collection25.Query -RuleName $Collection25.Name

New-CMDeviceCollection -Name $Collection26.Name -LimitingCollectionName $Collection13.Name -RefreshSchedule $Schedule -RefreshType 2
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection26.Name -QueryExpression $Collection26.Query -RuleName $Collection26.Name

New-CMDeviceCollection -Name $Collection27.Name -LimitingCollectionName $Collection13.Name -RefreshSchedule $Schedule -RefreshType 2
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection27.Name -QueryExpression $Collection27.Query -RuleName $Collection27.Name

New-CMDeviceCollection -Name $Collection28.Name -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection28.Name -QueryExpression $Collection28.Query -RuleName $Collection28.Name

New-CMDeviceCollection -Name $Collection29.Name -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection29.Name -QueryExpression $Collection29.Query -RuleName $Collection29.Name

New-CMDeviceCollection -Name $Collection30.Name -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection30.Name -QueryExpression $Collection30.Query -RuleName $Collection30.Name

New-CMDeviceCollection -Name $Collection31.Name -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection31.Name -QueryExpression $Collection31.Query -RuleName $Collection31.Name

New-CMDeviceCollection -Name $Collection32.Name -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection32.Name -QueryExpression $Collection32.Query -RuleName $Collection32.Name

New-CMDeviceCollection -Name $Collection33.Name -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection33.Name -QueryExpression $Collection33.Query -RuleName $Collection33.Name

New-CMDeviceCollection -Name $Collection34.Name -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection34.Name -QueryExpression $Collection34.Query -RuleName $Collection34.Name

New-CMDeviceCollection -Name $Collection35.Name -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection35.Name -QueryExpression $Collection35.Query -RuleName $Collection35.Name

New-CMDeviceCollection -Name $Collection36.Name -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection36.Name -QueryExpression $Collection36.Query -RuleName $Collection36.Name

New-CMDeviceCollection -Name $Collection37.Name -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection37.Name -QueryExpression $Collection37.Query -RuleName $Collection37.Name

New-CMDeviceCollection -Name $Collection38.Name -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection38.Name -QueryExpression $Collection38.Query -RuleName $Collection38.Name

New-CMDeviceCollection -Name $Collection39.Name -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection39.Name -QueryExpression $Collection39.Query -RuleName $Collection39.Name

New-CMDeviceCollection -Name $Collection40.Name -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection40.Name -QueryExpression $Collection40.Query -RuleName $Collection40.Name

New-CMDeviceCollection -Name $Collection41.Name -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection41.Name -QueryExpression $Collection41.Query -RuleName $Collection41.Name

New-CMDeviceCollection -Name $Collection42.Name -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection42.Name -QueryExpression $Collection42.Query -RuleName $Collection42.Name

New-CMDeviceCollection -Name $Collection43.Name -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection43.Name -QueryExpression $Collection43.Query -RuleName $Collection43.Name

New-CMDeviceCollection -Name $Collection44.Name -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection44.Name -QueryExpression $Collection44.Query -RuleName $Collection44.Name

New-CMDeviceCollection -Name $Collection45.Name -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection45.Name -QueryExpression $Collection45.Query -RuleName $Collection45.Name

#Move the collection to the right folder
$FolderPath = $SiteCode.Name + ":\DeviceCollection\" + $CollectionFolder.Name
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection1.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection2.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection3.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection4.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection5.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection6.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection7.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection8.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection9.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection10.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection11.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection12.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection13.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection14.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection15.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection16.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection17.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection18.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection19.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection20.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection21.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection22.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection23.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection24.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection25.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection26.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection27.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection28.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection29.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection30.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection31.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection32.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection33.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection34.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection35.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection36.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection37.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection38.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection39.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection40.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection41.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection42.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection43.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection44.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection45.Name)

Write-host "Completed !" -ForegroundColor WHITE