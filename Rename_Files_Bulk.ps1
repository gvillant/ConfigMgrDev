cd C:\Users\gaetan_villant\Dropbox\_Perso\Docs\impots

$Files = Get-ChildItem  -filter "*-*"

foreach ($file in $files) {
    write-host $file.Name
    #Rename-Item -NewName TP-$file -Path $file.Name
    }


