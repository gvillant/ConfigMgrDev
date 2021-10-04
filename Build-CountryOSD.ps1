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


<#
Most settings here : 
Folders ID : 
ContainerNodeID	Name
16777665	AU-OSD
16777672	CN-OSD
16777673	DE-OSD
16777674	US-OSD
#>

############ SET VARIABLES HERE ##############
$Country = "CN"           # US
$FLDOSD = "16777672"      # US
$DPName = "CNSCM01"       # US


$ColPrefix = $Country + " - "
$WIMBackupLocation = "\\" + $DPName + "\Share-WIM$"

$Col1 = "Backup my data before replace"
$Col2 = "Refresh my computer to w7 - No WIM"
$Col3 = "Restore my data after replace"
$Col4 = "Backup WIM to " + $DPName
$LimCol = "All systems - Domain " + $Country 

###########################################"##

$SMSProvider = "FRPSCM01.stago.grp"
Import-Module-CM


Write-host "ColPrefix is $ColPrefix"
Write-host "FLDOSD  is $FLDOSD"


##################col1##################
$ColName = $ColPrefix + $Col1

Write-host "Creating Collection : $ColName" -ForegroundColor Cyan
New-CMDeviceCollection -RefreshType ConstantUpdate -LimitingCollectionName $LimCol -Name $ColName

#Adding collection to PWR collection to disable hibernate
#Write-Host "Adding Collection $ColName to collection PWR-MI7-Migration (STG003EE)"  -ForegroundColor Cyan
#Add-CMDeviceCollectionIncludeMembershipRule -CollectionID $ColPowerExcludeID -IncludeCollectionName $ColName

Write-Host "Moving Collection $ColName to folder $FLDOSD"  -ForegroundColor DarkCyan
move-Collection 0 $ColName $FLDOSD

##################col2##################
$ColName = $ColPrefix + $Col2

Write-host "Creating Collection : $ColName" -ForegroundColor Cyan
New-CMDeviceCollection -RefreshType ConstantUpdate -LimitingCollectionName $LimCol -Name $ColName

#Adding collection to PWR collection to disable hibernate
#Write-Host "Adding Collection $ColName to collection PWR-MI7-Migration (STG003EE)"  -ForegroundColor Cyan
#Add-CMDeviceCollectionIncludeMembershipRule -CollectionID $ColPowerExcludeID -IncludeCollectionName $ColName

Write-Host "Moving Collection $ColName to folder $FLDOSD"  -ForegroundColor DarkCyan
move-Collection 0 $ColName $FLDOSD

##################col3##################
$ColName = $ColPrefix + $Col3

Write-host "Creating Collection : $ColName" -ForegroundColor Cyan
New-CMDeviceCollection -RefreshType ConstantUpdate -LimitingCollectionName $LimCol -Name $ColName

#Adding collection to PWR collection to disable hibernate
#Write-Host "Adding Collection $ColName to collection PWR-MI7-Migration (STG003EE)"  -ForegroundColor Cyan
#Add-CMDeviceCollectionIncludeMembershipRule -CollectionID $ColPowerExcludeID -IncludeCollectionName $ColName

Write-Host "Moving Collection $ColName to folder $FLDOSD"  -ForegroundColor DarkCyan
move-Collection 0 $ColName $FLDOSD


##################col4##################
$ColName = $ColPrefix + $Col4

Write-host "Creating Collection : $ColName" -ForegroundColor Cyan
New-CMDeviceCollection -RefreshType ConstantUpdate -LimitingCollectionName $LimCol -Name $ColName
New-CMDeviceCollectionVariable -CollectionName $ColName -VariableName WIMBackupLocation -VariableValue $WIMBackupLocation

#Adding collection to PWR collection to disable hibernate
#Write-Host "Adding Collection $ColName to collection PWR-MI7-Migration (STG003EE)"  -ForegroundColor Cyan
#Add-CMDeviceCollectionIncludeMembershipRule -CollectionID $ColPowerExcludeID -IncludeCollectionName $ColName

Write-Host "Moving Collection $ColName to folder $FLDOSD"  -ForegroundColor DarkCyan
move-Collection 0 $ColName $FLDOSD


