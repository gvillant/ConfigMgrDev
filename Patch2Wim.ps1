
######################################################################################################
function Merge2Wim {
#Use ImageX, because p$ 4.0 is needed for Add-WindowsImage cmdlet ... :(
#Script will copy Index 1 Wimfile to destination folder, then mount, append and unmount Index 2 WimFile. 

$ADKModulePath ="E:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\DISM"
$MountDir ="E:\Mnt"
$WimSourcePath ="E:\Package Sources\Operating Systems Images\Windows 7\W7x64SP1-160828-031100"
$WimFile ="W7x64SP1-160828-031100.wim"
$HotfixesFolder = "E:\Package Sources\Operating Systems Images\Windows 7\KB-Skylake"

#Wim Merged filename


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
 

write-host "Mount $WimFile Index 1 to $MountDir" -ForegroundColor Green
#(P$4 needed ... ) Mount-WindowsImage -ImagePath $WimSourcePath\$WimIndex2File -Index 1 -Path $MountDir -ReadOnly
& $ADKModulePath\dism.exe /Mount-Image /ImageFile:$WimSourcePath\$WimFile /Index:1 /MountDir:$MountDir

write-host "Append Packages" -ForegroundColor Green
& $ADKModulePath\dism.exe /Image:$MountDir /Add-Package /PackagePath:$HotfixesFolder

write-host "Unmount WIM $MountDir" -ForegroundColor Green
#(P$4 needed ... ) Dismount-WindowsImage -Discard -Path $MountDir
& $ADKModulePath\dism.exe /Unmount-Wim /MountDir:$MountDir /Commit

<#

write-host "Mount $WimFile Index 2 to $MountDir" -ForegroundColor Green
#(P$4 needed ... ) Mount-WindowsImage -ImagePath $WimSourcePath\$WimIndex2File -Index 2 -Path $MountDir -ReadOnly
& $ADKModulePath\dism.exe /Mount-Image /ImageFile:$WimSourcePath\$WimFile /Index:2 /MountDir:$MountDir

write-host "Append Packages" -ForegroundColor Green
& $ADKModulePath\dism.exe /Image:$MountDir /Add-Package /PackagePath:$HotfixesFolder

write-host "Unmount WIM $MountDir" -ForegroundColor Green
#(P$4 needed ... ) Dismount-WindowsImage -Discard -Path $MountDir
& $ADKModulePath\dism.exe /Unmount-Wim /MountDir:$MountDir /Commit

#>

}
######################################################################################################

Merge2Wim

