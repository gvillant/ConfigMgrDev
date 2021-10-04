<#
http://scug.be/sccm/2013/01/27/configmgr-2012-sp1-powershell-script-to-repair-broken-applications-after-upgrading-them-from-rtm/

Upgrading a Configmgr 2012 RTM environment to a new SP1 environment . After the upgrade was successfully performed , 
suddenly all applications within my OSD task sequence start failing as described in my previous blog post here : 
http://scug.be/sccm/2013/01/08/configmgr-2012-sp1-broken-applications-after-upgrading-from-rtm/

#>

$PSDFile = "E:\Program Files\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1"
$SiteCode = "STG"
 
Write-Host Importing System Center Configuration Manager 2012 Module...
import-module $PSDFile
cls
cd $SiteCode":"
write-host "Querying for Applications without deployments"
$AffectedApps = get-cmapplication | Where-Object -FilterScript { ($_.NumberOfDeployments -gt 0 ) -and ( $_.IsExpired -eq $false ) }
Write-Host "Found these affected Applications:"
$AffectedApps | select LocalizedDisplayName
write-host ""
Write-Host "Updating Deployment Types..."
$AffectedApps | Foreach {
    $AppName = $_.LocalizedDisplayName
    Write-Host "Looking up deployment types for $AppName"
    $DTypes = @(get-CMDeploymentType -Applicationname $AppName)
    
    $DTypes |foreach {
        $DtypeDescription = $_.LocalizedDescription
        $DtypeName = $_.LocalizedDisplayName
        $DtypeNameNew = $DtypeName + "_"
        
        write-host Found: $DtypeName
        write-host Updating the comment to `"$DtypeNameNew`"
            set-CMDeploymentType -ApplicationName $AppName -DeploymentTypeName $DtypeName -AdministratorComment $DtypeNameNew
        if (!$DTypeDescription) {
            write-host Updating comment back to `"$DtypeDescription`"
            set-CMDeploymentType -ApplicationName $AppName -DeploymentTypeName $DtypeName -AdministratorComment " "
            }
        if ($DTypeDescription) {
            write-host Updating comment back to `"$DtypeDescription`"
            set-CMDeploymentType -ApplicationName $AppName -DeploymentTypeName $DtypeName -AdministratorComment $DtypeDescription
            }
        write-host ""
        }
    write-host "----------------------------------------------"
    }
