<#
param(
    [parameter(
	Position = 1, 
	Mandatory=$true )
	]
	[ValidateNotNullOrEmpty()]
    [DateTime]$TargetDate = "12/15/2016"
)
#>
$VerbosePreference = "Continue"
#$ErrorActionPreference = "SilentlyContinue" 
$SMSProvider = "FRPSCM01.stago.grp"
$AppliName = "SKYPE_FOR_BUSINESS_BASIC_2016_R01"

#$ColName = "EXCMIG-TEST" # "EXCMIG-PRQ2-Skype(FR) - Lot 02"
#$TargetDate = "12/15/2016"

$StepsArray = 
    @('EXCMIG-PRQ2-Skype(FR) - Lot 02','12/15/2015'),
    @('EXCMIG-PRQ2-Skype(FR) - Lot 03','12/16/2015'),
    @('EXCMIG-PRQ2-Skype(FR) - Lot 04','12/17/2015'),
    @('EXCMIG-PRQ2-Skype(FR) - Lot 05','12/18/2015'),
    @('EXCMIG-PRQ2-Skype(FR) - Lot 06','12/21/2015'),
    @('EXCMIG-PRQ2-Skype(FR) - Lot 07','12/22/2015'),
    @('EXCMIG-PRQ2-Skype(FR) - Lot 08','12/23/2015'),
    @('EXCMIG-PRQ2-Skype(FR) - Lot 09','12/24/2015'),
    @('EXCMIG-PRQ2-Skype(FR) - Lot 10','12/28/2015'),
    @('EXCMIG-PRQ2-Skype(FR) - Lot 11','12/29/2015'),
    @('EXCMIG-PRQ2-Skype(FR) - Lot 12','12/30/2015'),
    @('EXCMIG-PRQ2-Skype(FR) - Lot 13','01/04/2016'),
    @('EXCMIG-PRQ2-Skype(FR) - Lot 14','01/05/2016'),
    @('EXCMIG-PRQ2-Skype(FR) - Lot 15','01/06/2016')



#######################################################################################
Function Import-Module-CM {
import-module ($Env:SMS_ADMIN_UI_PATH.Substring(0,$Env:SMS_ADMIN_UI_PATH.Length-5) + '\ConfigurationManager.psd1')
Get-SiteCode
Set-location $SiteCode":"
}
#######################################################################################

#######################################################################################
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
#return $SiteCode
}
#######################################################################################

#Import-Module-CM


$i=0

#Pour chaque enregistrement dans StepArray, execute les étapes suivantes
foreach ($line in $StepsArray) {
write-host Step ($i+1) : -ForegroundColor Green


#Renseigne la variable $ColName
Set-variable -name ColName -Value $StepsArray[$i][0] #-scope 1
Write-Host ColName: $ColName -ForegroundColor yellow

#Renseigne la variable $TargetDate
Set-variable -name TargetDate -Value ( $StepsArray[$i][1] ) #-scope 1
Write-Host TargetDate: $TargetDate -ForegroundColor yellow


$i++


$ValidTargetDate = [dateTime]::Parse($TargetDate,([Globalization.CultureInfo]::CreateSpecificCulture('en-US')))
Write-Verbose "TargetDate is $TargetDate"

$TargetDate = Get-Date $ValidTargetDate
$FullTargetDate = Get-Date $TargetDate -format "dddd dd MMMM yyyy"

Write-Verbose "TargetDate is $TargetDate"
Write-Verbose "FullTargetDate is $FullTargetDate"


$AvailableTime	        = $TargetDate.AddHours(-15)      # 
$Deadline	            = $TargetDate.AddHours(+12)      # 

Write-Verbose "AvailableTime is $AvailableTime"
Write-Verbose "Deadline is $Deadline"


Write-Verbose "Deploy $AppliName to $ColName with Available $AvailableTime and deadline $Deadline "

Start-CMApplicationDeployment -CollectionName $ColName -Name $AppliName -AppRequiresApproval $False -AvailableDateTime $AvailableTime -DeadlineDateTime $Deadline -DeployAction Install -DeployPurpose Required -EnableMomAlert $False -OverrideServiceWindow $True -PreDeploy $False -RaiseMomAlertsOnFailure $False -RebootOutsideServiceWindow $True -SendWakeupPacket $False -TimeBaseOn LocalTime -UseMeteredNetwork $True -UserNotification HideAll
}
