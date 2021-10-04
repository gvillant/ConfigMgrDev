
######################################################################################################
function Merge2Wim {
#Use ImageX, because p$ 4.0 is needed for Add-WindowsImage cmdlet ... :(
#Script will copy Index 1 Wimfile to destination folder, then mount, append and unmount Index 2 WimFile. 

$ADKModulePath ="E:\Program Files (x86)\Windows Kits\8.1\Assessment and Deployment Kit\Deployment Tools\amd64\DISM"
$MountDir ="E:\Mnt"
$WimSourcePath ="E:\Package Sources\Operating Systems Images\Windows 7\W7x64SP1-151124-030100-BC"
$WimDestinationPath ="E:\Package Sources\Operating Systems Images\Windows 7\W7x64SP1-151124-030100-Merged"

#Wim FR filename
$WimIndex1File ="W7x64SP1-031000-FR.wim"

#Wim EN filename
$WimIndex2File ="W7x64SP1-031000-EN.wim"

#Wim Merged filename
$WimDestFile ="W7x64SP1-031000-Merged.wim"

#Build Description for each index
$DescIndex1 = $WimIndex1File.substring(0,$WimIndex1File.indexof('.')).trim()
$DescIndex2 = $WimIndex2File.substring(0,$WimIndex2File.indexof('.')).trim()

#(P$4 needed ... ) import-module $ADKModulePath

#test if mountDir exists, create if necessary.
write-host "Check $MountDir folder" -ForegroundColor DarkYellow
if (Test-Path $MountDir) {
    write-host "$MountDir already exists" -ForegroundColor Green
    }
    else {
    new-item -ItemType directory $MountDir
    write-host "$MountDir created" -ForegroundColor Green
    }
 
#test if destination "Merged" file exists, copy Index 1 if necessary.
write-host "Check for $WimDestinationPath\$WimDestFile file" -ForegroundColor DarkYellow
if (Test-Path "$WimDestinationPath\$WimDestFile") {
    write-host "$WimDestinationPath\$WimDestFile Already here" -ForegroundColor Cyan
    }
    else {
    Copy-Item -Path "$WimSourcePath\$WimIndex1File" -Destination "$WimDestinationPath\$WimDestFile" -Force
    write-host "$WimDestinationPath\$WimDestFile created from $WimSourcePath\$WimIndex1File" -ForegroundColor Green
    }

write-host "Mount $WimIndex2File to $MountDir" -ForegroundColor Green
#(P$4 needed ... ) Mount-WindowsImage -ImagePath $WimSourcePath\$WimIndex2File -Index 1 -Path $MountDir -ReadOnly
& $ADKModulePath\imagex.exe /mount "$WimSourcePath\$WimIndex2File" 1 "$MountDir"

write-host "Run ImageX to append $MountDir to $WimDestFile" -ForegroundColor Green
& $ADKModulePath\imagex.exe /append "$MountDir" "$WimDestinationPath\$WimDestFile" $DescIndex2 $DescIndex2


write-host "Run ImageX to set info $DescIndex1 to Index 1" -ForegroundColor Green
& $ADKModulePath\imagex.exe /info "$WimDestinationPath\$WimDestFile" 1 $DescIndex1 $DescIndex1

write-host "Run ImageX to set info $DescIndex2 to Index 2" -ForegroundColor Green
& $ADKModulePath\imagex.exe /info "$WimDestinationPath\$WimDestFile" 2 $DescIndex2 $DescIndex2

write-host "Dismount WIM $MountDir" -ForegroundColor Green
#(P$4 needed ... ) Dismount-WindowsImage -Discard -Path $MountDir
& $ADKModulePath\imagex.exe /unmount "$MountDir"
}
######################################################################################################

Merge2Wim

