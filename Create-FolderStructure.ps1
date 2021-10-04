<#
 
************************************************************************************************************************
 
Created:    2015-03-01
Version:    1.1
 
Disclaimer:
This script is provided "AS IS" with no warranties, confers no rights and 
is not supported by the authors or DeploymentArtist.
 
Author - Johan Arwidmark
    Twitter: @jarwidmark
    Blog   : http://deploymentresearch.com
 
************************************************************************************************************************
 
#>
 
# Check for elevation
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "Oupps, you need to run this script from an elevated PowerShell prompt!`nPlease start the PowerShell prompt as an Administrator and re-run the script."
    Write-Warning "Aborting script..."
    Break
}
 
$SourcePath = 'H:\Sources'
 
New-Item -Path $SourcePath -ItemType Directory
New-Item -Path "$SourcePath\OSD" -ItemType Directory
New-Item -Path "$SourcePath\OSD\_Archive" -ItemType Directory
New-Item -Path "$SourcePath\OSD\Boot" -ItemType Directory
New-Item -Path "$SourcePath\OSD\Drivers" -ItemType Directory
New-Item -Path "$SourcePath\OSD\MDT" -ItemType Directory
New-Item -Path "$SourcePath\OSD\OS" -ItemType Directory
New-Item -Path "$SourcePath\OSD\OS\Captures" -ItemType Directory
New-Item -Path "$SourcePath\OSD\OS\ISOs" -ItemType Directory
New-Item -Path "$SourcePath\OSD\OS\Images" -ItemType Directory
New-Item -Path "$SourcePath\OSD\Packages" -ItemType Directory

New-Item -Path "$SourcePath\Softwares" -ItemType Directory
New-Item -Path "$SourcePath\Softwares\_Archive" -ItemType Directory
New-Item -Path "$SourcePath\Softwares\_APPTEMPLATE-R01" -ItemType Directory
New-Item -Path "$SourcePath\Softwares\_APPTEMPLATE-R01\_ico" -ItemType Directory
New-Item -Path "$SourcePath\Softwares\_APPTEMPLATE-R01\_docs" -ItemType Directory
New-Item -Path "$SourcePath\Softwares\_APPTEMPLATE-R01\DT01-APPNAME-TECHNO-REQ" -ItemType Directory
New-Item -Path "$SourcePath\Softwares\Adobe" -ItemType Directory
New-Item -Path "$SourcePath\Softwares\Microsoft" -ItemType Directory
New-Item -Path "$SourcePath\Softwares\Microsoft\CMClient" -ItemType Directory
New-Item -Path "$SourcePath\Softwares\Microsoft\CMClient\Install" -ItemType Directory
New-Item -Path "$SourcePath\Softwares\Microsoft\CMClient\Hotfixes" -ItemType Directory
New-Item -Path "$SourcePath\Softwares\Customer" -ItemType Directory
New-Item -Path "$SourcePath\Softwares\Others" -ItemType Directory
New-Item -Path "$SourcePath\SoftwareUpdates" -ItemType Directory
New-Item -Path "$SourcePath\SoftwareUpdates\MS-Baseline-WKS" -ItemType Directory
New-Item -Path "$SourcePath\SoftwareUpdates\MS-Monthly-WKS" -ItemType Directory
New-Item -Path "$SourcePath\SoftwareUpdates\MS-Baseline-SRV" -ItemType Directory
New-Item -Path "$SourcePath\SoftwareUpdates\MS-Monthly-SRV" -ItemType Directory
New-Item -Path "$SourcePath\SoftwareUpdates\SCUP" -ItemType Directory
 
New-SmbShare –Name Sources$ –Path $SourcePath –FullAccess EVERYONE

