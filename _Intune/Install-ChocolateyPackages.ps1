#From https://www.petervanderwoude.nl/post/combining-the-powers-of-the-intune-management-extension-and-chocolatey/

$ChocoPackages = @(“googlechrome”,”adobereader”,”notepadplusplus.install”,”7zip.install”)
$ChocoInstall = Join-Path ([System.Environment]::GetFolderPath(“CommonApplicationData”)) “Chocolatey\bin\choco.exe”

#install Chocolatey if not already there.
if(!(Test-Path $ChocoInstall)) {
     try {
         Invoke-Expression ((New-Object net.webclient).DownloadString(‘https://chocolatey.org/install.ps1’)) -ErrorAction Stop
     }
     catch {
         Throw “Failed to install Chocolatey”
     }       
}

#install ChocoPackages ...
foreach($Package in $ChocoPackages) {
     try {
         Invoke-Expression “cmd.exe /c $ChocoInstall Install $Package -y” -ErrorAction Stop
     }
     catch {
         Throw “Failed to install $Package”
     }
}
