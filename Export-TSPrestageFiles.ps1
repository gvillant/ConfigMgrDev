<#
.SYNOPSIS
 Exports all references in a task sequence as .pkgx files

.DESCRIPTION
 Exports all Packages, Applications, OS Images, Bootimages and Driverpackages referenced by a Task Sequence as .pkgx files to desired location.
 Specify the -ContentDistribution parameter as $True to start contentdistribution as well (Also requires the -DestionationDP parameter).
 Use FQDN server names.

.EXAMPLE
 .\Export-TSPrestageFiles.ps1 -CMServer Server1.domain.local -SiteCode 123 -SourceDP DP1.domain.local -TSID 1230001

.NOTES
 Created by Kristoffer Henriksson
#>



[CmdletBinding()]
param(
#    [Parameter(Mandatory=$True,Helpmessage="Please Enter Site Server Name")]
#    [String]$CMServer,

#    [Parameter(Mandatory=$True,Helpmessage="Please Enter Sitecode")]
#    [String]$SiteCode,

#    [Parameter(Mandatory=$True,Helpmessage="Please Enter Source DP")]
#    [String]$SourceDP,

    [Parameter(Mandatory=$True,Helpmessage="Please Enter Task Sequence ID")]
    [String]$TSID,

    [Parameter(Mandatory=$False)]
    [String]$Filepath = "E:\_PrestagedContent\$TSID",

    [Parameter(Mandatory=$False)]
    $ContentDistribution = $False,

    [Parameter(Mandatory=$False)]
    $DestinationDP
    )

$CMServer = 'FRPSCM01'
$SiteCode = 'STG'
$SourceDP = $env:computerName + '.stago.grp'

#CREATE FOLDER IF NOT EXISTS
if(!(Test-Path -Path $Filepath )){
    New-Item -ItemType directory -Path $Filepath
}

Import-Module -Name "${env:ProgramFiles(x86)}\Configuration Manager\Console\bin\ConfigurationManager.psd1"
CD $SiteCode":"

$SMS_WMI = "root\SMS\site"
$WMINameSpace = $SMS_WMI + "_" + $SiteCode

Write-Host "Retrieving Task Sequence References from WMI..."
$Packages = Get-WmiObject -ComputerName $CMServer -Namespace $WMINameSpace -Class SMS_TaskSequencePackageReference | Where-Object -Filterscript {$_.PackageID -eq $TSID} | Where-Object -FilterScript {$_.ObjectType -eq "0"}
$DriverPackages = Get-WmiObject -ComputerName $CMServer -Namespace $WMINameSpace -Class SMS_TaskSequencePackageReference | Where-Object -Filterscript {$_.PackageID -eq $TSID} | Where-Object -FilterScript {$_.ObjectType -eq "3"}
$OSImages = Get-WmiObject -ComputerName $CMServer -Namespace $WMINameSpace -Class SMS_TaskSequencePackageReference | Where-Object -Filterscript {$_.PackageID -eq $TSID} | Where-Object -FilterScript {$_.ObjectType -eq "257"}
$BootImages = Get-WmiObject -ComputerName $CMServer -Namespace $WMINameSpace -Class SMS_TaskSequencePackageReference | Where-Object -Filterscript {$_.PackageID -eq $TSID} | Where-Object -FilterScript {$_.ObjectType -eq "258"}
$Applications = Get-WmiObject -ComputerName $CMServer -Namespace $WMINameSpace -Class SMS_TaskSequencePackageReference | Where-Object -Filterscript {$_.PackageID -eq $TSID} | Where-Object -FilterScript {$_.ObjectType -eq "512"}

Write-Host "Exporting Packages..."
Foreach ($Object in $Packages){
    $FileName = $Filepath + "\" + $Object.ObjectID + ".pkgx"
        Publish-CMPrestageContent -DistributionPointName $SourceDP -FileName $FileName -PackageId $Object.ObjectID
        if($ContentDistribution -eq $True){
            Start-CMContentDistribution -PackageId $Object.ObjectID -DistributionPointName $DestinationDP
            }
        Write-Host $Object.ObjectName" Exported to" $Filepath
    }
Write-Host "Packages Exported"

Write-Host "Exporting Driverpackages..."
Foreach ($Object in $DriverPackages){
    $FileName = $Filepath + "\" + $Object.ObjectID + ".pkgx" 
        Publish-CMPrestageContent -DistributionPointName $SourceDP -DriverPackageId $Object.ObjectID -FileName $FileName 
        if($ContentDistribution -eq $True){
            Start-CMContentDistribution -DriverPackageId $Object.ObjectID -DistributionPointName $DestinationDP
            }
        Write-Host $Object.ObjectName" Exported to" $Filepath
    }
Write-Host "Driverpackages Exported"

Write-Host "Exporting OS Images..."
Foreach ($Object in $OSImages){
    $FileName = $Filepath + "\" + $Object.ObjectID + ".pkgx"
        Publish-CMPrestageContent -DistributionPointName $SourceDP -FileName $FileName -OperatingSystemImageId $Object.ObjectID
        if($ContentDistribution -eq $True){
            Start-CMContentDistribution -OperatingSystemImageId $Object.ObjectID -DistributionPointName $DestinationDP
            }
        Write-Host $Object.ObjectName" Exported to" $Filepath
    }
Write-Host "OS Images Exported"

Write-Host "Exporting Bootimage..."
Foreach ($Object in $BootImages){
    $FileName = $Filepath + "\" + $Object.ObjectID + ".pkgx"
        Publish-CMPrestageContent -BootImageId $Object.ObjectID -DistributionPointName $SourceDP -FileName $FileName
        if($ContentDistribution -eq $True){
            Start-CMContentDistribution -BootImageId $Object.ObjectID -DistributionPointName $DestinationDP
            }
        Write-Host $Object.ObjectName" Exported to" $Filepath
    }
Write-Host "Bootimage Exported"

Write-Host "Exporting Applications..."
Foreach ($Object in $Applications){
    $FileName = $Filepath + "\" + $Object.RefPackageID + ".pkgx"
        Publish-CMPrestageContent -ApplicationName $Object.ObjectName -DistributionPointName $SourceDP -FileName $FileName
        if($ContentDistribution -eq $True){
            Start-CMContentDistribution -ApplicationName $Object.ObjectName -DistributionPointName $DestinationDP
            }
        Write-Host $Object.ObjectName" Exported to" $Filepath
    }
Write-Host "Applications Exported"

$TSName = (Get-CMTaskSequence -TaskSequencePackageId $TSID).Name
Write-Host "All References from $TSName Exported"
