$VerbosePreference = "Continue"
$Coll = "EXCMIG-2016-02-09"
$SMSProvider = "FRPSCM01.stago.grp"


#######################################################################################
Function Import-Module-CM {
import-module ($Env:SMS_ADMIN_UI_PATH.Substring(0,$Env:SMS_ADMIN_UI_PATH.Length-5) + '\ConfigurationManager.psd1')
Get-SiteCode
Set-location $SiteCode":"
}
#######################################################################################

#######################################################################################
Function Get-SiteCode
{
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

Import-Module-CM

$User = get-aduser -filter {name -eq "adil de mirtas"}
$User

$FullUser = "STAGO\" + $User.SamAccountName
Write-Verbose $FullUser 

$CMUSer = Get-CMUser -name $FullUser

Add-CMUserCollectionDirectMembershipRule -CollectionName $Coll -Resource $CMUSer
