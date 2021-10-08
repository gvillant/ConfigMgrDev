$LogSize = 15GB
write-output"Log Size = $LogSize"
$DiskSize = (get-disk -Number 0).Size
write-output "Disk Size = $DiskSize"
$OSSize = (get-partition -DriveLetter C).Size
write-output "OS Size = $OSSize"
$DataSize = $DiskSize - $OSSize - $LogSize
write-output "Data Size = $DataSize"

#Move CDRom drive(s) to Z:
$z=90; (gwmi Win32_cdromdrive).drive | %{$a=mountvol $_ /l; mountvol $_ /d; $a=$a.Trim(); $l=[char]$z+":"; mountvol $l $a; $z=$z-1}

#Data partition
new-partition -DiskNumber 0 -Size $DataSize -DriveLetter D | Format-Volume -FileSystem NTFS -NewFileSystemLabel "DATA"

#Log partition
new-partition -DiskNumber 0 -UseMaximumSize -DriveLetter E | Format-Volume -FileSystem NTFS -NewFileSystemLabel "LOGS"

