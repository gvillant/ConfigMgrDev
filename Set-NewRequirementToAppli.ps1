$VerbosePreference = "SilentlyContinue"

$SMSProvider = "FRPSCM01.stago.grp"


Function Import-Module-CM {
import-module ($Env:SMS_ADMIN_UI_PATH.Substring(0,$Env:SMS_ADMIN_UI_PATH.Length-5) + '\ConfigurationManager.psd1')
Get-SiteCode
Set-location $SiteCode":"
}

Function Get-SiteCode {
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

Import-Module-CM

$results = @()

#$apps = @(  "SKYPE FOR BUSINESS BASIC 2016_R01" #,
      #      "SKYPE FOR BUSINESS BASIC 2016_R01",
      #      "AUTOCAD-LT_2013",
      #      "Office Standard 2016 - FINAL"
 #       )
#foreach ($appName in $apps) {
#$Appdt = Get-CMApplication -Name $appName
 
#Cherche toutes toutes les applications actives et non retirées qui ont un requirement de type OS et les ajoute dans $results.
foreach ($Appdt in (Get-CMApplication)) {
        
    if ($Appdt.IsEnabled -and  !($Appdt.Isexpired))  { 
    
        $xml = [Microsoft.ConfigurationManagement.ApplicationManagement.Serialization.SccmSerializer]::DeserializeFromString($appdt.SDMPackageXML,$True)
        $numDTS = $xml.DeploymentTypes.count
        $dts = $xml.DeploymentTypes
        
        foreach ($dt in $dts)
            {
            foreach($requirement in $dt.Requirements)
                {
                #write-host -ForegroundColor Yellow  "Process $($appName) - $($dt.Title) - $($requirement.Name)"
                if($requirement.Expression.gettype().name -eq 'OperatingSystemExpression') 
                    {
                    write-host -ForegroundColor Green "$($appdt.LocalizedDisplayName) - $($dt.Title) - $($requirement.Name)"
                    $objResults = New-Object System.Object
                    $objResults | Add-member -Type NoteProperty -Name appName -Value $appdt.LocalizedDisplayName
                    $objResults | Add-member -Type NoteProperty -Name dtTitle -Value $dt.Title
                    $objResults | Add-member -Type NoteProperty -Name requirementName -Value $requirement.Name
                    $results += $objResults
                    }
                }
            }
        }
    }

#Affiche les résultats
$results | Out-GridView

#Fix Global condition
foreach ($Target in $results) {
    Set-Location E:\_Exploit\_Scripts
    & E:\_Exploit\_Scripts\Add-CMDeploymentTypeGlobalCondition-v2.ps1 -ApplicationName "$($Target.appName)" -DeploymentTypeName "$($Target.dtTitle)" -sdkserver "frpscm01" -sitecode "STG" -GlobalCondition "os-wks-x64" -Operator "IsEquals" -Value "True"
    }
