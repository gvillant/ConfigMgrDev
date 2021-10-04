$remediation =$true
$LogPath = "C:\inetpub\logs\LogFiles\W3SVC1"
$maxDaystoKeep = -0
$outputPath = "C:\inetpub\logs\LogFiles\CleanupLogs.log"

$itemsToDelete = get-childitem -path $LogPath -Recurse -File *.log | Where-Object {$_.LastWriteTime -lt ((get-date).AddDays($maxDaystoKeep))}

if ($remediation) {
"------------- Start script Remediation ON -------------" | Add-Content $outputPath
} else {
"------------- Start script Remediation OFF -------------" | Add-Content $outputPath
}

if ($itemsToDelete.Count -gt 0) {
    ForEach ($item in $itemsToDelete) {
        if ($remediation -eq $false) {
            "$($item.BaseName) is older than $((get-date).AddDays($maxDaystoKeep)) and should be deleted" | Add-Content $outputPath
            Write-Output "not-Compliant"    
                }
        else {
            Remove-Item -Verbose $item.FullName
            "$($item.BaseName) is older than $((get-date).AddDays($maxDaystoKeep)) is deleted" | Add-Content $outputPath
            }
        }
   }

else {
    "No items to be deleted today $($(Get-Date).DateTime)" | Add-Content $outputPath
    Write-Output "Compliant"
    }

"Cleanup of log files older than $((get-date).AddDays($maxDaystoKeep)) completed..."  | Add-Content $outputPath
"------------- End script -------------" | Add-Content $outputPath
#start-sleep -Seconds 10
