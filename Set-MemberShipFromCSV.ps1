#
# Gaëtan VILLANT @ DELL
# Read CSV file and add users to groups - PowerShell Script
# Generate separate logfiles for group or user errors. 
# CSV file should be formated with 2 columns "Package_Nom_groupe_AD" and "Login"

$CSVFile = "E:\_exploit\Users.csv"
$GroupErrorLog = "E:\_exploit\GroupErrors.log"
$UserErrorLog = "E:\_exploit\UserErrors.log"
$SuccessLog = "E:\_exploit\ScriptSuccess.log"

Import-module ActiveDirectory 
Import-CSV $CSVFile | % { 
        try {
              $ADGroup = $_.Package_Nom_groupe_AD
              $UserLogin = $_.Login
              Get-ADGroup -Identity $_.Package_Nom_groupe_AD
                try {
                Add-ADGroupMember -Identity $_.Package_Nom_groupe_AD -Member $_.Login
                write-host "$(Get-Date) - SUCCESS : user $UserLogin added to Group $ADGroup : $_" -ForegroundColor DarkGreen
                "$(Get-Date) - SUCCESS : user $UserLogin added to Group $ADGroup : $_" | Add-Content $SuccessLog
                }
                Catch {
                $FailedItem = $UserLogin
                write-host "$(Get-Date) - ERROR : User $FailedItem : $_" -ForegroundColor Red
                "$(Get-Date) - ERROR : User $FailedItem : $_" | Add-Content $UserErrorLog
                    }        
                }
        Catch {
               $FailedItem =  $ADGroup
               write-host "$(Get-Date) - ERROR : Group $FailedItem : $_" -ForegroundColor Red
               "$(Get-Date) - ERROR : Group $FailedItem : $_" | Add-Content $GroupErrorLog
            }
    } 
