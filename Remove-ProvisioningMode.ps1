$ComputerName = $env:COMPUTERNAME
$ArgumentList = @($false)
Invoke-WmiMethod -Namespace "root\ccm" -Class "SMS_Client" -Name "SetClientProvisioningMode" -ComputerName $ComputerName -ArgumentList $ArgumentList
