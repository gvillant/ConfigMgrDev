<#
.SYNOPSIS
	Script to set the "Create Deployment for OSD Task sequence for Customer"
.DESCRIPTION
	The script will deploy TS for multiples collections, with appropriate options...
.PARAMETER SMSProvider
    Hostname or FQDN of a SMSProvider in the Hierarchy 
    This parameter is optional
.PARAMETER TSID
    ID of the task sequence to deploy
.EXAMPLE
	PS C:\PSScript > .\Deploy-TS.ps1 -TSID STG00000
    This will deploy TS STG00000.
.INPUTS
	None.  You cannot pipe objects to this script.
.OUTPUTS
	No objects are output from this script. 
.LINK
	http://www.dell.com
.NOTES
	NAME: Deploy-TS.ps1
	VERSION: 1.0
	AUTHOR: Gaetan VILLANT @ Dell for STAGO
	LASTEDIT: October 17, 2014
    Change history:
.REMARKS
	To see the examples, type: "Get-Help .\Deploy-TS.ps1 -examples".
	For more information, type: "Get-Help .\Deploy-TS.ps1 -detailed".
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
    HelpMessage="TaskSequence ID ?", 
	Mandatory=$true )
	]
	[ValidateNotNullOrEmpty()]
    [String]$TSID = "" 
    )


$SMSProvider = "FRPSCM01.stago.grp"

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
#return $SiteCode
}
#######################################################################################


#######################################################################################
#Fix Ghost Deployment > rewrite ProgramName 
Function Fix-Deployment
{
$AdvTSNameSpace = "root\sms\site_" + $SiteCode
$Coll = Get-CMDeviceCollection -Name $ColName
$CollID = $Coll.CollectionID
$AdvTS = gwmi -namespace $AdvTSNameSpace -ComputerName $SMSProvider -class SMS_Advertisement -filter "Packageid='$TSID' AND CollectionID='$CollID'"
$AdvID = $AdvTS.AdvertisementID
$AdvTS.ProgramName="*"
$AdvTS.put()
}
#######################################################################################

#######################################################################################
#Fix Deployment to client > change Flags 
#http://connect.microsoft.com/ConfigurationManagervnext/feedback/details/1893555/start-cmtasksequencedeployment-error-the-value-clients-is-not-recognized-for-the-parameter-availability

Function Fix-AvailabilityClients
{
$deployment = Get-CMDeployment -CollectionName $ColName -SoftwareName $TS.Name -FeatureType TaskSequence
$advert = $cm.GetInstance("SMS_Advertisement.AdvertisementID='$($deployment.DeploymentID)'")
$advert.AdvertFlags = $advert.AdvertFlags -band ($advert.AdvertFlags -bxor [Microsoft.ConfigurationManagement.ManagementProvider.AdvertisementFlags]::APEnableTSFromCDAndPxe)
$advert.AdvertFlags = $advert.AdvertFlags -band ($advert.AdvertFlags -bxor [Microsoft.ConfigurationManagement.ManagementProvider.AdvertisementFlags]::HiddenInWinPE)
$advert.AdvertFlags = $advert.AdvertFlags -band ($advert.AdvertFlags -bxor [Microsoft.ConfigurationManagement.ManagementProvider.AdvertisementFlags]::TargetToWinPE)
$advert.Put()
}
#######################################################################################

Import-Module-CM
$TS = Get-CMTaskSequence -TaskSequencePackageId $TSID | Select Name
$cm = Get-CMConnectionManager
Write-host "TSID is $TSID"
Write-host TSName is $TS.Name


# All systems with Client OS - All Domains
$ColName = "All systems with Client OS - All Domains"
Write-Host "Deploy $TSID on Collection $ColName" -ForegroundColor Cyan
Start-CMTaskSequenceDeployment -CollectionName $ColName -TaskSequencePackageId $TSID -DeployPurpose Available -Availability MediaAndPxe -ShowTaskSequenceProgress $True
Fix-Deployment

# All Unknown Computers
$ColName = "All Unknown Computers"
Start-CMTaskSequenceDeployment -CollectionName $ColName -TaskSequencePackageId $TSID -DeployPurpose Available -Availability MediaAndPxe -ShowTaskSequenceProgress $True
Fix-Deployment

# OSD - Provisioned
$ColName = "OSD - Provisioned"
Start-CMTaskSequenceDeployment -CollectionName $ColName -TaskSequencePackageId $TSID -DeployPurpose Available -Availability ClientsMediaAndPxe -ShowTaskSequenceProgress $True
Fix-Deployment

# OSD - VMs
$ColName = "OSD - VMs"
Start-CMTaskSequenceDeployment -CollectionName $ColName -TaskSequencePackageId $TSID -DeployPurpose Available -Availability ClientsMediaAndPxe -ShowTaskSequenceProgress $True
Fix-Deployment

# SandBox VMS
$ColName = "SandBox VMS"
Start-CMTaskSequenceDeployment -CollectionName $ColName -TaskSequencePackageId $TSID -DeployPurpose Available -Availability ClientsMediaAndPxe -ShowTaskSequenceProgress $True
Fix-Deployment

# UDI - Refresh my Computer to w7
$ColName =  "UDI - Refresh my Computer to w7"
Start-CMTaskSequenceDeployment -CollectionName $ColName -TaskSequencePackageId $TSID -DeployPurpose Available -Availability MediaAndPxeHidden -ShowTaskSequenceProgress $True -AllowFallback $false -DeploymentOption DownloadContentLocallyWhenNeededByRunningTaskSequence
Fix-Deployment
Fix-AvailabilityClients

# UDI - Refresh my Computer to w7 - NO WIM
$ColName =  "UDI - Refresh my Computer to w7 - NO WIM"
Start-CMTaskSequenceDeployment -CollectionName $ColName -TaskSequencePackageId $TSID -DeployPurpose Available -Availability MediaAndPxeHidden -ShowTaskSequenceProgress $True -AllowFallback $false -DeploymentOption DownloadContentLocallyWhenNeededByRunningTaskSequence
Fix-Deployment
Fix-AvailabilityClients

# OSD - Wipe
$ColName =  "OSD - Wipe"
Start-CMTaskSequenceDeployment -CollectionName $ColName -TaskSequencePackageId $TSID -DeployPurpose Available -Availability MediaAndPxeHidden -ShowTaskSequenceProgress $True -AllowFallback $false -DeploymentOption DownloadContentLocallyWhenNeededByRunningTaskSequence
Fix-Deployment
Fix-AvailabilityClients

