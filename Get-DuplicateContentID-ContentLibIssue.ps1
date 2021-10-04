$PathToDataLib = "f:\SCCMContentLib\DataLib" # Path to DataLib
 
####################################
# Get Legacy Package Folders
$folders = Get-ChildItem -LiteralPath $PathToDataLib | Where-Object { $_.Name.Length -ge 9 -and $_.Name.Length -le 11} | Select-Object -Property @{Name="Name";Expression={$_.Name.SubString(0,8)}}
$uniqueFolders = $folders | Select-Object -Property Name -Unique
 
# Display Statistics
Write-Host "Count of Folders found: $($folders.Count)"
Write-Host "Count of Unique Folders found: $($uniqueFolders.Count)"
Function Get-Duplicate {
    param($array, [switch]$count)
    begin {
        $hash = @{}
    }
    process {
        $array | %{ $hash[$_] = $hash[$_] + 1 }
        if($count) {
            $hash.GetEnumerator() | ?{$_.value -gt 1} | %{
                New-Object PSObject -Property @{
                    Value = $_.key
                    Count = $_.value
                }
            }
        }
        else {
            $hash.GetEnumerator() | ?{$_.value -gt 1} | %{$_.key}
        }    
    }
}
 
# Display Duplicated Packages
Get-Duplicate ($folders | Select -ExpandProperty Name) -count

