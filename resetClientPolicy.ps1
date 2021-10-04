[cmdletbinding()]            
param(            
[string[]]$ComputerName = $env:ComputerName,            
[switch]$Purge = 0            
)            

if($Purge) {            
 $Gflag = 1            
} else {            
 $Gflag = 0            
}            

foreach($Computer in $ComputerName) {            
 $client = Get-WMIObject -Class SMS_Client -Namespace root\sms -ComputerName $Computer            
 $returnval = $Client.ResetPolicy($Gflag)            
 if($returnvalue) {            
 Write-Warning "Error occurred while resetting/purging the policy on $Computer"            
 } else {            
 Write-Host "Purge/Reset successful on $Computer"            
 }            
}

