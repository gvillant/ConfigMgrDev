$data = ""
$file = "C:\Program Files\Microsoft Data Protection Manager\DPM\ActiveOwner\ACB357C7-EE84-4BB4-ABBD-AD5A218A9304"
$remediation = "false"

#region functions

function Remediate-DPM {
        $computer = gc env:computername
        $ComputerCountry = $computer.substring(0,2)
        #$ComputerCountry
        $app = "C:\Program Files\Microsoft Data Protection Manager\DPM\bin\SetDpmServer.exe"
        $arg1 = " -dpmservername cndpm01.stago.grp"
        $arg2 = " -dpmservername usdpm01.stago.grp"
        $arg3 = " -dpmservername frdpm02.stago.grp"
        
        switch ($ComputerCountry) {
            "CN" { start-process $app -ArgumentList $arg1 
            write-host "not-Compliant: remediate with SetDPMServer to $arg1"
            }
            
            "US" { start-process $app -ArgumentList $arg2
            write-host "not-Compliant: remediate with SetDPMServer to $arg2"
            }
            
            default { start-process $app -ArgumentList $arg3 
            write-host "not-Compliant: remediate with SetDPMServer to $arg3"
            }
         }
}

function Test-RegistryKeyValue {
    <#
    .SYNOPSIS
    Tests if a registry value exists.
    .DESCRIPTION
    The usual ways for checking if a registry value exists don't handle when a value simply has an empty or null value.  This function actually checks if a key has a value with a given name.
    .EXAMPLE
    Test-RegistryKeyValue -Path 'hklm:\Software\Carbon\Test' -Name 'Title'
    Returns 'True' if hklm:\Software\Carbon\Test contains a value named 'Title'.  'False' otherwise.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The path to the registry key where the value should be set.  Will be created if it doesn't exist.
        $Path,

        [Parameter(Mandatory=$true)]
        [string]
        # The name of the value being set.
        $Name
    )

    if( -not (Test-Path -Path $Path -PathType Container) )
    {
        return $false
    }

    $properties = Get-ItemProperty -Path $Path 
    if( -not $properties )
    {
        return $false
    }

    $member = Get-Member -InputObject $properties -Name $Name
    if( $member )
    {
        return $true
    }
    else
    {
        return $false
    }
}

#endregion


if (test-Path $file) {
$data = (Get-Content $file -Encoding ascii -TotalCount 1) # get first line of the file
$data = $data.replace("`0","") # remove NULL characters
$data = $data.substring(0,$data.IndexOf(".")) # get string before first .
}

$key = "HKLM:\SOFTWARE\Microsoft\Microsoft Data Protection Manager\Agent\ClientProtection"

############## NOT compliant : DPM Client is not installed > WARNING
if (test-path $key){
$configuredValue = (Get-ItemProperty -Path $key -Name BackupConfigured).BackupConfigured
   } 
    else {
        write-host "not-Compliant: DPM client is not installed"
        exit
        }
        
############## NOT compliant : DPMServer Not Set > WARNING
if ($data -eq "") {
    ############## Join DPMServer according ComputerCountry if $remediation = true
    if ($remediation -eq "true") {
    Remediate-DPM
     }
else {
    write-host "not-Compliant: DPMServer not set"
}
}
############## NOT compliant : DPMClient not approved or policies not sent to client
############## If Target server is FRDPM01 and $remediation = true , join new default DPM server
if (!($data -eq "") -and !($data -eq "FRDPM01") -and !($configuredValue -eq 2)) {
    write-host "not-Compliant: DPMClient is not approved on $data"
    }
    else {
    if (($data -eq "FRDPM01") -and !($configuredValue -eq 2)) {
        if ($remediation -eq "true") {
    Remediate-DPM 
            }
        else {
        write-host "not-Compliant: DPMClient is not approved on $data"
            }
        }
    }

############## NOT compliant : DPMClient approved but backup is older than 30 days.

#Retrieve LastBackupTime
if (!($data -eq "") -and $configuredValue -eq 2) {
    if (Test-RegistryKeyValue $key LastBackupTime) {

    $LastBackup = (Get-ItemProperty -Path $key -Name LastBackupTime).LastBackupTime

    [datetime]$today = (get-date).Date
    [datetime]$LastBackupDay = [datetime]::FromFileTime($LastBackup).Date

    #$LastBackupDay = $LastBackupDay.AddDays(-40)

    #Write-host Lastbackup Day is $LastBackupDay -ForegroundColor Green
    #Write-host Today is $today -ForegroundColor Cyan

    #calculate time difference between today and LastBackupTime
    $timeSpanTotalDays = ($Today - $LastBackupDay).TotalDays

    #Result Logic: If more than 30 days, then fails. 
    if ($timespanTotalDays -cge 30) 
        { write-host "not-Compliant: Backup is $timeSpanTotalDays days old." -ForegroundColor Red
        exit } 
        else 
        { 
        #write-host "Compliant" -foreground Green
        } 
    }
    else {
    write-host "not-Compliant: Cannot retrieve LastBackuptime in registry." -ForegroundColor Red
    exit }
}
 
 ############## compliant 
if (!($data -eq "") -and $configuredValue -eq 2) {
    if ($remediation -eq "true") {
    write-host "Compliant: DPMClient synced on $data" }
    else {
    write-host "Compliant"
    }
   }
