<#
.SYNOPSIS
 Modify ConfigMgr objects prestaged settings

.DESCRIPTION
 Modify all Packages, Applications, OS Images, Bootimages and Driverpackages in a specific folderName to change preload settings.
 Use FQDN server names.

.EXAMPLE
 .\Set-PreloadOption.ps1 -CMServer Server1.domain.local -SiteCode 123 -FolderName Test

.NOTES
 Created by Kristoffer Henriksson
#>


[CmdletBinding()]
param(
    [Parameter(Mandatory=$True,Helpmessage="Please Enter Site Server Name")]
    [String]$CMServer,
    
    [Parameter(Mandatory=$True,Helpmessage="Please Enter Sitecode")]
    [String]$SiteCode,

    [Parameter(Mandatory=$True,Helpmessage="Please Enter FolderName")]
    [String]$FolderName

    #[Parameter(Mandatory=$True,Helpmessage="Please Enter Source DP")]
    #[String]$SourceDP,

    #[Parameter(Mandatory=$True,Helpmessage="Please Enter Task Sequence ID")]
    #[String]$TSID,

    #[Parameter(Mandatory=$False)]
    #[String]$Filepath = "E:\_PrestagedContent",

    #[Parameter(Mandatory=$False)]
    #$ContentDistribution = $False,

    #[Parameter(Mandatory=$False)]
    #$DestinationDP
    )

Import-Module -Name "${env:ProgramFiles(x86)}\Configuration Manager\Console\bin\ConfigurationManager.psd1"
CD $SiteCode":"

$SMS_WMI = "root\SMS\site"
$WMINameSpace = $SMS_WMI + "_" + $SiteCode

Write-Host "Retrieving Objects References from WMI..."
$FolderID = (Get-WmiObject -Class SMS_ObjectContainerNode -Namespace $WMINameSpace -ComputerName $CMServer -Filter "Name = '$($FolderName)'").ContainerNodeID

$Packages = (Get-WmiObject -Class SMS_ObjectContainerItem -Namespace $WMINameSpace -ComputerName $CMServer -Filter "ContainerNodeID = '$($FolderID)'").InstanceKey | Where-Object -FilterScript {$_.ObjectType -eq "0"}
$DriverPackages = (Get-WmiObject -Class SMS_ObjectContainerItem -Namespace $WMINameSpace -ComputerName $CMServer -Filter "ContainerNodeID = '$($FolderID)'").InstanceKey | Where-Object -FilterScript {$_.ObjectType -eq "3"}
$OSImages = (Get-WmiObject -Class SMS_ObjectContainerItem -Namespace $WMINameSpace -ComputerName $CMServer -Filter "ContainerNodeID = '$($FolderID)'").InstanceKey | Where-Object -FilterScript {$_.ObjectType -eq "257"}
$BootImages = (Get-WmiObject -Class SMS_ObjectContainerItem -Namespace $WMINameSpace -ComputerName $CMServer -Filter "ContainerNodeID = '$($FolderID)'").InstanceKey | Where-Object -FilterScript {$_.ObjectType -eq "258"}
$Applications = (Get-WmiObject -Class SMS_ObjectContainerItem -Namespace $WMINameSpace -ComputerName $CMServer -Filter "ContainerNodeID = '$($FolderID)'").InstanceKey | Where-Object -FilterScript {$_.ObjectType -eq "512"}

#$Packages = Get-WmiObject -ComputerName $CMServer -Namespace $WMINameSpace -Class SMS_TaskSequencePackageReference | Where-Object -Filterscript {$_.PackageID -eq $TSID} | Where-Object -FilterScript {$_.ObjectType -eq "0"}
#$DriverPackages = Get-WmiObject -ComputerName $CMServer -Namespace $WMINameSpace -Class SMS_TaskSequencePackageReference | Where-Object -Filterscript {$_.PackageID -eq $TSID} | Where-Object -FilterScript {$_.ObjectType -eq "3"}
#$OSImages = Get-WmiObject -ComputerName $CMServer -Namespace $WMINameSpace -Class SMS_TaskSequencePackageReference | Where-Object -Filterscript {$_.PackageID -eq $TSID} | Where-Object -FilterScript {$_.ObjectType -eq "257"}
#$BootImages = Get-WmiObject -ComputerName $CMServer -Namespace $WMINameSpace -Class SMS_TaskSequencePackageReference | Where-Object -Filterscript {$_.PackageID -eq $TSID} | Where-Object -FilterScript {$_.ObjectType -eq "258"}
#$Applications = Get-WmiObject -ComputerName $CMServer -Namespace $WMINameSpace -Class SMS_TaskSequencePackageReference | Where-Object -Filterscript {$_.PackageID -eq $TSID} | Where-Object -FilterScript {$_.ObjectType -eq "512"}

Write-Host "Modifying Packages..."
Foreach ($Object in $Packages)
  {
        try 
            {
                $Object = Get-WmiObject -Class SMS_Package -Namespace root\sms\site_$SiteCode -ComputerName $SMSProvider -Filter "PackageID ='$($Object)'"
                $Object = [wmi]$Object.__PATH
                $Object.PkgFlags = 16         # 16777216 for 'Manually copy content', 32 for 'Automatically download content', 16 for 'Download only changes'
                $Object.put() | Out-Null
                Write-Verbose "Successfully edited package $($Object.Name)."
            }
        catch
            {
                Write-Verbose "$($Object.Name) could not be edited."
            }
    }
Write-Host "Packages Fixed"

Write-Host "Modifying Driverpackages..."
Foreach ($Object in $DriverPackages)
  {
        try 
            {
                $Object = Get-WmiObject -Class SMS_Package -Namespace root\sms\site_$SiteCode -ComputerName $SMSProvider -Filter "PackageID ='$($Object)'"
                $Object = [wmi]$Object.__PATH
                $Object.PkgFlags = 16         # 16777216 for 'Manually copy content', 32 for 'Automatically download content', 16 for 'Download only changes'
                $Object.put() | Out-Null
                Write-Verbose "Successfully edited package $($Object.Name)."
            }
        catch
            {
                Write-Verbose "$($Object.Name) could not be edited."
            }
    }
Write-Host "Driverpackages fixed"

Write-Host "Modifying OS Images..."
Foreach ($Object in $OSImages)
  {
        try 
            {
                $Object = Get-WmiObject -Class SMS_Package -Namespace root\sms\site_$SiteCode -ComputerName $SMSProvider -Filter "PackageID ='$($Object)'"
                $Object = [wmi]$Object.__PATH
                $Object.PkgFlags = 16         # 16777216 for 'Manually copy content', 32 for 'Automatically download content', 16 for 'Download only changes'
                $Object.put() | Out-Null
                Write-Verbose "Successfully edited package $($Object.Name)."
            }
        catch
            {
                Write-Verbose "$($Object.Name) could not be edited."
            }
    }
Write-Host "OS Images fixed"

Write-Host "Modifying Bootimage..."
Foreach ($Object in $BootImages)
  {
        try 
            {
                $Object = Get-WmiObject -Class SMS_Package -Namespace root\sms\site_$SiteCode -ComputerName $SMSProvider -Filter "PackageID ='$($Object)'"
                $Object = [wmi]$Object.__PATH
                $Object.PkgFlags = 16         # 16777216 for 'Manually copy content', 32 for 'Automatically download content', 16 for 'Download only changes'
                $Object.put() | Out-Null
                Write-Verbose "Successfully edited package $($Object.Name)."
            }
        catch
            {
                Write-Verbose "$($Object.Name) could not be edited."
            }
    }
Write-Host "Bootimage fixed"

Write-Host "Modifying Applications..."
Foreach ($Object in $Applications)
  {
        try 
            {
                $Object = Get-WmiObject -Class SMS_Package -Namespace root\sms\site_$SiteCode -ComputerName $SMSProvider -Filter "PackageID ='$($Object)'"
                $Object = [wmi]$Object.__PATH
                $Object.PkgFlags = 16         # 16777216 for 'Manually copy content', 32 for 'Automatically download content', 16 for 'Download only changes'
                $Object.put() | Out-Null
                Write-Verbose "Successfully edited package $($Object.Name)."
            }
        catch
            {
                Write-Verbose "$($Object.Name) could not be edited."
            }
    }
Write-Host "Applications fixed"

Write-Host "Enf of Job"