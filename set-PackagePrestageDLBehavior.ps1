<#
.SYNOPSIS
	Script to set the "Prestaged DL behavior for Drivers Packages"
.DESCRIPTION
	Change value in the script  : 16777216 for 'Manually copy content', 32 for 'Automatically download content', 16 for 'Download only changes'
	Be Carreful because the script replace this value for all packages.
.PARAMETER SMSProvider
    Hostname or FQDN of a SMSProvider in the Hierarchy 
    This parameter is optional
.EXAMPLE
	PS C:\PSScript > .\set-PackagePrestageDLBehavior.ps1 -SMSProvider cm12
    This will use CM12 as SMS Provider.
    This will use "Test" as the folder in which you want all packages to get edited.
    Will give you some verbose output.
.INPUTS
	None.  You cannot pipe objects to this script.
.OUTPUTS
	No objects are output from this script. 
.LINK
	http://www.dell.com
.NOTES
	NAME: set-PackagePrestageDLBehavior.ps1
	VERSION: 1.0
	AUTHOR: Gaetan VILLANT
	LASTEDIT: September 10, 2014
    Change history:
	Thanks to David OBrien :) 
.REMARKS
	To see the examples, type: "Get-Help .\set-PackagePrestageDLBehavior.ps1 -examples".
	For more information, type: "Get-Help .\set-PackagePrestageDLBehavior.ps1 -detailed".
    This script will only work with Powershell 3.0.
#>

$SMSProvider = "fff-cma-srv01"

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
return $SiteCode
}

$SiteCode = Get-SiteCode
Write-host "SiteCode is $SiteCode."

$Pkgs = Get-WmiObject -Class SMS_DriverPackage -Namespace root\sms\site_$SiteCode -ComputerName $SMSProvider 
#Write-host "$Pkgs"
#Write-host "Package $($Pkgs.PackageID) - $($Pkgs.Name) is set with PkgFlags $($Pkgs.PkgFlags)."

foreach ($Pkg in $Pkgs)
    {
        try 
            {
				#write-host -ForegroundColor Yellow "Package $($Pkg.PackageID) - $($Pkg.Name) is set with PkgFlags $($Pkg.PkgFlags)."
                $Flag =$($Pkg.PkgFlags)

                if ( ($Flag -ne '16') ) {
                write-host -ForegroundColor Yellow "Package $($Pkg.PackageID) - $($Pkg.Name) is set with PkgFlags $($Pkg.PkgFlags)."                   
				$Pkg = [wmi]$Pkg.__PATH
                $Pkg.PkgFlags = 16         # 16777216 for 'Manually copy content', 32 for 'Automatically download content', 16 for 'Download only changes'
                $Pkg.put() | Out-Null
                write-host -ForegroundColor DarkGreen "Package $($Pkg.PackageID) - $($Pkg.Name) is set with PkgFlags $($Pkg.PkgFlags)." 
                }
			}
		catch
            {
                Write-host "$($Pkg.Name) could not be edited."
            }
    }
	