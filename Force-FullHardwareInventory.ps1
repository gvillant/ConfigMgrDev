#Set Hardware Inventory ID
$HardwareInventoryID = '{00000000-0000-0000-0000-000000000001}'

#Remove Class to force next inventory to be full
Get-WmiObject -Namespace 'Root\CCM\INVAGT' -Class 'InventoryActionStatus' -Filter "InventoryActionID='$HardwareInventoryID'" | Remove-WmiObject

#Trigger HwInv
Invoke-WmiMethod -Namespace root\ccm -Class sms_client -Name TriggerSchedule $HardwareInventoryID

