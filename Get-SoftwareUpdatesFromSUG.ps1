############################################################################################

$modulelocation = 'D:\Apps\SCCM\AdminConsole\bin\configurationmanager.psd1'
$SUG = 'FFF-Servers-Monthly - Windows Security+Criticals - Lot1 - Preprod 2015-07-14 09:01:06'

# OK FFF-Servers-Monthly - Windows Security+Criticals - Lot1 - Preprod 2015-07-14 09:01:06
# OK FFF-Servers-Monthly - Windows Security+Criticals - Lot2 - Prod 2015-06-09 09:02:34
# OK FFF-Servers-Monthly - Windows Security+Criticals - Lot1 - Preprod 2015-09-08 09:01:25
# OK FFF-Servers-Monthly - Windows Security+Criticals - Lot1 - Preprod 2015-08-11 09:01:52

$SUGTarget = 'FFF-Baseline_Servers'

Import-Module $modulelocation
CD FFF:

write-host "Building update's List ..." -ForegroundColor Yellow
$SUList = (Get-CMSoftwareUpdate -UpdateGroupName $SUG | Where-Object { $_.isExpired -eq $false })

write-host find $SUList.count Updates non-expired to move from $SUG to $SUGTarget -ForegroundColor Green

$i = 0
ForEach ($SU in $SUList)
{
    $i++
    write-progress -activity "Add Software updates to SUG $SUGTarget" -status "SU added: " -PercentComplete (($i / $SUList.count) * 100) -CurrentOperation "(($i / $SUList.count) * 100)% complete"
    write-host Add $SU.LocalizedDisplayName to $SUGTarget -ForegroundColor Yellow
    $SU | Add-CMSoftwareUpdateToGroup -SoftwareUpdateGroupName "$SUGTarget"
}

#$SUList | Add-CMSoftwareUpdateToGroup -SoftwareUpdateGroupName "$SUGTarget"

############################################################################################

