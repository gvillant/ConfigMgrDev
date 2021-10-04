# Script: CreateSUGfromKBs.ps1
# Author: Phil Schwan, PLA
# Date: 03/12/2015
# Notes: Recommend turning off IE Enhanced Security to ensure that URL content is properly retrieved
# Requires ConfigMgr Powershell module and rights to connect to WMI of site server

$PSScriptRoot="E:\_Exploit\_Scripts"
$i=1
$SiteCode='STG'
$SiteServer='FRPSCM01'
$CIIDlist = $PSScriptRoot + '\CIIDs.txt'
$logfilename = $PSScriptRoot + '\CreateSUGfromKBs.log'
$SUGname = 'Multi-reboot Updates'
[array]$CIIDs = @()
[array]$KBs=@()
$url = "https://support.microsoft.com/en-us/kb/2894518"
function LogOutput
{
param (
[Parameter(Mandatory=$true)]
$message,
[Parameter(Mandatory=$true)]
$type )
switch ($type)
{
1 { $type = "Info"}
2 { $type = "Warning"}
3 { $type = "Error"}
}

$TZbias = (Get-WmiObject -Query "Select Bias from Win32_TimeZone").bias
$Time = Get-Date -Format "HH:mm:ss.fff"
$Date = Get-Date -Format "MM-dd-yyyy"
$Output = "<![LOG[$($message)]LOG]!><time=`"$($Time)+$($TZBias)`" date=`"$($Date)`" "
$Output += "component=`"$($Component)`" context=`"$($Context)`" type=`"$($Type)`" "
$Output += "thread=`"$($logfilename)`" file=`"$($logfilename)`">"
Out-File -InputObject $Output -Append -NoClobber -Encoding Default -FilePath "$logfilename"
Write-Host $message
}

LogOutput -message " " -type 1
LogOutput -message "Beginning evaluation of KB2894518 for new updates" -type 1
$result = Invoke-WebRequest $url
$result.AllElements | Where Class -eq "plink" | ForEach-Object {
$pos = $_.innertext.indexof('/kb/') + 3
if ($pos -gt 3)
{
$ExcludeKB = $_.innertext.Substring($pos,$_.innertext.Length-$POS).Trim().Replace("/","").Replace(")","")
$ExcludeKB = $ExcludeKB.Trim() #Catching a few trailing spaces that slip through
$KBs += $ExcludeKB
LogOutput -message "Searching for CI_IDs for $ExcludeKB" -type 1
$CIID = (gwmi -ns root\sms\site_$($SiteCode) -class sms_softwareupdate -ComputerName $SiteServer | where {$_.ArticleID -eq $ExcludeKB }).CI_ID
LogOutput -message "KB$i=$ExcludeKB" -type 1
LogOutput -message "CI_ID=$CIID" -type 1
$CIIDs += $CIID
}
$i++
}
LogOutput -message "List of KBs=$KBs" -type 1
LogOutput -message "List of CI_IDs=$CIIDs" -type 1
#Clearing out the extra null entries the WMI query returns
$CIIDs | out-file $CIIDlist -force
$CIIDs.Clear()
$CIIDs = Get-Content $CIIDlist
import-module $Env:SMS_ADMIN_UI_PATH\..\ConfigurationManager.psd1
Set-Location $sitecode":"
If (Get-CMSoftwareUpdateGroup -Name $SUGname) {
$i=0
$SUG = Get-CMSoftwareUpdateGroup -Name $SUGname
LogOutput -message "SUG $SUGname found. Updatingâ€¦" -type 1
foreach ($CI in $CIIDs){
if ($SUG.Updates -contains $CI){
LogOutput -message "Update CI_ID $CI already in $SUGname." -type 1
}
Else{
LogOutput -message "Update CI_ID $CI not in $SUGname. Adding update" -type 1
Add-CMSoftwareUpdateToGroup -SoftwareUpdateGroupName $SUGname -SoftwareUpdateID $CI
$i++
}
}
LogOutput -message "Added $i Software Updates to $SUGname." -type 1
}
Else {
    LogOutput -message "SUG $SUGname not found. Creating" -type 1
    New-CMSoftwareUpdateGroup -Name $SUGname -UpdateID $CIIDs
}

