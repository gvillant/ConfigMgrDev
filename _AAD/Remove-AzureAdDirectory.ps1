
$DirectoryName = "ModernLab190625"

$User="ADMIN@$($DirectoryName).onmicrosoft.com"
$PasswordTmp = "Camu9533"
$Password="MBcart514K"
$SecurePassword = $Password | ConvertTo-SecureString -AsPlainText -Force
$msolcred = New-Object -TypeName System.Management.Automation.PSCredential ($User,$SecurePassword)

#Prerequisite: install AzureRM module with Install-Module -Name AzureRM -AllowClobber (not working from Dell network)

try {
    connect-AzureAD -credential $msolcred -ErrorAction Stop
    } 
catch {
    write-host "cannot connect : $($error.exception)"
    break
    }

$CSVFileUsers = "C:\temp\users_$($DirectoryName).csv"

# *** Remove app registrations ***
Connect-AzureRmAccount -Credential $msolcred
Get-AzureRmADApplication | select DisplayName
Get-AzureRmADApplication | Remove-AzureRmADApplication -Force

# *** Remove Enterprise applications ***
Connect-MsolService -Credential $msolcred
Get-MsolServicePrincipal | select DisplayName

#Get-MsolServicePrincipal | try {Remove-MsolServicePrincipal} catch {"cannot remove: $($error.exception)"}
Get-MsolServicePrincipal | Remove-MsolServicePrincipal

# *** Remove all users but global admin ***
#get a list of all users by running this command
Get-MsolUser -All | Export-CSV $CSVFileUsers -Force -NoClobber -NoTypeInformation -Append
$Users = Import-Csv $CSVFileUsers | where {$_.UserPrincipalName -ne $User}

$Users.UserPrincipalName

#$Users | try {Remove-MsOlUser -Force} catch {"cannot remove: $($error.exception)"}
$Users | Remove-MsOlUser -Force