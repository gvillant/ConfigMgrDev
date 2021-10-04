<#
This script will help automate monthly tasks for patch management.
Replace variables as needed
SUGFilterName    = The name of the ADR which created the monthly SUGs
SUGTarget        = The name of the destination Baseline SUG
SiteCode         = ConfigMgr local SiteCode
Simulate         = $true or $false to run in simulate mode or not. 


#>
############################################################################################

$SUGFilterName = 'FFF-Clients-Monthly-W8.x - Windows+Office - Lot2 - Prod*'
$SUGTarget = 'FFF-Baseline_Clients_OS-Windows'
$SiteCode = 'FFF'
$Simulate = $true



function get-SUGSourceList {
write-host "Building SUG List with filter $SUGFilterName ..." -ForegroundColor Yellow
$SUGSourceList = (Get-CMSoftwareUpdateGroup | Where-Object -FilterScript {( $_.LocalizedDisplayName -like $SUGFilterName ) -and ( $_.IsDeployed -eq $true )})
write-host find $SUGSourceList.count SUG to process -ForegroundColor Green
Set-variable -name SUGSourceList -Value $SUGSourceList -scope 1
}


function add-UpdatesFromSUGSourcetoSUGTarget {
write-host "Building update's List for SUG $SUGSource ..." -ForegroundColor Yellow
$SUList = (Get-CMSoftwareUpdate -UpdateGroupName $SUGSource | Where-Object -FilterScript {( $_.isExpired -eq $false ) -and ( $_.LocalizedDisplayName -notMatch "32\s*bits" )} )
$SUListCount = $SUList.count
write-host find $SUListCount Updates non-expired to move from $SUGSource to $SUGTarget -ForegroundColor Green

$i = 0
ForEach ($SU in $SUList)
{
    $i++
    $SULocalizedDisplayName = $SU.LocalizedDisplayName
    write-progress -activity "Add Software updates to SUG $SUGTarget" -status "SU added: $i / $SUListCount - $SULocalizedDisplayName" -PercentComplete (($i / $SUList.count) * 100)
    if ($simulate) {
    write-host Simulate: $SU.LocalizedDisplayName to $SUGTarget -ForegroundColor White
    } 
    else {
    write-host Process: $SU.LocalizedDisplayName to $SUGTarget -ForegroundColor White
    $SU | Add-CMSoftwareUpdateToGroup -SoftwareUpdateGroupName "$SUGTarget"
    }
}
}

#region MAIN


Import-module ($Env:SMS_ADMIN_UI_PATH.Substring(0,$Env:SMS_ADMIN_UI_PATH.Length-5) + '\ConfigurationManager.psd1')
CD $SiteCode":"

get-SUGSourceList


Foreach ($SUGItem in $SUGSourceList)
{
    $SUGSource = $SUGItem.LocalizedDisplayName
    write-host Start processing $SUGItem.LocalizedDisplayName aka $SUGSource -ForegroundColor Yellow
    add-UpdatesFromSUGSourcetoSUGTarget
    if ($simulate) {
    write-host Simulate: Change SUG Description to OLD - content copied to $SUGTarget -ForegroundColor White
    } 
    else {
    write-host Process: Change SUG Description to OLD - content copied to $SUGTarget -ForegroundColor White
    $SUGitem | set-CMSoftwareUpdateGroup -description "OLD - content copied to $SUGTarget"
    }

}

#endregion


############################################################################################

