<# 
.SYNOPSIS 
Delete Specified Item(s) From CCM Cache
.DESCRIPTION 
Uses ContentIDs to identify (ALL SOFTWARE UPDATES) and purge content from the local ccm cache - Created by Gary Blok @gwblok
Partial Code borrowed from: https://gallery.technet.microsoft.com/scriptcenter/Deleting-the-SCCM-Cache-da03e4c7
Assist by Keith S. Garner @keithga1
.LINK
https://garytown.com
#> 
   
$Logfile = "c:\windows\temp\Remove-CCMCacheContent.log"
# Connect to resource manager COM object    
$CMObject = New-Object -ComObject 'UIResource.UIResourceMgr' 
 
# Using GetCacheInfo method to return cache properties 
$CMCacheObjects = $CMObject.GetCacheInfo() 
 
# Delete Cache item 
$CMCacheObjects.GetCacheElements() | Where-Object { $_.ContentID | Select-String -Pattern '^[\dA-F]{8}-(?:[\dA-F]{4}-){3}[\dA-F]{12}$' }   | ForEach-Object { 
    $CMCacheObjects.DeleteCacheElement($_.CacheElementID)
    Add-Content $Logfile -value "Deleted: Name: $($_.ContentID)  Version: $($_.ContentVersion)"
    Write-Host "Deleted: Name: $($_.ContentID)  Version: $($_.ContentVersion)" -BackgroundColor Red 
}   