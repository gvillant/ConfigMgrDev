#New-PSSession -ComputerName FRS06030

$Target = "FRS06038"

psexec \\FRS06038 -h -d -s powershell.exe "enable-psremoting -force"

Enter-PSSession -ComputerName $Target


