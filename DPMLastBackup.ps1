function Test-RegistryKeyValue
{
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


#EXAMPLE1  130861060894900000 = 9/7/2015, 4:14:28 PM

#Retrieve LastBackupTime
$key = "HKLM:\SOFTWARE\Microsoft\Microsoft Data Protection Manager\Agent\ClientProtection"

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
    { write-host "not-Compliant: Backup is $timeSpanTotalDays days old." -ForegroundColor Red } 
    else 
    { write-host "Compliant" -foreground Green} 
}
else {
write-host "not-Compliant: Cannot retrieve LastBackuptime in registry." -ForegroundColor Red
}

