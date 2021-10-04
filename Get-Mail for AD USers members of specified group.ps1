IMPORT-module activedirectory

$Users = $null

$Members = Get-ADGroupMember -Identity INFORMATIQUE_FFF

foreach ($member in $members) {
$Users += (Get-ADUser $member -properties mail).mail
$Users += "`n"
    }

$Users
