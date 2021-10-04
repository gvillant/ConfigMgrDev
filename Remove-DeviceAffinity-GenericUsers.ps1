
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

Function Write-CMLog {            
##  Function: Write-CMLog            
##  Purpose: This function writes CmTrace log format file to ScriptDir\ScriptName.log file     
##     1 = information
##     2 = warning
##     3 = error

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


$LogPath = $MyInvocation.MyCommand.Definition.Replace('.ps1','.log')

Write-CMLog "*** Start Script ***" 1 MAIN $LogPath
Write-CMLog "Script started by $Env:Username" 1 MAIN $LogPath

#Step 1: Suppression des affinités pour la liste des comptes connus suivants
$GenericUsers = (   'tf1\preparation',
                    'tf1\support_vsn',
                    'TF1\scanuser',
                    'TF1\EXPRIMM_cdpa',
                    'TF1\infotf1',
                    'TF1\cockpite',
                    'TF1\S_ilook_R',
                    'TF1\cross',
                    'TF1\defcon1',
                    'TF1\demotf1',
                    'TF1\pcs',
                    'TF1\pcs_incendie',
                    'TF1\redacinf',
                    'TF1\rfmc',
                    'TF1\sbrinks',
                    'TF1\quaitf1',
                    'TF1\regaudio',
                    'TF1\audito',
                    'TF1\pcs_mss',
                    'TF1\respentretien',
                    'TF1\rfinale',
                    'TF1\securitasresporg')

foreach ($User in $GenericUsers){
    $Affinities = (Get-CMUserDeviceAffinity -UserName $User)
    Write-Host -ForegroundColor Cyan "Found $($Affinities.count) Affinity(ies) for $User"
    Write-CMLog "Found $($Affinities.count) Affinity(ies) for $User" 2 GenericUsers $LogPath
    foreach ($Affinity in (Get-CMUserDeviceAffinity -UserName $User)) {
    Remove-CMDeviceAffinityFromUser -UserName $Affinity.UniqueUserName -DeviceName $Affinity.ResourceName -Force
    #Write-host Remove affinity $Affinity.UniqueUserName - $Affinity.ResourceName
    Write-CMLog "Remove affinity $($Affinity.UniqueUserName) - $($Affinity.ResourceName)" 1 GenericUsers $LogPath    }
    }

#Step 2: Suppression des affinités des users admins, scripts ...  ($*, X_PRD_* ...) 

#Spécifier ici la collection cible
$DeviceCollectionName = "D - ST - ALL - Clients Workstations"
Write-CMLog "Target Collection: $DeviceCollectionName" 2 ScriptUsers $LogPath

$CollectionQuery = Get-CimInstance -Namespace "Root\SMS\Site_$SiteCode" -ClassName "SMS_Collection" -Filter "Name='$DeviceCollectionName' and CollectionType='2'"
Write-CMLog "Collection members count: $($CollectionQuery.MemberCount)" 1 ScriptUsers $LogPath

$ResourcesInCollection = Get-CimInstance -Namespace "Root\SMS\Site_$SiteCode" -ClassName "SMS_CollectionMember_a"  -Filter "CollectionID='$($CollectionQuery.CollectionID)'"

$UDARelationShips = @()

foreach($item in $ResourcesInCollection){
    $UDA = Get-CimInstance -Namespace "Root\SMS\Site_$SiteCode" -ClassName "SMS_UserMachineRelationship" -Filter "ResourceID='$($item.ResourceID)'"
    foreach($Rel in $UDA){
        Write-Progress -Activity "Exporting UDA information" -Status "Processing resource $($item.ResourceID)"
        $DObject = New-Object PSObject
        $DObject | Add-Member -MemberType NoteProperty -Name "RelationshipResourceID" -Value $Rel.RelationshipResourceID
        $DObject | Add-Member -MemberType NoteProperty -Name "CollectionName" -Value $DeviceCollectionName
        $DObject | Add-Member -MemberType NoteProperty -Name "ResourceName" -Value $Rel.ResourceName
        $DObject | Add-Member -MemberType NoteProperty -Name "ResourceID" -Value $Rel.ResourceID
        $DObject | Add-Member -MemberType NoteProperty -Name "UniqueUserName" -Value $Rel.UniqueUserName
        $DObject | Add-Member -MemberType NoteProperty -Name "CreationTime" -Value $Rel.CreationTime
        $DObject | Add-Member -MemberType NoteProperty -Name "IsActive" -Value $Rel.IsActive
        $UDARelationShips += $DObject
        }
    }
    
#Suppression de l'affinité si l'utilisateur matche TF1\$*
$UDARelationShips | ?{$_.UniqueUserName -like 'tf1\$*'} | % {
    Write-Host "Delete $($_.UniqueUserName) - $($_.ResourceName)"
    Write-CMLog "Delete $($_.UniqueUserName) - $($_.ResourceName)" 1 AdminsUsers $LogPath
    Remove-CMDeviceAffinityFromUser -UserName $_.UniqueUserName -DeviceName $_.ResourceName -Force
    }

#Suppression de l'affinité si l'utilisateur matche DSY\U_PRD_*
$UDARelationShips | ?{$_.UniqueUserName -like 'DSY\U_PRD_*'} | % {
    Write-Host "Delete $($_.UniqueUserName) - $($_.ResourceName)"
    Write-CMLog "Delete $($_.UniqueUserName) - $($_.ResourceName)" 1 ScriptUsers $LogPath
    Remove-CMDeviceAffinityFromUser -UserName $_.UniqueUserName -DeviceName $_.ResourceName -Force
    }
    
#Suppression de l'affinité si l'utilisateur matche TF1\X_PRD_*
$UDARelationShips | ?{$_.UniqueUserName -like 'TF1\X_PRD_*'} | % {
    Write-Host "Delete $($_.UniqueUserName) - $($_.ResourceName)"
    Write-CMLog "Delete $($_.UniqueUserName) - $($_.ResourceName)" 1 ScriptUsers $LogPath
    Remove-CMDeviceAffinityFromUser -UserName $_.UniqueUserName -DeviceName $_.ResourceName -Force
    }

#Suppression de l'affinité si l'utilisateur matche TF1\USR_PRD_*
$UDARelationShips | ?{$_.UniqueUserName -like 'TF1\USR_PRD_*'} | % {
    Write-Host "Delete $($_.UniqueUserName) - $($_.ResourceName)"
    Write-CMLog "Delete $($_.UniqueUserName) - $($_.ResourceName)" 1 ScriptUsers $LogPath
    Remove-CMDeviceAffinityFromUser -UserName $_.UniqueUserName -DeviceName $_.ResourceName -Force
    }

   Write-CMLog "*** End Script ***" 1 MAIN $LogPath