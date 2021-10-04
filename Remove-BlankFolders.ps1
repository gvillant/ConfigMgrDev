$SearchRoot = "E:\SMSPKGE$"

Get-ChildItem -Path $SearchRoot | ForEach-Object {
    if ($_.PSIsContainer -eq $true) {
        if ((Get-ChildItem -Path $_.FullName) -eq $null) {
            Write-Host "$($_.FullName) is empty."
			Remove-Item -Force $_.FullName
            Write-Host "$($_.FullName) removed." -ForegroundColor Yellow
        } else {
            Write-Host "$($_.FullName) is not empty."
        }
    }
} 
