# The script check for client Authentication certificate Local Machine certificate store and return Compliant or not-Compliant

$ComputerName = $env:COMPUTERNAME
$Result = $null

Import-Module pki
Set-Location CERT:\LOCALMACHINE\my
#Set-Location 'Cert:\LOCALMACHINE\Remote Desktop\'

$Result = Get-ChildItem | where {$_.Subject -match $ComputerName}

if ($Result) {'Compliant'} else {'not-Compliant'}
