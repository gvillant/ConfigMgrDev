
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
function Invoke-DCMEvaluation
{
    param (
        [Parameter(Mandatory=$true, HelpMessage="Computer Name",ValueFromPipeline=$true)] $ComputerName
           )
    $Baselines = Get-WmiObject -ComputerName $ComputerName -Namespace root\ccm\dcm -Class SMS_DesiredConfiguration
    $Baselines | % { 
                  write-host $Computer.Name: Find and Invoke DCM Evaluation $Baselines.Name and $Baselines.Version -ForegroundColor Yellow
                  ([wmiclass]"\\$ComputerName\root\ccm\dcm:SMS_DesiredConfiguration").TriggerEvaluation($_.Name, $_.Version) 
                    }
}
#######################################################################################

$SMSProvider = "FFF-CMA-SRV01"
Import-Module-CM

$CollName = "DCM: Reboot pending check"
$CollID = Get-CMDeviceCollection -name $CollName
write-host Collection is : $CollID.CollectionID -ForegroundColor Yellow

$ComputerList = Get-CMDevice -CollectionId $CollID.CollectionID | select -Property Name
write-host ComputerList: $ComputerList -ForegroundColor Yellow

foreach ($Computer in $ComputerList) {
    write-host $Computer.Name: Start searching for DCM deployments -foreground Green
    Invoke-DCMEvaluation $Computer.Name
    }
