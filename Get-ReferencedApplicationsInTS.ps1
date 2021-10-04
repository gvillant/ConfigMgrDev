
Import-Module "D:\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1"
CD SOC:

$TS = "SOC00153"


$SiteCode = $SiteCode = (get-psdrive -PSProvider CMSite).Name
$AppList = Get-CMApplication
$ProgList = Get-CMProgram
$TSList = Get-CMTaskSequence | where-object {$_.PackageID -eq $TS }
 
foreach ($TSInfo in $TSList)
{
    "{0}:{1}" -f $TSInfo.packageID, $TSInfo.Name
    $TSDependents = Get-WMIObject -NameSpace "Root\SMS\Site_$($SiteCode)" -Class SMS_TaskSequenceAppReferencesInfo | Where-Object {$_.PackageID -eq "$($TSInfo.PackageID)"}
 
    foreach ($TSDep in $TSDependents)
    {
        $Apps = $AppList | where-object { $_.CI_UniqueID -like "$($TSDep.RefAppModelName)*" }
 
        foreach ($App in $Apps)
            {
                "  {0}" -f $App.LocalizedDisplayName 
                #Set-CMApplication -Id $App.CI_ID -AutoInstall $true
                #$AppList = Get-CMApplication
            }
    }
 <#
    $TSDependents = Get-WMIObject -NameSpace "Root\SMS\Site_$($SiteCode)" -Class SMS_TaskSequencePackageReference | Where-Object {$_.PackageID -eq "$($TSInfo.PackageID)"}
 
    foreach ($TSDep in $TSDependents)
    {
        $Progs = $ProgList | where-object { $_.PackageID -like $TSDep.RefPackageID }
 
        foreach ($Prog in $Progs)
        {
            if (($Prog.ProgramFlags -band 33) -eq 0)
            {
                "  {0}:{1}:{2}" -f $Prog.PackageID, $Prog.PackageName, $Prog.ProgramName
                #Set-CMProgram -StandardProgram -ProgramName "$($Prog.ProgramName)" -Id $Prog.PackageID -EnableTaskSequence $true
                #$ProgList = Get-CMProgram
            }
        }
    }
    "  " #>
}

