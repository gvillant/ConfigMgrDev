$path = "G:\Backup_TaskSequences"
     
$ts = Get-CMTaskSequence -Name "W7x64-03.15.09"

foreach ($t in $ts){

     $exportname = $t.Name +".zip"

     Export-CMTaskSequence -TaskSequencePackageId $t.PackageID -ExportFilePath "$path\$exportname" -WithDependence $false -WithContent $false

     }

