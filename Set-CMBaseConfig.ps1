$SMSProvider = $env:computername

#######################################################################################
Function Import-Module-CM {
import-module ($Env:SMS_ADMIN_UI_PATH.Substring(0,$Env:SMS_ADMIN_UI_PATH.Length-5) + '\ConfigurationManager.psd1')
Get-SiteCode
Set-location $SiteCode":"
}
#######################################################################################

#######################################################################################
Function Get-SiteCode
{
    $wqlQuery = "SELECT * FROM SMS_ProviderLocation"
    $a = Get-WmiObject -Query $wqlQuery -Namespace "root\sms" -ComputerName $SMSProvider
    $a | ForEach-Object {
        if($_.ProviderForLocalSite)
            {
                $script:SiteCode = $_.SiteCode
            }
    }

Write-host "SMSProvider is $SMSProvider."
Write-host "SiteCode is $SiteCode."
return $SiteCode
}
#######################################################################################

#######################################################################################
Function Set-CMBaseConfig {
#$sitecode = "PS1"
$SMSProvider = $env:computername
$siteserver = $SMSProvider
$ADSuffix = "lab.local"
$siteserverFQDN = $SMSProvider + "." + $ADSuffix
Write-host "SMSProvider is $SMSProvider."
Write-host "SiteCode is $SiteCode."
Write-host "siteserver is $siteserver"
Write-host "siteserverFQDN is $siteserverFQDN"
$DistributionGroup = "DPG-All DPs"

#Add admin account to local administrators group and grant ConfigMgr rights
#net localgroup administrators /add LAB\sccmadmin
#New-CMAdministrativeUser -Name "LAB\sccmadmin" -RoleName "Full Administrator"

#Add Boundary and Boundary Groups (content and site assignment)
New-CMBoundary -DisplayName "192.168.1.0/24 - Lab" -BoundaryType IPSubnet -Value "192.168.1.0"
New-CMBoundaryGroup -name "Lab"
New-CMBoundaryGroup -DefaultSiteCode $sitecode -name "Lab-SiteAssignment"
Add-CMBoundaryToGroup -BoundaryGroupName "Lab" -BoundaryName "192.168.1.0/24 - Lab"
Add-CMBoundaryToGroup -BoundaryGroupName "Lab-SiteAssignment" -BoundaryName "192.168.1.0/24 - Lab"

#Add Distribution Point to Boundary Group
Set-CMDistributionPoint -SiteCode $sitecode -SiteSystemServerName $siteserverFQDN -AddBoundaryGroupName "Lab"

#Add Distribution Point Group
New-CMDistributionPointGroup -Name $DistributionGroup
Add-CMDistributionPointToGroup -DistributionPointGroupName $DistributionGroup -DistributionPointName $siteserverFQDN

#Grab Distribution Point Group via WMI for later use
$DPGroup = Get-WmiObject -Namespace "Root\SMS\Site_$($sitecode)" -Class SMS_DistributionPointGroup -ComputerName $siteserverFQDN -Filter "Name='$DistributionGroup'"

# Add all Boot Images to Distribution Point Group
Get-CMBootImage | ForEach-Object {
Write-Host "Adding boot image " $_.Name "("$_.PackageID") to Distribution Point Group " $DPGroup.Name
$DPGroup.AddPackages($_.PackageID) | format-table ReturnValue -AutoSize
}

#Configure Discovery Methods (OU locations for Group discovery must be added in console)
$FullSchedule = New-CMSchedule -RecurInterval Days -Start "2014/01/01 12:00:00" -End "2016/12/31 00:00:00" -RecurCount 1
Set-CMDiscoveryMethod -ActiveDirectorySystemDiscovery -ActiveDirectoryContainer "LDAP://DC=LAB,DC=local" -SiteCode $sitecode -Enabled $True -PollingSchedule $FullSchedule
Set-CMDiscoveryMethod -ActiveDirectoryUserDiscovery -ActiveDirectoryContainer "LDAP://DC=LAB,DC=localset" -SiteCode $sitecode -Enabled $True -PollingSchedule $FullSchedule
Set-CMDiscoveryMethod -ActiveDirectoryGroupDiscovery -SiteCode $sitecode -Enabled $True -PollingSchedule $FullSchedule

#Configure Network Access Account
$NAAccount = "Lab\CM_NAA"
$NAAsecure = Read-Host "Enter desired password for Network Access Account" -AsSecureString
New-CMAccount -Name $NAAccount -Password $NAAsecure -SiteCode $sitecode

#Set Network Access Account (Site Configuration\Sites\Configure Site Components\Software Distribution)
#Note ConfigMgr 2012 R2 CU1 or higher required due to changes in how NAA is stored
Set-CMSoftwareDistributionComponent -NetworkAccessAccountNames $NAAccount -SiteCode $sitecode

#Configure Client Push Account
$CPAccount = "Lab\CM_CP"
$CPsecure = Read-Host "Enter desired password for Client Push Account" -AsSecureString
New-CMAccount -Name $CPAccount -Password $CPsecure -SiteCode $sitecode

#Set Client Push Account (Site Configuration\Sites\Client Installation Settings)
Set-CMClientPushInstallation -SiteCode $sitecode -ChosenAccount $CPAccount

#Enable PXE on Distribution Point and set to respond to internal adapter only
$PXEsecure = Read-Host "Enter desired PXE boot password" -AsSecureString
$CMDistributionPoint = Get-CMDistributionPoint -SiteSystemServerName $siteserverFQDN
$adapter = Get-WmiObject win32_networkadapterconfiguration -Filter 'DHCPEnabled = "False"' | where {$_.IPAddress}
$MAC = Get-WmiObject win32_networkadapter -Filter "index = $($adapter.Index)" | select MACAddress
Set-CMDistributionPoint -InputObject $CMDistributionPoint -EnablePxeSupport $True -AllowRespondIncomingPxeRequest $True -ComputersUsePxePassword $PXEsecure -EnableUnknownComputerSupport $True -MacAddressForRespondingPxeRequest $MAC.MACAddress
#Enable command prompt support in x86 boot image and distribute
$CMBootImg86 = Get-CMBootImage -Name "Boot image (x86)"
$CMBootImg86.EnableLabShell = $True
$CMBootImg86.Put()
Update-CMDistributionPoint -BootImage $CMBootImg86
Start-CMContentDistribution -BootImage $CMBootImg86 -DistributionPointGroupName $DistributionGroup
#Enable command prompt support in x64 boot image and distribute
$CMBootImg64 = Get-CMBootImage -Name "Boot image (x64)"
$CMBootImg64.EnableLabShell = $True
$CMBootImg64.Put()
Update-CMDistributionPoint -BootImage $CMBootImg64
Start-CMContentDistribution -BootImage $CMBootImg64 -DistributionPointGroupName $DistributionGroup

#Install/configure WSUS (Use PSSession to launch x64 P$)
$s = New-PSSession -ComputerName $SMSProvider
Invoke-command -Session $s -ScriptBlock {Install-WindowsFeature -Name UpdateServices-Services, UpdateServices-DB -IncludeManagementTools}
Remove-PSSession $s

& "c:\program files\Update Services\Tools\wsusutil.exe" postinstall SQL_INSTANCE_NAME=localhost CONTENT_DIR=E:\WSUS
}

#######################################################################################

#######################################################################################
function CM-ResetPolicy {
Invoke-WmiMethod -ComputerName test01 -Namespace root\ccm -Class sms_client -Name ResetPolicy -ArgumentList 1
}


Import-Module-CM

#Set-CMBaseConfig

