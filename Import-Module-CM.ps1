


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

$SMSProvider = "FRPSCM01.stago.grp"

Import-Module-CM


######################################################################################################
function Import-OSImage {
$OSName = "W7x64SP1-031000-Merged"
$DPGName = "DPG-OSD-Build"
$OSPath = "E:\Package Sources\Operating Systems Images\Windows 7\W7x64SP1-151124-030100-Merged\W7x64SP1-031000-Merged.wim"
$OSDescription = "v031000 Updates:24/11/2015"
$OSVersion = "031000"

New-CMOperatingSystemImage -Name $OSName -Path $OSPath -Description $OSDescription
Set-CMOperatingSystemImage -Name $OSName -EnableBinaryDeltaReplication $True -Version $OSVersion
Start-CMContentDistribution -OperatingSystemImageName $OSName -DistributionPointGroupName $DPGName
}
######################################################################################################

