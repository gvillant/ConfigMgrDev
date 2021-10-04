#Get SLIC Table Status and Bios ProducKey 
$LicencingService = Get-WMIObject -Class SoftwareLicensingService

write-host "0=No SLIC table, 1=SLIC table with Windows marker, 2=SLIC table without Windows marker, 3=Corrupted or invalid SLIC table"
Write-host "OA2xBiosMarkerStatus = $($LicencingService.OA2xBiosMarkerStatus)"
Write-Host "OA3xOriginalProductKey =  $($LicencingService.OA3xOriginalProductKey)"

#$LicencingService
