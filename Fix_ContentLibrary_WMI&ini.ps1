
$DPsCollection = 'STG0028D'

$SMSProvider = $env:COMPUTERNAME

Function Get-SiteCode {
    $wqlQuery = "SELECT * FROM SMS_ProviderLocation"
    $a = Get-WmiObject -Query $wqlQuery -Namespace "root\sms" -ComputerName $SMSProvider
    $a | ForEach-Object {
        if($_.ProviderForLocalSite)
            {
                $script:SiteCode = $_.SiteCode
            }
    }

Write-host "SMSProvider is $SMSProvider."
Write-host "SiteCode is $SiteCode."
return $SiteCode
}

Function Import-Module-CM {
import-module ($Env:SMS_ADMIN_UI_PATH.Substring(0,$Env:SMS_ADMIN_UI_PATH.Length-5) + '\ConfigurationManager.psd1')
Get-SiteCode
Set-location $SiteCode":"
}

Function Set-LogPath {
$global:LogComponent = (split-path $MyInvocation.PSCommandPath -Leaf).Replace('.ps1','')
#Try to to connect to Microsoft.SMS.TSEnvironment to define if in TS.
Try {
    $tsenv = New-Object -COMObject Microsoft.SMS.TSEnvironment
    $global:LogFolder = $tsenv.Value("_SMSTSLogPath") 
    $global:LogFileName = (split-path $MyInvocation.PSCommandPath -Leaf).Replace('.ps1','.log')
    $global:LogPath = "$LogFolder\$LogFileName"
    Write-CMLog "Script is running inside a Task Sequence" 1 $LogComponent $LogPath 
    $RunningInTs = $True
    }
    Catch
    {
    $global:LogPath = $MyInvocation.ScriptName.Replace('.ps1','.log')
    Write-CMLog "Script is running outside a Task Sequence" 1 $LogComponent $LogPath 
    }
}

Function Write-CMLog {            
##  Function: Write-CMLog            
##  Purpose: This function writes CmTrace log format file to ScriptDir\ScriptName.log file     
##     1 = information
##     2 = warning
##     3 = error
## Example: Write-CMLog "Write something" 1 TEST $LogPath

PARAM(                     
    [String]$Message,                                  
    [int]$severity,                     
    [string]$component,
    [string]$LogPath                     
    )                                          
    $TimeZoneBias = Get-WmiObject -Query "Select Bias from Win32_TimeZone"                     
    $Date= Get-Date -Format "HH:mm:ss.fff"                     
    $Date2= Get-Date -Format "MM-dd-yyyy"                     
    $type=1                         
    
    "<![LOG[$Message]LOG]!><time=$([char]34)$date+$($TimeZoneBias.bias)$([char]34) date=$([char]34)$date2$([char]34) component=$([char]34)$component$([char]34) context=$([char]34)$([char]34) type=$([char]34)$severity$([char]34) thread=$([char]34)$([char]34) file=$([char]34)$([char]34)>"| Out-File -FilePath $LogPath -Append -NoClobber -Encoding ascii            
    }

Function Set-RegistryValue {
PARAM(                     
    [String]$RegPath,                                  
    [String]$RegName,                     
    [string]$RegValue,
    [string]$RegType                     
    ) 
    
<#
.EXAMPLE
#Set DisableLogonBackgroundImage 0
$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
$RegName = "DisableLogonBackgroundImage"
$RegValue = "0"
$RegType = "DWORD"
Set-RegistryValue $RegPath $RegName $RegValue $RegType
#>

if (!(Test-Path $RegPath))
  {
    Write-CMLog "Key $RegPath Does not exist, create it" 1 $LogComponent $LogPath
    Write-CMLog "Write Registry $RegPath - $RegName - $RegValue - $RegType" 1 $LogComponent $LogPath
    New-Item -Path $RegPath -Force | Out-Null
    New-ItemProperty -Path $RegPath -Name $RegName -Value $RegValue -PropertyType $RegType -Force | Out-Null}
   else {   
    Write-CMLog "Write Registry $RegPath - $RegName - $RegValue - $RegType" 1 $LogComponent $LogPath
    New-ItemProperty -Path $RegPath -Name $RegName -Value $RegValue -PropertyType $RegType -Force | Out-Null}
   }


$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition

#Import-Module-CM

#Set-LogPath

#Write-CMLog "*** Start Script ***" 1 $LogComponent $LogPath
#Write-CMLog "*** End script ***" 1 $LogComponent $LogPath


#$DPs = Get-CMDevice -CollectionId $DPsCollection

foreach ($DP in $DPs) {
$session = New-PSSession -ComputerName $DP.name

Invoke-Command -Session $session -Scriptblock {
Write-Host "==Connected to $env:COMPUTERNAME ==" -ForegroundColor Green
$WMIPkgList = Get-WmiObject -Namespace Root\SCCMDP -Class SMS_PackagesInContLib | Select -ExpandProperty PackageID | Sort-Object
$ContentLib = (Get-ItemProperty -path HKLM:SOFTWARE\Microsoft\SMS\DP -Name ContentLibraryPath)
$PkgLibPath = ($ContentLib.ContentLibraryPath) + "\PkgLib"
$PkgLibList = (Get-ChildItem $PkgLibPath | Select -ExpandProperty Name | Sort-Object)
$PkgLibList = ($PKgLibList | ForEach-Object {$_.replace(".INI","")})
$PksinWMIButNotContentLib = Compare-Object -ReferenceObject $WMIPkgList -DifferenceObject $PKgLibList -PassThru | Where-Object { $_.SideIndicator -eq "<=" } 
$PksinContentLibButNotWMI = Compare-Object -ReferenceObject $WMIPkgList -DifferenceObject $PKgLibList -PassThru | Where-Object { $_.SideIndicator -eq "=>" } 

if ($PksinWMIButNotContentLib){
Write-Host ========================================
Write-Host Items in WMI but not the Content Library
$PksinWMIButNotContentLib
}

if ($PksinContentLibButNotWMI){
Write-Host ========================================
Write-Host Items in Content Library but not WMI
$PksinContentLibButNotWMI
Write-Host ========================================
}

#Foreach ($Pkg in $PksinWMIButNotContentLib){ Get-WmiObject -Namespace Root\SCCMDP -Class SMS_PackagesInContLib -Filter "PackageID = '$Pkg'" | Remove-WmiObject -Confirm }
#Foreach ($Pkg in $PksinContentLibButNotWMI){ Remove-Item -Path "$PkgLibPath\$Pkg.INI" -Confirm }

}

remove-PSSession $session

}
