$SMSClient = [wmiclass]"\\.\root\ccm\SMS_Client"
$returnvalue = $SMSClient.ResetPolicy(1)
if ($returnvalue) {
  Write-Warning "Error occurred while resetting the policy"
} else {
  Write-Host "Reset successful"
}
