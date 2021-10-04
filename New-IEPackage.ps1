
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

function New-IEPackage($LPArch, $LpLg, $LPLg2)
{

$LPArch = "x64"
$LpLg = "zh-cn"
$LPLg2 = "fra"
$DPGName = "DPG-OSD-Win7"
    Write-Host "LP-IE11-W7"  $LPArch "_"  $LPLg
    Write-Host "$LPArch" -ForegroundColor yellow
    Write-Host "$LPLg" -ForegroundColor DarkYellow
    New-CMPackage -Name "LP-IE11-W7${$LPArch}_$LPLg" -Language "$LpLg" -Manufacturer "Microsoft" -Path "\\frpscm01\package_sources\OSD\LanguagePacks\InternetExplorer11\IE11-7$LPArch\$LPLg"
    New-CMProgram -PackageName "LP-IE11-W7${$LPArch}_$LPLg" -StandardProgramName "Install" -CommandLine "wusa IE11-Windows6.1-LanguagePack-$LPArch-$LPLg.msu /quiet /norestart" -ProgramRunType WhetherOrNotUserIsLoggedOn -RunMode RunWithAdministrativeRights -DiskSpaceRequirement 10 -DiskSpaceUnit MB -Duration 20
    Start-CMContentDistribution -PackageName LP-IE11-W7${$LPArch}_$LPLg -DistributionPointGroupName $DPGName
}
#######################################################################################

Import-Module-CM



New-IEPackage($LPArch, $LpLg, $LPLg2)
