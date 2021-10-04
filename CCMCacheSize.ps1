
function Get-CCMCacheSize {
$Cache = Get-WmiObject -namespace root\ccm\SoftMgmtAgent -class CacheConfig
$check = $Cache.Size
$Location = $Cache.Location
$check
$Location
}


function Set-CCMCacheSize {
$Cache = Get-WmiObject -namespace root\ccm\SoftMgmtAgent -class CacheConfig
$Cache.size = 13312
$Cache.InUse = "True"
$Cache.Put()
Restart-Service ccmexec
}


Get-CCMCacheSize
#Set-CCMCacheSize
