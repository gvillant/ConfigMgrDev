#Bulk set services startupType. 

$StartupType = "Disabled"
$Services = @(  "CcmExec",
                "sms_executive",
                "SMS_SITE_COMPONENT_MANAGER",
                "SMS_SITE_SQL_BACKUP",
                "SMS_SITE_VSS_WRITER",
                "WsusService"
                "W3SVC"
                "WAS"
                )
                
foreach ($Service in $Services) {set-service $Service -StartupType $StartupType }
