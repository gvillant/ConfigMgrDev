
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
return $SiteCode
}
#######################################################################################


#######################################################################################

#$LPArch = "x64"
#$LpLg = "de-de"
#$LPLg2 = "deu"
$DPGName = "DPG-OSD-Win7"

function New-ModelPackage($ComputerCountry, $Version)
{
$PackageName = "STAGO_MODELES-STAGO-VAL_5.0_R01_7ALLC_$ComputerCountry"
$ProgramName = "STAGO_MODELES-STAGO-VAL_5.0_R01_7ALLC_$ComputerCountry"
    New-CMPackage -Name $PackageName -Language $ComputerCountry -Manufacturer Stago -Path \\FRPSCM01\package_sources\Softwares\STAGO_MODELES-STAGO-VAL_5.0_R01_7ALLC_MUI\$ComputerCountry\DT01-STAGO_MODELES-STAGO-VAL_5.0_R01_7ALLC_$ComputerCountry -Version $Version
    New-CMProgram -PackageName $ProgramName -StandardProgramName Install -CommandLine "msiexec /i STAGO_MODELES-STAGO-VAL_5.0_R01_7ALLC_$ComputerCountry.msi /qn /L*v c:\windows\stago\Install_STAGO_MODELES-STAGO-VAL_5.0_R01_7ALLC_$ComputerCountry.log" -ProgramRunType WhetherOrNotUserIsLoggedOn -RunMode RunWithAdministrativeRights -DiskSpaceRequirement 10 -DiskSpaceUnit MB -Duration 20
    Set-CMProgram -Name $PackageName -StandardProgramName $ProgramName -EnableTaskSequence $True
    Start-CMContentDistribution -PackageName "STAGO_MODELES-STAGO-VAL_5.0_R01_7ALLC_$ComputerCountry" -DistributionPointGroupName $DPGName
    }
#######################################################################################

Import-Module-CM

function TestNew-ModelPackage($ComputerCountry, $Version)
{
    write-host "STAGO_MODELES-STAGO-VAL_2.0_R01_WIN7ALLC_$ComputerCountry"
    }





    