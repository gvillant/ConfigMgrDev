<#
.SYNOPSIS
	Script to set the "Create Collections for OSD TS Customer Deployment"
.DESCRIPTION
	The script will build collection and TS deployment for multiples scenarios Replace, Refresh, Restore, forced ...
.PARAMETER SMSProvider
    Hostname or FQDN of a SMSProvider in the Hierarchy 
    This parameter is optional
.EXAMPLE
	PS C:\PSScript > .\Build-OSDPlanning.ps1 -TargetDate 09/21/2014
    This will use 21 September 2014 as the target date .
.INPUTS
	None.  You cannot pipe objects to this script.
.OUTPUTS
	No objects are output from this script. 
.LINK
	http://www.dell.com
.NOTES
	NAME: Build-OSDPlanning.ps1
	VERSION: 1.1
	AUTHOR: Gaetan VILLANT @ Dell for STAGO
	LASTEDIT: September 17, 2014
    LASTEDIT: October 8, 2014
	Change history:
	v1.1: 10/08/2014 : added forced test refresh
.REMARKS
	To see the examples, type: "Get-Help .\set-PackagePrestageDLBehavior.ps1 -examples".
	For more information, type: "Get-Help .\set-PackagePrestageDLBehavior.ps1 -detailed".
    This script will only work with Powershell 3.0.


param(
    [parameter(
	Position = 1, 
	Mandatory=$true )
	] 
	[Alias("SMS")]
	[ValidateNotNullOrEmpty()]
    [string]$SMSProvider = "",
    
    [parameter(
	Position = 2, 
	Mandatory=$true )
	] 
	[Alias("TD")]
	[ValidateNotNullOrEmpty()]
    [string]$TargetDate (ex: 09/21/2014)= ""
)
#>

param(
    [parameter(
	Position = 1, 
	Mandatory=$true )
	]
	[ValidateNotNullOrEmpty()]
    [DateTime]$TargetDate = "" 
)


$SMSProvider = "FRPSCM01.stago.grp"
#$TargetDate = "01/12/2014"

#######################################################################################
Function Import-Module-CM {
import-module ($Env:SMS_ADMIN_UI_PATH.Substring(0,$Env:SMS_ADMIN_UI_PATH.Length-5) + '\ConfigurationManager.psd1')
Get-SiteCode
Set-location $SiteCode":"
}
#######################################################################################

#######################################################################################
Function Get-SiteCode
{
    $wqlQuery = "SELECT * FROM SMS_ProviderLocation"
    $a = Get-WmiObject -Query $wqlQuery -Namespace "root\sms" -ComputerName $SMSProvider
    $a | ForEach-Object {
        if($_.ProviderForLocalSite)
            {
                $script:SiteCode = $_.SiteCode
            }
    }

Write-host "SMSProvider is $SMSProvider."
Write-host "SiteCode is $SiteCode."
return $SiteCode
}
#######################################################################################

#######################################################################################
function move-Collection($SourceContainerNodeID,$ColName,$TargetContainerNodeID)
{
$Class = "SMS_ObjectContainerItem"
$Method = "MoveMembers"
$Coll = Get-CMDeviceCollection -Name $ColName
$CollID = $Coll.CollectionID

$MCFull = "\\$SMSProvider\ROOT\SMS\site_" + $SiteCode + ":" + $Class

$MC = [WmiClass]$MCFull

$InParams = $mc.psbase.GetMethodParameters($Method)

$InParams.ContainerNodeID = $SourceContainerNodeID #usually 0 when newly created Collection
$InParams.InstanceKeys = $CollID
$InParams.ObjectType = "5000" #5000 for Collection_Device, 5001 for Collection_User
$InParams.TargetContainerNodeID = $TargetContainerNodeID #needs to be evaluated

"Calling SMS_ObjectContainerItem. : MoveMembers with Parameters :"
$inparams.PSBase.properties | select name,Value | format-Table

$R = $mc.PSBase.InvokeMethod($Method, $inParams, $Null)
}

#$SourceContainerNodeID = "0" #usually 0 when newly created Collection
#$TargetContainerNodeID = #Needs to be evaluated, depending on where you want to put the collection!

#######################################################################################

Import-Module-CM

#Check and confirm date format
Write-host "Target Date is $TargetDate"
$ValidTargetDate = [dateTime]::Parse($TargetDate,([Globalization.CultureInfo]::CreateSpecificCulture('en-US')))
$TargetDate = Get-Date $ValidTargetDate
$FullTargetDate = Get-Date $TargetDate -format "dddd dd MMMM yyyy"
$ColPrefix = Get-Date $TargetDate -format "yyMMdd"

Write-host "Provider is $SMSProvider"
Write-host "Valid Target Date is $ValidTargetDate"
Write-host "Target Date is $TargetDate"
Write-Host "Deployments will be created for $FullTargetDate" -ForegroundColor Green
Write-host "Collection Prefix is $ColPrefix"

#Read-Host 'Press Enter to continue...' | Out-Null

#Create Collections
#Global Collection Variables
$SiteTri = "GEN"
$ColPowerExcludeID = "STG003EE" #Powersettings to disable hibernate

#Folders
$FLDRefresh ="16777486"    # REFRESH
$FLDReplaceBKP ="16777488" # REPLACE BACKUP
$FLDReplaceRST ="16777489" # REPLACE RESTORE
$FLDRefreshTST ="16777563" # TEST BACKUP

#Global Deployment Variables

$AdvTSNameSpace = "root\sms\site_" + $SiteCode

$TSRefreshID = "STG00304"    # W7x64-03.04.11
$TSReplaceBKPID	= "STG000AA" # REPLACE - Backup TEST or MIGRATION (SMP Only)
$TSReplaceRSTID	= "STG00069" # RESTORE AFTER
$TSRefreshTSTID	= "STG00170" # REFRESH - Backup TEST (SMP + WIM) 

$TSRefreshTime1	        = $TargetDate.AddHours(-5.5)    # 
$TSRefreshExpTime1	    = $TargetDate.AddHours(+6)      # 
$TSRefreshTime2	        = $TargetDate.AddHours(+14.5)   # 
$TSRefreshExpTime2   	= $TargetDate.AddHours(+30)     #
$TSRefreshTime3     	= $TargetDate.AddHours(+6)      # 
$TSRefreshExpTime3  	= $TargetDate.AddHours(+72)     #

$TSReplaceBKPTime1	    = $TargetDate.AddHours(-5.5)    # 
$TSReplaceBKPExpTime1	= $TargetDate.AddHours(+3)      # 
$TSReplaceBKPTime2	    = $TargetDate.AddHours(+16)     # 
$TSReplaceBKPExpTime2	= $TargetDate.AddHours(+23)     #
$TSReplaceBKPTime3	    = $TargetDate.AddHours(+6)      # 
$TSReplaceBKPExpTime3	= $TargetDate.AddHours(+23)     #

$TSReplaceRSTTime1	    = $TargetDate.AddHours(+3)      # 
$TSReplaceRSTExpTime1	= $TargetDate.AddHours(+10)     # 
$TSReplaceRSTTime2	    = $TargetDate.AddHours(+23)     # 
$TSReplaceRSTExpTime2	= $TargetDate.AddHours(+34)     # 
$TSReplaceRSTTime3	    = $TargetDate.AddHours(+6)      # 
$TSReplaceRSTExpTime3	= $TargetDate.AddHours(+72)     # 

$TSRefreshTSTTime1  	= $TargetDate.AddHours(+18.5)   #  
$TSRefreshTSTExpTime1	= $TargetDate.AddHours(+30)     #
$TSRefreshTSTTime3  	= $TargetDate.AddHours(+6)      #  
$TSRefreshTSTExpTime3	= $TargetDate.AddHours(+20)     #

write-host "################## REFRESH ##################"
write-host "TSRefreshTime1       => $TSRefreshTime1"
write-host "TSRefreshExpTime1    => $TSRefreshExpTime1"
write-host "TSRefreshTime2       => $TSRefreshTime2"
write-host "TSRefreshExpTime2    => $TSRefreshExpTime2"
write-host "TSRefreshTime3       => $TSRefreshTime3"
write-host "TSRefreshExpTime3    => $TSRefreshExpTime3"

write-host "############### REPLACE BKP #################"
write-host "TSReplaceBKPTime1    => $TSReplaceBKPTime1"
write-host "TSReplaceBKPExpTime1 => $TSReplaceBKPExpTime1"
write-host "TSReplaceBKPTime2    => $TSReplaceBKPTime2"
write-host "TSReplaceBKPExpTime2 => $TSReplaceBKPExpTime2"
write-host "TSReplaceBKPTime3    => $TSReplaceBKPTime3"
write-host "TSReplaceBKPExpTime3 => $TSReplaceBKPExpTime3"

write-host "############### REPLACE RST #################"
write-host "TSReplaceRSTTime1    => $TSReplaceRSTTime1"
write-host "TSReplaceRSTExpTime1 => $TSReplaceRSTExpTime1"
write-host "TSReplaceRSTTime2    => $TSReplaceRSTTime2"
write-host "TSReplaceRSTExpTime2 => $TSReplaceRSTExpTime2"
write-host "TSReplaceRSTTime3    => $TSReplaceRSTTime3"
write-host "TSReplaceRSTExpTime3 => $TSReplaceRSTExpTime3"

write-host "############### REFRESH TST #################"
write-host "TSRefreshTSTTime1    => $TSRefreshTSTTime1"
write-host "TSRefreshTSTExpTime1 => $TSRefreshTSTExpTime1"
write-host "TSRefreshTSTTime3    => $TSRefreshTSTTime3"
write-host "TSRefreshTSTExpTime3 => $TSRefreshTSTExpTime3"




Write-host "Start Collection processing" -ForegroundColor Green

############################################################################

$TargetContainerNodeID = $FLDRefresh

#Collection 9h REFRESH GEN
$Scenario = "REFRESH - VIP"
$TimeTri = "09H"
$ComputerBackupLocation = "\\FRSCM05\VIP$"
$UserDataLocation = "LOCAL"
$ColName = $ColPrefix + " - " + $TimeTri + " - " + $Scenario + " - " + $SiteTri
$TSID = $TSRefreshID

Write-host "Creating Collection : $ColName" -ForegroundColor Cyan
New-CMDeviceCollection -RefreshType ConstantUpdate -LimitingCollectionName "All Desktop and Server Clients" -Name $ColName
New-CMDeviceCollectionVariable -CollectionName $ColName -VariableName ComputerBackupLocation -VariableValue $ComputerBackupLocation
New-CMDeviceCollectionVariable -CollectionName $ColName -VariableName UserDataLocation -VariableValue $UserDataLocation
New-CMDeviceCollectionVariable -CollectionName $ColName -VariableName VipRefresh -VariableValue "TRUE"
New-CMDeviceCollectionVariable -CollectionName $ColName -VariableName BackupFile -VariableValue "%OSDComputerName%.wim"

#Adding collection to PWR collection to disable hibernate
Write-Host "Adding Collection $ColName to collection PWR-MI7-Migration (STG003EE)"  -ForegroundColor Cyan
Add-CMDeviceCollectionIncludeMembershipRule -CollectionID $ColPowerExcludeID -IncludeCollectionName $ColName

Write-Host "Moving Collection $ColName to folder $TargetContainerNodeID"  -ForegroundColor DarkCyan
move-Collection 0 $ColName $TargetContainerNodeID

#Deploy TS 9h REFRESH GEN
$Schedule = New-CMSchedule -Start $TSRefreshTime1 -Nonrecurring
$ScheduleAV = $TSRefreshTime1
$ScheduleEXP = $TSRefreshExpTime1

Write-Host "Deploy $TSID @ time $TargetDate on Collection $ColName" -ForegroundColor Cyan
Start-CMTaskSequenceDeployment -CollectionName $ColName -TaskSequencePackageId $TSID -ScheduleEvent AsSoonAsPossible -DeploymentAvailableDay $ScheduleAV -DeploymentAvailableTime $ScheduleAV -DeploymentExpireDay $ScheduleEXP -DeploymentExpireTime $ScheduleEXP -AllowUsersRunIndependently $True -DeployPurpose Required -MakeAvailableTo Clients -RerunBehavior RerunIfFailedPreviousAttempt -ShowTaskSequenceProgress $True

#Fix Ghost Deployment > rewrite ProgramName 
$Coll = Get-CMDeviceCollection -Name $ColName
$CollID = $Coll.CollectionID
$AdvTS = gwmi -namespace $AdvTSNameSpace -ComputerName $SMSProvider -class SMS_Advertisement -filter "Packageid='$TSID' AND CollectionID='$CollID'"
$AdvID = $AdvTS.AdvertisementID
$AdvTS.ProgramName="*"
$AdvTS.put()
Set-CMTaskSequenceDeployment -TaskSequenceDeploymentId $AdvID -DeploymentExpireDay $ScheduleEXP -DeploymentExpireTime $ScheduleEXP

############################################################################

############################################################################
#Collection 14h REFRESH GEN
$Scenario = "REFRESH - VIP"
$TimeTri = "14H"
$ComputerBackupLocation = "\\FRSCM04\VIP$"
$UserDataLocation = "LOCAL"
$ColName = $ColPrefix + " - " + $TimeTri + " - " + $Scenario + " - " + $SiteTri
$TSID = $TSRefreshID

Write-host "Creating Collection : $ColName" -ForegroundColor Cyan
New-CMDeviceCollection -RefreshType ConstantUpdate -LimitingCollectionName "All Desktop and Server Clients" -Name $ColName
New-CMDeviceCollectionVariable -CollectionName $ColName -VariableName ComputerBackupLocation -VariableValue $ComputerBackupLocation
New-CMDeviceCollectionVariable -CollectionName $ColName -VariableName UserDataLocation -VariableValue $UserDataLocation
New-CMDeviceCollectionVariable -CollectionName $ColName -VariableName VipRefresh -VariableValue "TRUE"
New-CMDeviceCollectionVariable -CollectionName $ColName -VariableName BackupFile -VariableValue "%OSDComputerName%.wim"

#Adding collection to PWR collection to disable hibernate
Write-Host "Adding Collection $ColName to collection PWR-MI7-Migration (STG003EE)"  -ForegroundColor Cyan
Add-CMDeviceCollectionIncludeMembershipRule -CollectionID $ColPowerExcludeID -IncludeCollectionName $ColName

Write-Host "Moving Collection $ColName to folder $TargetContainerNodeID"  -ForegroundColor DarkCyan
move-Collection 0 $ColName $TargetContainerNodeID

#Deploy TS 
$Schedule = New-CMSchedule -Start $TSRefreshTime2 -Nonrecurring
$ScheduleAV = $TSRefreshTime2
$ScheduleEXP = $TSRefreshExpTime2

Write-Host "Deploy $TSID @ time $TargetDate on Collection $ColName" -ForegroundColor Cyan
Start-CMTaskSequenceDeployment -CollectionName $ColName -TaskSequencePackageId $TSID -ScheduleEvent AsSoonAsPossible -DeploymentAvailableDay $ScheduleAV -DeploymentAvailableTime $ScheduleAV -DeploymentExpireDay $ScheduleEXP -DeploymentExpireTime $ScheduleEXP -AllowUsersRunIndependently $True -DeployPurpose Required -MakeAvailableTo Clients -RerunBehavior RerunIfFailedPreviousAttempt -ShowTaskSequenceProgress $True

#Fix Ghost Deployment > rewrite ProgramName 
$Coll = Get-CMDeviceCollection -Name $ColName
$CollID = $Coll.CollectionID
$AdvTS = gwmi -namespace $AdvTSNameSpace -ComputerName $SMSProvider -class SMS_Advertisement -filter "Packageid='$TSID' AND CollectionID='$CollID'"
$AdvID = $AdvTS.AdvertisementID
$AdvTS.ProgramName="*"
$AdvTS.put()
Set-CMTaskSequenceDeployment -TaskSequenceDeploymentId $AdvID -DeploymentExpireDay $ScheduleEXP -DeploymentExpireTime $ScheduleEXP

############################################################################

############################################################################
#Collection FORCED REFRESH GEN
$Scenario = "REFRESH - VIP"
$TimeTri = "FORCED"
$ComputerBackupLocation = "\\FRSCM04\VIP$"
$UserDataLocation = "LOCAL"
$ColName = $ColPrefix + " - " + $TimeTri + " - " + $Scenario + " - " + $SiteTri
$TSID = $TSRefreshID

Write-host "Creating Collection : $ColName" -ForegroundColor Cyan
New-CMDeviceCollection -RefreshType ConstantUpdate -LimitingCollectionName "All Desktop and Server Clients" -Name $ColName
New-CMDeviceCollectionVariable -CollectionName $ColName -VariableName ComputerBackupLocation -VariableValue $ComputerBackupLocation
New-CMDeviceCollectionVariable -CollectionName $ColName -VariableName UserDataLocation -VariableValue $UserDataLocation
New-CMDeviceCollectionVariable -CollectionName $ColName -VariableName VipRefresh -VariableValue "TRUE"
New-CMDeviceCollectionVariable -CollectionName $ColName -VariableName BackupFile -VariableValue "%OSDComputerName%.wim"

#Adding collection to PWR collection to disable hibernate
Write-Host "Adding Collection $ColName to collection PWR-MI7-Migration (STG003EE)"  -ForegroundColor Cyan
Add-CMDeviceCollectionIncludeMembershipRule -CollectionID $ColPowerExcludeID -IncludeCollectionName $ColName

Write-Host "Moving Collection $ColName to folder $TargetContainerNodeID"  -ForegroundColor DarkCyan
move-Collection 0 $ColName $TargetContainerNodeID

#Deploy TS 
$Schedule = New-CMSchedule -Start $TSRefreshTime3 -Nonrecurring
$ScheduleAV = $TSRefreshTime3
$ScheduleEXP = $TSRefreshExpTime3

Write-Host "Deploy $TSID @ time $TargetDate on Collection $ColName" -ForegroundColor Cyan
Start-CMTaskSequenceDeployment -CollectionName $ColName -TaskSequencePackageId $TSID -ScheduleEvent AsSoonAsPossible -DeploymentAvailableDay $ScheduleAV -DeploymentAvailableTime $ScheduleAV -DeploymentExpireDay $ScheduleEXP -DeploymentExpireTime $ScheduleEXP -AllowUsersRunIndependently $True -DeployPurpose Required -MakeAvailableTo Clients -RerunBehavior RerunIfFailedPreviousAttempt -ShowTaskSequenceProgress $True

#Fix Ghost Deployment > rewrite ProgramName 
$Coll = Get-CMDeviceCollection -Name $ColName
$CollID = $Coll.CollectionID
$AdvTS = gwmi -namespace $AdvTSNameSpace -ComputerName $SMSProvider -class SMS_Advertisement -filter "Packageid='$TSID' AND CollectionID='$CollID'"
$AdvID = $AdvTS.AdvertisementID
$AdvTS.ProgramName="*"
$AdvTS.put()
Set-CMTaskSequenceDeployment -TaskSequenceDeploymentId $AdvID -DeploymentExpireDay $ScheduleEXP -DeploymentExpireTime $ScheduleEXP


############################################################################

############################################################################

$TargetContainerNodeID = $FLDReplaceBKP

#Collection 9h REPLACE BKP GEN
$Scenario = "REPLACE - BKP"
$TimeTri = "09H"
$ColName = $ColPrefix + " - " + $TimeTri + " - " + $Scenario + " - " + $SiteTri
$TSID = $TSReplaceBKPID

Write-host "Creating Collection : $ColName" -ForegroundColor Cyan
New-CMDeviceCollection -RefreshType ConstantUpdate -LimitingCollectionName "All Desktop and Server Clients" -Name $ColName
New-CMDeviceCollectionVariable -CollectionName $ColName -VariableName DisableOldComputerNAme -VariableValue "TRUE"

#Adding collection to PWR collection to disable hibernate
Write-Host "Adding Collection $ColName to collection PWR-MI7-Migration (STG003EE)"  -ForegroundColor Cyan
Add-CMDeviceCollectionIncludeMembershipRule -CollectionID $ColPowerExcludeID -IncludeCollectionName $ColName

Write-Host "Moving Collection $ColName to folder $TargetContainerNodeID"  -ForegroundColor DarkCyan
move-Collection 0 $ColName $TargetContainerNodeID

#Deploy TS
$Schedule = New-CMSchedule -Start $TSReplaceBKPTime1 -Nonrecurring
$ScheduleAV = $TSReplaceBKPTime1
$ScheduleEXP = $TSReplaceBKPExpTime1

Write-Host "Deploy $TSID @ time $TargetDate on Collection $ColName" -ForegroundColor Cyan
Start-CMTaskSequenceDeployment -CollectionName $ColName -TaskSequencePackageId $TSID -ScheduleEvent AsSoonAsPossible -DeploymentAvailableDay $ScheduleAV -DeploymentAvailableTime $ScheduleAV -DeploymentExpireDay $ScheduleEXP -DeploymentExpireTime $ScheduleEXP -AllowUsersRunIndependently $True -DeployPurpose Required -MakeAvailableTo Clients -RerunBehavior AlwaysRerunProgram -ShowTaskSequenceProgress $True

#Fix Ghost Deployment > rewrite ProgramName 
$Coll = Get-CMDeviceCollection -Name $ColName
$CollID = $Coll.CollectionID
$AdvTS = gwmi -namespace $AdvTSNameSpace -ComputerName $SMSProvider -class SMS_Advertisement -filter "Packageid='$TSID' AND CollectionID='$CollID'"
$AdvID = $AdvTS.AdvertisementID
$AdvTS.ProgramName="*"
$AdvTS.put()
Set-CMTaskSequenceDeployment -TaskSequenceDeploymentId $AdvID -DeploymentExpireDay $ScheduleEXP -DeploymentExpireTime $ScheduleEXP


############################################################################

############################################################################
#Collection 14h REPLACE BKP GEN
$Scenario = "REPLACE - BKP"
$TimeTri = "14H"
$ColName = $ColPrefix + " - " + $TimeTri + " - " + $Scenario + " - " + $SiteTri
$TSID = $TSReplaceBKPID

Write-host "Creating Collection : $ColName" -ForegroundColor Cyan
New-CMDeviceCollection -RefreshType ConstantUpdate -LimitingCollectionName "All Desktop and Server Clients" -Name $ColName
New-CMDeviceCollectionVariable -CollectionName $ColName -VariableName DisableOldComputerNAme -VariableValue "TRUE"

#Adding collection to PWR collection to disable hibernate
Write-Host "Adding Collection $ColName to collection PWR-MI7-Migration (STG003EE)"  -ForegroundColor Cyan
Add-CMDeviceCollectionIncludeMembershipRule -CollectionID $ColPowerExcludeID -IncludeCollectionName $ColName

Write-Host "Moving Collection $ColName to folder $TargetContainerNodeID"  -ForegroundColor DarkCyan
move-Collection 0 $ColName $TargetContainerNodeID

#Deploy TS
$Schedule = New-CMSchedule -Start $TSReplaceBKPTime2 -Nonrecurring
$ScheduleAV = $TSReplaceBKPTime2
$ScheduleEXP = $TSReplaceBKPExpTime2

Write-Host "Deploy $TSID @ time $TargetDate on Collection $ColName" -ForegroundColor Cyan
Start-CMTaskSequenceDeployment -CollectionName $ColName -TaskSequencePackageId $TSID -ScheduleEvent AsSoonAsPossible -DeploymentAvailableDay $ScheduleAV -DeploymentAvailableTime $ScheduleAV -DeploymentExpireDay $ScheduleEXP -DeploymentExpireTime $ScheduleEXP -AllowUsersRunIndependently $True -DeployPurpose Required -MakeAvailableTo Clients -RerunBehavior AlwaysRerunProgram -ShowTaskSequenceProgress $True

#Fix Ghost Deployment > rewrite ProgramName 
$Coll = Get-CMDeviceCollection -Name $ColName
$CollID = $Coll.CollectionID
$AdvTS = gwmi -namespace $AdvTSNameSpace -ComputerName $SMSProvider -class SMS_Advertisement -filter "Packageid='$TSID' AND CollectionID='$CollID'"
$AdvID = $AdvTS.AdvertisementID
$AdvTS.ProgramName="*"
$AdvTS.put()
Set-CMTaskSequenceDeployment -TaskSequenceDeploymentId $AdvID -DeploymentExpireDay $ScheduleEXP -DeploymentExpireTime $ScheduleEXP


############################################################################

############################################################################
#Collection FORCED REPLACE BKP GEN
$Scenario = "REPLACE - BKP"
$TimeTri = "FORCED"
$ColName = $ColPrefix + " - " + $TimeTri + " - " + $Scenario + " - " + $SiteTri
$TSID = $TSReplaceBKPID

Write-host "Creating Collection : $ColName" -ForegroundColor Cyan
New-CMDeviceCollection -RefreshType ConstantUpdate -LimitingCollectionName "All Desktop and Server Clients" -Name $ColName
New-CMDeviceCollectionVariable -CollectionName $ColName -VariableName DisableOldComputerNAme -VariableValue "TRUE"

#Adding collection to PWR collection to disable hibernate
Write-Host "Adding Collection $ColName to collection PWR-MI7-Migration (STG003EE)"  -ForegroundColor Cyan
Add-CMDeviceCollectionIncludeMembershipRule -CollectionID $ColPowerExcludeID -IncludeCollectionName $ColName

Write-Host "Moving Collection $ColName to folder $TargetContainerNodeID"  -ForegroundColor DarkCyan
move-Collection 0 $ColName $TargetContainerNodeID

#Deploy TS
$Schedule = New-CMSchedule -Start $TSReplaceBKPTime3 -Nonrecurring
$ScheduleAV = $TSReplaceBKPTime3
$ScheduleEXP = $TSReplaceBKPExpTime3

Write-Host "Deploy $TSID @ time $TargetDate on Collection $ColName" -ForegroundColor Cyan
Start-CMTaskSequenceDeployment -CollectionName $ColName -TaskSequencePackageId $TSID -ScheduleEvent AsSoonAsPossible -DeploymentAvailableDay $ScheduleAV -DeploymentAvailableTime $ScheduleAV -DeploymentExpireDay $ScheduleEXP -DeploymentExpireTime $ScheduleEXP -AllowUsersRunIndependently $True -DeployPurpose Required -MakeAvailableTo Clients -RerunBehavior AlwaysRerunProgram -ShowTaskSequenceProgress $True

#Fix Ghost Deployment > rewrite ProgramName 
$Coll = Get-CMDeviceCollection -Name $ColName
$CollID = $Coll.CollectionID
$AdvTS = gwmi -namespace $AdvTSNameSpace -ComputerName $SMSProvider -class SMS_Advertisement -filter "Packageid='$TSID' AND CollectionID='$CollID'"
$AdvID = $AdvTS.AdvertisementID
$AdvTS.ProgramName="*"
$AdvTS.put()
Set-CMTaskSequenceDeployment -TaskSequenceDeploymentId $AdvID -DeploymentExpireDay $ScheduleEXP -DeploymentExpireTime $ScheduleEXP


############################################################################

############################################################################

$TargetContainerNodeID = $FLDReplaceRST

#Collection 9h REPLACE RST GEN
$Scenario = "REPLACE - RST"
$TimeTri = "09H"
$ColName = $ColPrefix + " - " + $TimeTri + " - " + $Scenario + " - " + $SiteTri
$TSID = $TSReplaceRSTID

Write-host "Creating Collection : $ColName" -ForegroundColor Cyan
New-CMDeviceCollection -RefreshType ConstantUpdate -LimitingCollectionName "All Desktop and Server Clients" -Name $ColName

#Adding collection to PWR collection to disable hibernate
Write-Host "Adding Collection $ColName to collection PWR-MI7-Migration (STG003EE)"  -ForegroundColor Cyan
Add-CMDeviceCollectionIncludeMembershipRule -CollectionID $ColPowerExcludeID -IncludeCollectionName $ColName

Write-Host "Moving Collection $ColName to folder $TargetContainerNodeID"  -ForegroundColor DarkCyan
move-Collection 0 $ColName $TargetContainerNodeID

#Deploy TS
$Schedule = New-CMSchedule -Start $TSReplaceRSTTime1 -Nonrecurring
$ScheduleAV = $TSReplaceRSTTime1
$ScheduleEXP = $TSReplaceRSTExpTime1

Write-Host "Deploy $TSID @ time $TargetDate on Collection $ColName" -ForegroundColor Cyan
Start-CMTaskSequenceDeployment -CollectionName $ColName -TaskSequencePackageId $TSID -ScheduleEvent AsSoonAsPossible -DeploymentAvailableDay $ScheduleAV -DeploymentAvailableTime $ScheduleAV -DeploymentExpireDay $ScheduleEXP -DeploymentExpireTime $ScheduleEXP -AllowUsersRunIndependently $True -DeployPurpose Required -MakeAvailableTo Clients -RerunBehavior AlwaysRerunProgram -ShowTaskSequenceProgress $True

#Fix Ghost Deployment > rewrite ProgramName 
$Coll = Get-CMDeviceCollection -Name $ColName
$CollID = $Coll.CollectionID
$AdvTS = gwmi -namespace $AdvTSNameSpace -ComputerName $SMSProvider -class SMS_Advertisement -filter "Packageid='$TSID' AND CollectionID='$CollID'"
$AdvID = $AdvTS.AdvertisementID
$AdvTS.ProgramName="*"
$AdvTS.put()
Set-CMTaskSequenceDeployment -TaskSequenceDeploymentId $AdvID -DeploymentExpireDay $ScheduleEXP -DeploymentExpireTime $ScheduleEXP


############################################################################

############################################################################
#Collection 14h REPLACE RST GEN
$Scenario = "REPLACE - RST"
$TimeTri = "14H"
$ColName = $ColPrefix + " - " + $TimeTri + " - " + $Scenario + " - " + $SiteTri
$TSID = $TSReplaceRSTID

Write-host "Creating Collection : $ColName" -ForegroundColor Cyan
New-CMDeviceCollection -RefreshType ConstantUpdate -LimitingCollectionName "All Desktop and Server Clients" -Name $ColName

#Adding collection to PWR collection to disable hibernate
Write-Host "Adding Collection $ColName to collection PWR-MI7-Migration (STG003EE)"  -ForegroundColor Cyan
Add-CMDeviceCollectionIncludeMembershipRule -CollectionID $ColPowerExcludeID -IncludeCollectionName $ColName

Write-Host "Moving Collection $ColName to folder $TargetContainerNodeID"  -ForegroundColor DarkCyan
move-Collection 0 $ColName $TargetContainerNodeID

#Deploy TS
$Schedule = New-CMSchedule -Start $TSReplaceRSTTime2 -Nonrecurring
$ScheduleAV = $TSReplaceRSTTime2
$ScheduleEXP = $TSReplaceRSTExpTime2

Write-Host "Deploy $TSID @ time $TargetDate on Collection $ColName" -ForegroundColor Cyan
Start-CMTaskSequenceDeployment -CollectionName $ColName -TaskSequencePackageId $TSID -ScheduleEvent AsSoonAsPossible -DeploymentAvailableDay $ScheduleAV -DeploymentAvailableTime $ScheduleAV -DeploymentExpireDay $ScheduleEXP -DeploymentExpireTime $ScheduleEXP -AllowUsersRunIndependently $True -DeployPurpose Required -MakeAvailableTo Clients -RerunBehavior AlwaysRerunProgram -ShowTaskSequenceProgress $True

#Fix Ghost Deployment > rewrite ProgramName 
$Coll = Get-CMDeviceCollection -Name $ColName
$CollID = $Coll.CollectionID
$AdvTS = gwmi -namespace $AdvTSNameSpace -ComputerName $SMSProvider -class SMS_Advertisement -filter "Packageid='$TSID' AND CollectionID='$CollID'"
$AdvID = $AdvTS.AdvertisementID
$AdvTS.ProgramName="*"
$AdvTS.put()
Set-CMTaskSequenceDeployment -TaskSequenceDeploymentId $AdvID -DeploymentExpireDay $ScheduleEXP -DeploymentExpireTime $ScheduleEXP


############################################################################

############################################################################
#Collection FORCED REPLACE RST GEN
$Scenario = "REPLACE - RST"
$TimeTri = "FORCED"
$ColName = $ColPrefix + " - " + $TimeTri + " - " + $Scenario + " - " + $SiteTri
$TSID = $TSReplaceRSTID

Write-host "Creating Collection : $ColName" -ForegroundColor Cyan
New-CMDeviceCollection -RefreshType ConstantUpdate -LimitingCollectionName "All Desktop and Server Clients" -Name $ColName

#Adding collection to PWR collection to disable hibernate
Write-Host "Adding Collection $ColName to collection PWR-MI7-Migration (STG003EE)"  -ForegroundColor Cyan
Add-CMDeviceCollectionIncludeMembershipRule -CollectionID $ColPowerExcludeID -IncludeCollectionName $ColName

Write-Host "Moving Collection $ColName to folder $TargetContainerNodeID"  -ForegroundColor DarkCyan
move-Collection 0 $ColName $TargetContainerNodeID

#Deploy TS
$Schedule = New-CMSchedule -Start $TSReplaceRSTTime3 -Nonrecurring
$ScheduleAV = $TSReplaceRSTTime3
$ScheduleEXP = $TSReplaceRSTExpTime3

Write-Host "Deploy $TSID @ time $TargetDate on Collection $ColName" -ForegroundColor Cyan
Start-CMTaskSequenceDeployment -CollectionName $ColName -TaskSequencePackageId $TSID -ScheduleEvent AsSoonAsPossible -DeploymentAvailableDay $ScheduleAV -DeploymentAvailableTime $ScheduleAV -DeploymentExpireDay $ScheduleEXP -DeploymentExpireTime $ScheduleEXP -AllowUsersRunIndependently $True -DeployPurpose Required -MakeAvailableTo Clients -RerunBehavior AlwaysRerunProgram -ShowTaskSequenceProgress $True

#Fix Ghost Deployment > rewrite ProgramName 
$Coll = Get-CMDeviceCollection -Name $ColName
$CollID = $Coll.CollectionID
$AdvTS = gwmi -namespace $AdvTSNameSpace -ComputerName $SMSProvider -class SMS_Advertisement -filter "Packageid='$TSID' AND CollectionID='$CollID'"
$AdvID = $AdvTS.AdvertisementID
$AdvTS.ProgramName="*"
$AdvTS.put()
Set-CMTaskSequenceDeployment -TaskSequenceDeploymentId $AdvID -DeploymentExpireDay $ScheduleEXP -DeploymentExpireTime $ScheduleEXP


############################################################################

############################################################################

$TargetContainerNodeID = $FLDRefreshTST

#Collection REFRESHTST GEN
$Scenario = "REFRESH - TST"
$TimeTri = "TEST"
$ComputerBackupLocation = "\\FRSCM05\VIP$"
$UserDataLocation = "LOCAL"
$ColName = $ColPrefix + " - " + $TimeTri + " - " + $Scenario + " - " + $SiteTri
$TSID = $TSRefreshTSTID

Write-host "Creating Collection : $ColName" -ForegroundColor Cyan
New-CMDeviceCollection -RefreshType ConstantUpdate -LimitingCollectionName "All Desktop and Server Clients" -Name $ColName
New-CMDeviceCollectionVariable -CollectionName $ColName -VariableName ComputerBackupLocation -VariableValue $ComputerBackupLocation
New-CMDeviceCollectionVariable -CollectionName $ColName -VariableName Vip -VariableValue "TRUE"
New-CMDeviceCollectionVariable -CollectionName $ColName -VariableName BackupFile -VariableValue "%OSDComputerName%.wim"

#Adding collection to PWR collection to disable hibernate
Write-Host "Adding Collection $ColName to collection PWR-MI7-Migration (STG003EE)"  -ForegroundColor Cyan
Add-CMDeviceCollectionIncludeMembershipRule -CollectionID $ColPowerExcludeID -IncludeCollectionName $ColName

Write-Host "Moving Collection $ColName to folder $TargetContainerNodeID"  -ForegroundColor DarkCyan
move-Collection 0 $ColName $TargetContainerNodeID

#Deploy TS 
$Schedule = New-CMSchedule -Start $TSRefreshTSTTime1 -Nonrecurring
$ScheduleAV = $TSRefreshTSTTime1
$ScheduleEXP = $TSRefreshTSTExpTime1

Write-Host "Deploy $TSID @ time $TargetDate on Collection $ColName" -ForegroundColor Cyan
Start-CMTaskSequenceDeployment -CollectionName $ColName -TaskSequencePackageId $TSID -ScheduleEvent AsSoonAsPossible -DeploymentAvailableDay $ScheduleAV -DeploymentAvailableTime $ScheduleAV -DeploymentExpireDay $ScheduleEXP -DeploymentExpireTime $ScheduleEXP -AllowUsersRunIndependently $True -DeployPurpose Required -MakeAvailableTo Clients -RerunBehavior AlwaysRerunProgram -ShowTaskSequenceProgress $True

#Fix Ghost Deployment > rewrite ProgramName 
$Coll = Get-CMDeviceCollection -Name $ColName
$CollID = $Coll.CollectionID
$AdvTS = gwmi -namespace $AdvTSNameSpace -ComputerName $SMSProvider -class SMS_Advertisement -filter "Packageid='$TSID' AND CollectionID='$CollID'"
$AdvID = $AdvTS.AdvertisementID
$AdvTS.ProgramName="*"
$AdvTS.put()
Set-CMTaskSequenceDeployment -TaskSequenceDeploymentId $AdvID -DeploymentExpireDay $ScheduleEXP -DeploymentExpireTime $ScheduleEXP

############################################################################

############################################################################

$TargetContainerNodeID = $FLDRefreshTST

#Collection FORCED REFRESHTST GEN
$Scenario = "REFRESH - TST"
$TimeTri = "FORCED"
$ComputerBackupLocation = "\\FRSCM05\VIP$"
$UserDataLocation = "LOCAL"
$ColName = $ColPrefix + " - " + $TimeTri + " - " + $Scenario + " - " + $SiteTri
$TSID = $TSRefreshTSTID

Write-host "Creating Collection : $ColName" -ForegroundColor Cyan
New-CMDeviceCollection -RefreshType ConstantUpdate -LimitingCollectionName "All Desktop and Server Clients" -Name $ColName
New-CMDeviceCollectionVariable -CollectionName $ColName -VariableName ComputerBackupLocation -VariableValue $ComputerBackupLocation
New-CMDeviceCollectionVariable -CollectionName $ColName -VariableName Vip -VariableValue "TRUE"
New-CMDeviceCollectionVariable -CollectionName $ColName -VariableName BackupFile -VariableValue "%OSDComputerName%.wim"

#Adding collection to PWR collection to disable hibernate
Write-Host "Adding Collection $ColName to collection PWR-MI7-Migration (STG003EE)"  -ForegroundColor Cyan
Add-CMDeviceCollectionIncludeMembershipRule -CollectionID $ColPowerExcludeID -IncludeCollectionName $ColName

Write-Host "Moving Collection $ColName to folder $TargetContainerNodeID"  -ForegroundColor DarkCyan
move-Collection 0 $ColName $TargetContainerNodeID

#Deploy TS 
$Schedule = New-CMSchedule -Start $TSRefreshTSTTime3 -Nonrecurring
$ScheduleAV = $TSRefreshTSTTime3
$ScheduleEXP = $TSRefreshTSTExpTime3

Write-Host "Deploy $TSID @ time $TargetDate on Collection $ColName" -ForegroundColor Cyan
Start-CMTaskSequenceDeployment -CollectionName $ColName -TaskSequencePackageId $TSID -ScheduleEvent AsSoonAsPossible -DeploymentAvailableDay $ScheduleAV -DeploymentAvailableTime $ScheduleAV -DeploymentExpireDay $ScheduleEXP -DeploymentExpireTime $ScheduleEXP -AllowUsersRunIndependently $True -DeployPurpose Required -MakeAvailableTo Clients -RerunBehavior AlwaysRerunProgram -ShowTaskSequenceProgress $True

#Fix Ghost Deployment > rewrite ProgramName 
$Coll = Get-CMDeviceCollection -Name $ColName
$CollID = $Coll.CollectionID
$AdvTS = gwmi -namespace $AdvTSNameSpace -ComputerName $SMSProvider -class SMS_Advertisement -filter "Packageid='$TSID' AND CollectionID='$CollID'"
$AdvID = $AdvTS.AdvertisementID
$AdvTS.ProgramName="*"
$AdvTS.put()
Set-CMTaskSequenceDeployment -TaskSequenceDeploymentId $AdvID -DeploymentExpireDay $ScheduleEXP -DeploymentExpireTime $ScheduleEXP

############################################################################

Write-Host "End of script - Deployments created for $TargetDate" -ForegroundColor Magenta


