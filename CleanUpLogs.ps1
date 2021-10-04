
$LogPath = 'C:\inetpub\logs\LogFiles\W3SVC1'
$maxDaystoKeep = -30
$outputPath = "E:\_Exploit\CleanUpLogs\CleanupLogs.log"

$itemsToDelete = get-childitem -path $LogPath -Recurse -File *.log | Where-Object {$_.LastWriteTime -lt ((get-date).AddDays($maxDaystoKeep))}

if ($itemsToDelete.Count -gt 0){
    ForEach ($item in $itemsToDelete){
        "$($item.BaseName) is older than $((get-date).AddDays($maxDaystoKeep)) and will be deleted" | Add-Content $outputPath
        Remove-Item -Verbose $item.FullName
    }
}
ELSE{ 
    "No items to be deleted today $($(Get-Date).DateTime)"  | Add-Content $outputPath
    }

Write-Output "Cleanup of log files older than $((get-date).AddDays($maxDaystoKeep)) completed..."
#start-sleep -Seconds 10

