#Backup GPO linked in the specified OU

$TargetOU = "OU=w10,DC=stago,DC=grp"
$BackupPath = "c:\temp\GPO\W10\"

import-module activedirectory

$LinkedGPOs = Get-ADOrganizationalUnit -Filter {DistinguishedName -eq $TargetOU} | select -ExpandProperty LinkedGroupPolicyObjects
$GUIDRegex = "{[a-zA-Z0-9]{8}[-][a-zA-Z0-9]{4}[-][a-zA-Z0-9]{4}[-][a-zA-Z0-9]{4}[-][a-zA-Z0-9]{12}}"

foreach($LinkedGPO in $LinkedGPOs) {
    $result = [Regex]::Match($LinkedGPO,$GUIDRegex);
    if($result.Success) {
        $GPOGuid = $result.Value.TrimStart("{").TrimEnd("}")
        Get-GPO -Guid $GPOGuid | Backup-GPO -Path $BackupPath
    }
}
