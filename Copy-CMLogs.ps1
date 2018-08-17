#############################################################################
# Author  : Gaëtan Villant 
# Website : www.dell.com
# 
# Version : 1.2
# Created : 2018/08/08
# Modified : - Add Logs 
#            - include CCM\Logs folder
#
# Purpose : This script copies logs to $SLShare\$TSID or $FallbackSLShare\$TSID if not exists.
#
#############################################################################

$FallbackSLShare = "\\TFPRDSCC10\TSLogs$"

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
    Catch {
        $global:LogPath = $MyInvocation.ScriptName.Replace('.ps1','.log')
        Write-CMLog "Script is running outside a Task Sequence" 1 $LogComponent $LogPath $true
    }
}

Function Write-CMLog {            
    <#  Function: Write-CMLog            
        Purpose: This function writes CmTrace log format file to $LogPath\ScriptName.log file     
            1 = information
            2 = warning
            3 = error
        Example: Write-CMLog "Write something" 1 TEST $LogPath
#>
    PARAM(                     
        [String]$Message,                                  
        [int]$severity,                     
        [string]$component,
        [string]$LogPath,
        [bool]$WriteHost = $False                    
        )                                          
    $TimeZoneBias = Get-WmiObject -Query "Select Bias from Win32_TimeZone"                     
    $Date= Get-Date -Format "HH:mm:ss.fff"                     
    $Date2= Get-Date -Format "MM-dd-yyyy"                     
    $type=1                         
    
    "<![LOG[$Message]LOG]!><time=$([char]34)$date+$($TimeZoneBias.bias)$([char]34) date=$([char]34)$date2$([char]34) component=$([char]34)$component$([char]34) context=$([char]34)$([char]34) type=$([char]34)$severity$([char]34) thread=$([char]34)$([char]34) file=$([char]34)$([char]34)>"| Out-File -FilePath $LogPath -Append -NoClobber -Encoding ascii
    
    #Write-host ? 
    if ($WriteHost) {
        write-host $Message
        }
}

Function Get-CMTSVariable ($TSVariableName) {
    try {
        $tsenv = New-Object -COMObject Microsoft.SMS.TSEnvironment
        $RunningInTs = $True
        }
        catch {
        Write-CMLog "Script is running outside a Task Sequence: cannot get value from TSVariable $TSVariableName" 2 $LogComponent $LogPath $True
        $RunningInTs = $False
        }
    
    if ($RunningInTs) {
        $TSVariableValue = $tsenv.value($TSVariableName)
        Write-CMLog "TSVariable $TSVariableName has value $TSVariableValue" 1 $LogComponent $LogPath 
        return $TSVariableValue
        }
    }

function Copy-CMLogs {
    #Create a temporary folder for logs staging
    New-Item -Path $env:TEMP\CMLogs -ItemType Directory -Force | out-null
    
    #copy $WINDOWS.~BT\Panther logs
    if (test-Path "C:\$WINDOWS.~BT\Sources\Panther") {
        #Create PantherBT subfolder
        New-Item -Path $env:TEMP\CMLogs\PantherBT -ItemType Directory -Force | out-null
        copy-item -Path "C:\$WINDOWS.~BT\Sources\Panther\*" -Include *.xml, *.log -Destination $env:TEMP\CMLogs\PantherBT
        }
        else {
        Write-CMLog "Did not found C:\$WINDOWS.~BT\Sources\Panther folder" 1 $LogComponent $LogPath
        }

    #copy Windows\Panther logs
    if (test-Path "C:\WINDOWS\Panther") {
        #Create PantherBT subfolder
        Write-CMLog "Copy Logs from C:\WINDOWS\Panther to $env:TEMP\CMLogs\Panther" 1 $LogComponent $LogPath
        New-Item -Path $env:TEMP\CMLogs\Panther -ItemType Directory -Force | out-null
        copy-item -Path "C:\WINDOWS\Panther\*" -Include *.xml, *.log -Destination $env:TEMP\CMLogs\Panther
        }
        else {
        Write-CMLog "Did not found C:\WINDOWS\Panther folder" 1 $LogComponent $LogPath
        }

    #copy Windows\CCM\Logs logs
    if (test-Path "C:\WINDOWS\CCM\Logs") {
        #Create CCMLogs subfolder
        Write-CMLog "Copy Logs from C:\WINDOWS\CCM\Logs to $env:TEMP\CMLogs\CCMLogs" 1 $LogComponent $LogPath
        New-Item -Path $env:TEMP\CMLogs\CCMLogs -ItemType Directory -Force | out-null
        copy-item -Path "C:\WINDOWS\CCM\Logs\*" -Include *.xml, *.log -Destination $env:TEMP\CMLogs\CCMLogs
        }
        else {
        Write-CMLog "Did not found C:\WINDOWS\CCM\Logs folder" 1 $LogComponent $LogPath
        }

    #copy CM(smsts) logs
    Write-CMLog "Copy Logs from $SourceLogPath to $env:TEMP\CMLogs,then zip and copy to destination $TargetLogPathFilename" 1 $LogComponent $LogPath $true
    Copy-Item -Path $SourceLogPath\* -Destination $env:TEMP\CMlogs -Force

    #zip and copy
    Write-CMLog "Zip and copy source folder $env:TEMP\CMLogs to destination folder $TargetLogPathFilename" 1 $LogComponent $LogPath    
    Compress-Archive -Path $env:TEMP\CMLogs\* -CompressionLevel Optimal -DestinationPath $TargetLogPathFilename
    
    #cleanup temporary folders
    Remove-Item $env:TEMP\CMLogs -Recurse
    Write-CMLog "Cleanup folder $env:TEMP\CMLogs" 1 $LogComponent $LogPath $true
    
}

function Get-Inventory ($InventoryFile) {
    
    #Get task sequence environment.
    $tsenv = New-Object -COMObject Microsoft.SMS.TSEnvironment

    
    #Create folder if not exists
    if (!(test-path $InventoryFile -ErrorAction SilentlyContinue)) {
        try {
            New-Item -Path $InventoryFile -ItemType File -Force -ea Stop | Out-Null}
        catch { $_.Exception.Message }
        }

    #Get WMI information
    $Bios =get-wmiobject win32_bios
    $Serial = $Bios.serialnumber
    $Hardware = get-wmiobject Win32_computerSystem 
    $Sysbuild = get-wmiobject Win32_WmiSetting 
    $OS = gwmi Win32_OperatingSystem
    $Networks = Get-WmiObject Win32_NetworkAdapterConfiguration | ? {$_.IPEnabled}
    $driveSpace = gwmi win32_volume -Filter 'drivetype = 3' | select PScomputerName, driveletter, label, @{LABEL='GBfreespace';EXPRESSION={"{0:N2}" -f($_.freespace/1GB)} } | Where-Object { $_.driveletter -match "C:" }
    $cpu = Get-WmiObject Win32_Processor 
    $totalMemory = [math]::round($Hardware.TotalPhysicalMemory/1024/1024/1024, 2)
    $lastBoot = $OS.ConvertToDateTime($OS.LastBootUpTime)

    #Task Sequence information
    $AdvertisementID = $tsenv.Value("_SMSTSAdvertID")
    $TaskSequenceID = $tsenv.value("_SMSTSPackageID")
    $PackageName = $tsenv.value("_SMSTSPackageName")
    $InstallationMode = $tsenv.value("_SMSTSLaunchMode")
    $LogTime = Get-Date -Format G 

    #Build Object
    $OutputObj = New-Object -Type PSObject
    $OutputObj | Add-Member -MemberType NoteProperty -Name ComputerName -Value $env:COMPUTERNAME.ToUpper()
    $OutputObj | Add-Member -MemberType NoteProperty -Name Manufacturer -Value $Hardware.Manufacturer
    $OutputObj | Add-Member -MemberType NoteProperty -Name Model -Value $Hardware.Model
    $OutputObj | Add-Member -MemberType NoteProperty -Name CPU_Info -Value $cpu.Name
    $OutputObj | Add-Member -MemberType NoteProperty -Name SystemType -Value $Hardware.SystemType
    $OutputObj | Add-Member -MemberType NoteProperty -Name BuildVersion -Value $SysBuild.BuildVersion
    $OutputObj | Add-Member -MemberType NoteProperty -Name OS -Value $OS.Caption
    $OutputObj | Add-Member -MemberType NoteProperty -Name SerialNumber -Value $Serial
    $OutputObj | Add-Member -MemberType NoteProperty -Name C:_GBfreeSpace -Value $driveSpace.GBfreespace
    $OutputObj | Add-Member -MemberType NoteProperty -Name Total_Physical_Memory -Value $totalMemory
    $OutputObj | Add-Member -MemberType NoteProperty -Name Last_Reboot -Value $lastboot

    #Retrieve IP settings.   
    $i=1
    foreach ($Network in $Networks) {
    $IPAddress  = $Network.IpAddress[0]
    $MACAddress  = $Network.MACAddress
    $OutputObj | Add-Member -MemberType NoteProperty -Name IPAddress$i -Value $IPAddress
    $OutputObj | Add-Member -MemberType NoteProperty -Name MACAddress$i -Value $MACAddress
    $i++
    }

    #Retrieve Task Sequence  
    $OutputObj | Add-Member -MemberType NoteProperty -Name AdvertisementID -Value $AdvertisementID
    $OutputObj | Add-Member -MemberType NoteProperty -Name TaskSequenceID -Value $TaskSequenceID
    $OutputObj | Add-Member -MemberType NoteProperty -Name PackageName -Value $PackageName
    $OutputObj | Add-Member -MemberType NoteProperty -Name InstallationMode -Value $InstallationMode
    $OutputObj | Add-Member -MemberType NoteProperty -Name LogTime -Value $LogTime

    #Export to file
    $outputObj | out-file $InventoryFile -Force
}

function Set-FileName {
    #Build Filename : %COMPUTERNAME%_%DATE-HOUR%_%ERRORRETURNCODE%
    $ErrorReturnCode = Get-CMTSVariable "ErrorReturnCode"
    if ($ErrorReturnCode) {
        $FileNameSuffix = "_ERROR_$($ErrorReturnCode)"
        Write-CMLog "Task sequence finished with an error! ErrorReturnCode: $ErrorReturnCode " 2 $LogComponent $LogPath
    } else 
        {$FileNameSuffix = ""
    }
    $ComputerName = $env:COMPUTERNAME
    $Date = get-date -Format yyyyMMdd-HHmmss
    $Filename = "$($ComputerName)_$($Date)$FileNameSuffix.zip"
    return $Filename
}

#region MAIN
Set-LogPath

#Define destination archive folder, if variable SLShare exists, use it, otherwise use FallbackSLShare
$TSID = Get-CMTSVariable "_SMSTSPackageID"
$TargetLogPath = Get-CMTSVariable "SLShare"
$TargetLogPath = "$TargetLogPath\$TSID"
if ($TargetLogPath -like "\\*") {
    Write-CMLog "valid SLShare variable found, use it as destination folder: $TargetLogPath" 1 $LogComponent $LogPath
    } 
    else {
    $TargetLogPath = "$FallbackSLShare\$TSID"
    Write-CMLog "valid SLShare variable not found, use default folder: $TargetLogPath" 2 $LogComponent $LogPath
    }

#Create file if not exists
if (!(test-path $TargetLogPath -ErrorAction SilentlyContinue)) {
    Write-CMLog "$TargetLogPath does not exists. Create it." 1 $LogComponent $LogPath
    try {
        New-Item -Path $TargetLogPath -ItemType Directory -ea Stop | Out-Null}
    catch { $Error = $_.Exception.Message }
    Write-CMLog "Error creating folder: $Error" 2 $LogComponent $LogPath
    }

#Build Filename Computername_yyyy-mm-dd ... 
$FileName = Set-FileName

$SourceLogPath = Get-CMTSVariable "_SMSTSLogPath"
#Test: $SourceLogPath = "C:\Windows\CCM\Logs"

$TargetLogPathFilename = "$($TargetLogPath)\$($FileName)"

#Get quick inventory
Write-CMLog "Get inventory and copy results to $env:TEMP\CMLogs\inventory.txt" 1 $LogComponent $LogPath $true
Get-Inventory "$env:TEMP\CMlogs\inventory.txt"

#Copy, compress and move logs to server.
Copy-CMLogs

#endregion
