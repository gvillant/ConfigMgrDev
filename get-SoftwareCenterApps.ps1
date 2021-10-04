$softwareCenter = New-Object -ComObject "UIResource.UIResourceMgr"

$Apps = $softwareCenter.GetAvailableApplications()
