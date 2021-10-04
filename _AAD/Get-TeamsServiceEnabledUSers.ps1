
#Connect-AzureAD 
#Install-Module AzureAD -force

$Users = `
"Amar_Maouche",
"Christian_Girardon",
"Christophe_Leung",
"Cyrille_Fretay",
"Francesco_Scaccianoc",
"Gaetan_Villant",
"Gilles_Breton",
"Hendrik_Rijkens",
"Mauro_Sahanaja",
"Raphael_Sanz",
"Saad_Lahkim",
"Tarek_Haouami",
"Ben_Terry",
"Dean_Bloomfield",
"Scott_Melville",
"Mark_Burns",
"Peter_Malheiro"


$Obj = @()

foreach ($user in $Users) {
    $item = Get-AzureADUser -SearchString $user | Select GivenName, Surname, Department, CompanyName, City, Country, UserPrincipalName, Mobile -ExpandProperty AssignedPlans | where Service -eq "TeamspaceAPI" | where CapabilityStatus -eq "Enabled"
    #((Service -eq "TeamspaceAPI") -and (CapabilityStatus -eq "Enabled"))   | Format-Table #CapabilityStatus -eq "Enabled"
    #Get-AzureADUser -SearchString $user | Select GivenName, Surname, SipProxyAddress, Department, CompanyName, City, Country
    $obj += $item
}
$obj | Export-Csv -Force c:\temp\tc.csv -NoClobber -NoTypeInformation