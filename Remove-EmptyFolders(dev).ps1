$a = Get-ChildItem E:\SMSPKGE$ -recurse | Where-Object {$_.PSIsContainer -eq $True}
$a | Where-Object {$_.GetFiles().Count -eq 0 -and $_.GetDirectories().count -eq 0} | Select-Object FullName


$b = $a | Where-Object {$_.GetFiles().Count -eq 0 -and $_.GetDirectories().count -eq 0}

write-host Total folders count is $a.Count 
write-host Empty folders count is $b.count

$b | remove-item
