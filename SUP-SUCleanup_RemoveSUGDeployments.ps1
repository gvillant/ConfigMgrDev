#Multidimensionnal array sous la forme suivante: ADR, SUG cible, filtre à appliquer.
$OfficeRegex = '32\s*bits'
$StepsArray = 
    @('FFF-Clients-Monthly-Noemie SIS (FFF) - Windows+Office - Lot2 - Prod', 'FFF-Baseline_Clients_OS-Windows', '( $_.isExpired -eq $false ) -and ( $_.LocalizedDisplayName -notMatch $OfficeRegex )'),
    @('FFF-Clients-Monthly-W7 - Office - Lot2 - Prod', 'FFF-Baseline_Clients_Office2013', '( $_.isExpired -eq $false )'),
    @('FFF-Servers-Monthly - Windows Security+Criticals - Lot2 - Prod', 'FFF-Baseline_Servers', '( $_.isExpired -eq $false )')

$SiteCode = 'FFF'
$Simulate = $true

Import-module ($Env:SMS_ADMIN_UI_PATH.Substring(0,$Env:SMS_ADMIN_UI_PATH.Length-5) + '\ConfigurationManager.psd1')
CD $SiteCode":"

function Run-Main {
$i=0

#Pour chaque enregistrement dans StepArray, execute les étapes suivantes
foreach ($line in $StepsArray) {
write-host Step ($i+1) : -ForegroundColor Green

#Renseigne la variable $SUGFilter
Set-variable -name SUGFilter -Value ( $StepsArray[$i][0] + '*' ) -scope 1
Write-Host SUGFilter: $SUGFilter -ForegroundColor yellow

#Renseigne la variable $SUGTarget
Set-variable -name SUGTarget -Value $StepsArray[$i][1] -scope 1
Write-Host SUGTarget: $SUGTarget -ForegroundColor yellow

#Renseigne la variable $UpdatesFilter
Set-variable -name UpdatesFilter -Value $StepsArray[$i][2] -scope 1
$sbUpdatesFilter = [scriptblock]::Create($UpdatesFilter)
Write-Host UpdatesFilter: $UpdatesFilter -ForegroundColor yellow

$i++

#Récupère la liste des SUG à traiter
get-SUGSourceList

Foreach ($SUGItem in $SUGSourceList)
    {
        $SUGSource = $SUGItem.LocalizedDisplayName
        write-host Start processing $SUGItem.LocalizedDisplayName -ForegroundColor Yellow
        add-UpdatesFromSUGSourcetoSUGTarget
        if ($simulate) {
        write-host Simulate: Change SUG Description to OLD - content copied to $SUGTarget -ForegroundColor White
        } 
        else {
        write-host Process: Change SUG Description to OLD - content copied to $SUGTarget -ForegroundColor White
        $SUGitem | set-CMSoftwareUpdateGroup -description "OLD - content copied to $SUGTarget"
        }

}

}
}

function get-SUGSourceList {
write-host "Building SUG List with filter $SUGFilter ..." -ForegroundColor DarkCyan

#Récupère la liste des SUG avec un déploiement actif, correspondant à $SUGFilter
$SUGSourceList = (Get-CMSoftwareUpdateGroup | Where-Object -FilterScript {( $_.LocalizedDisplayName -like $SUGFilter ) -and ( $_.IsDeployed -eq $true )})
write-host find $SUGSourceList.count SUG to process -ForegroundColor Green
Set-variable -name SUGSourceList -Value $SUGSourceList -scope 1
}

function add-UpdatesFromSUGSourcetoSUGTarget {
write-host "Building update's List for SUG $SUGSource ..." -ForegroundColor Yellow

#Récupère la liste des SU non-expirés, d'après le filtre fourni 
$SUList = (Get-CMSoftwareUpdate -UpdateGroupName $SUGSource | Where-Object -FilterScript $sbUpdatesFilter )
$SUListCount = $SUList.count
write-host find $SUListCount Updates non-expired to move from $SUGSource to $SUGTarget -ForegroundColor Green

$i = 0
ForEach ($SU in $SUList)
{
    $i++
    $SULocalizedDisplayName = $SU.LocalizedDisplayName
    write-progress -activity "Add Software updates to SUG $SUGTarget" -status "SU added: $i / $SUListCount - $SULocalizedDisplayName" -PercentComplete (($i / $SUList.count) * 100)
    if ($simulate) {
    write-host Simulate: $SU.LocalizedDisplayName to $SUGTarget -ForegroundColor White
    } 
    else {
    write-host Process: $SU.LocalizedDisplayName to $SUGTarget -ForegroundColor White
    $SU | Add-CMSoftwareUpdateToGroup -SoftwareUpdateGroupName "$SUGTarget"
    }
}
}

Function Log-ScriptEvent { 
 
########################################################################################################## 
<# 
.SYNOPSIS 
   Log to a file in a format that can be read by Trace32.exe / CMTrace.exe  
 
.DESCRIPTION 
   Write a line of data to a script log file in a format that can be parsed by Trace32.exe / CMTrace.exe 
 
   The severity of the logged line can be set as: 
 
        1 - Information 
        2 - Warning 
        3 - Error 
 
   Warnings will be highlighted in yellow. Errors are highlighted in red. 
 
   The tools to view the log: 
 
   SMS Trace - http://www.microsoft.com/en-us/download/details.aspx?id=18153 
   CM Trace - Installation directory on Configuration Manager 2012 Site Server - <Install Directory>\tools\ 
 
.EXAMPLE 
   Log-ScriptEvent c:\output\update.log "Application of MS15-031 failed" Apply_Patch 3 
 
   This will write a line to the update.log file in c:\output stating that "Application of MS15-031 failed". 
   The source component will be Apply_Patch and the line will be highlighted in red as it is an error  
   (severity - 3). 
 
#> 
########################################################################################################## 
 
#Define and validate parameters 
[CmdletBinding()] 
Param( 
      #Path to the log file 
      [parameter(Mandatory=$True)] 
      [String]$NewLog, 
 
      #The information to log 
      [parameter(Mandatory=$True)] 
      [String]$Value, 
 
      #The source of the error 
      [parameter(Mandatory=$True)] 
      [String]$Component, 
 
      #The severity (1 - Information, 2- Warning, 3 - Error) 
      [parameter(Mandatory=$True)] 
      [ValidateRange(1,3)] 
      [Single]$Severity 
      ) 
 
 
#Obtain UTC offset 
$DateTime = New-Object -ComObject WbemScripting.SWbemDateTime  
$DateTime.SetVarDate($(Get-Date)) 
$UtcValue = $DateTime.Value 
$UtcOffset = $UtcValue.Substring(21, $UtcValue.Length - 21) 
 
 
#Create the line to be logged 
$LogLine =  "<![LOG[$Value]LOG]!>" +` 
            "<time=`"$(Get-Date -Format HH:mm:ss.fff)$($UtcOffset)`" " +` 
            "date=`"$(Get-Date -Format M-d-yyyy)`" " +` 
            "component=`"$Component`" " +` 
            "context=`"$([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)`" " +` 
            "type=`"$Severity`" " +` 
            "thread=`"$([Threading.Thread]::CurrentThread.ManagedThreadId)`" " +` 
            "file=`"`">" 
 
#Write the line to the passed log file 
Add-Content -Path $NewLog -Value $LogLine 
 
} 
 
########################################################################################################## 


run-main
