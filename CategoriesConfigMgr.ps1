
# https://social.technet.microsoft.com/Forums/en-US/09195204-09fb-46f1-bda9-6cb730050cb7/application-properties-in-wmi-on-the-client?forum=configmanagersdk

# Gets "Administrative categories" and "User categories"
#$ApplicationCategories = @(gwmi -Namespace root\sms\site_$SiteCode -ComputerName $SiteServer -Class SMS_CategoryInstance | ? {@("AppCategories","CatalogCategories") -icontains $_.CategoryTypeName})
#Write-Host "I found $($ApplicationCategories.Count) Application Categories"

# Gets "Administrative categories" only
$ApplicationCategories = @(gwmi -Namespace root\sms\site_$SiteCode -ComputerName $SiteServer -Class SMS_CategoryInstance | ? {@("AppCategories") -icontains $_.CategoryTypeName})
Write-Host "I found $($ApplicationCategories.Count) Application Categories"

# Gets application<->category relationships for the categories found above
# NOTE: This WMI Class is large so to reduce overhead it must be queried with a Filter and as little as possible
$CategoryRelationships = @($ApplicationCategories | % {gwmi -Namespace root\sms\site_$SiteCode -ComputerName $SiteServer -Class SMS_CategoryInstanceMembership -Filter "CategoryInstanceID = $($_.CategoryInstanceID)"})
Write-Host "I found $($CategoryRelationships.Count) Category Relationships"

# Get a list of applications from the server that have categories
$ServerApplicationsWithCategories =  @($CategoryRelationships | % {$_.ObjectKey} | % {gwmi -Namespace root\sms\site_$SiteCode -ComputerName $SiteServer -Class SMS_Application -Filter "CI_UniqueID = '$_'"} | Sort-Object ModelID -Unique)
Write-Host "I found $($ServerApplicationsWithCategories.Count) Server Applications With Categories"

# Show results
foreach ($Application in $ServerApplicationsWithCategories) {
    Write-Host "`t$($Application.LocalizedDisplayName)"
    foreach ($Relationship in @($CategoryRelationships | ? {$_.ObjectKey -eq $Application.CI_UniqueID})) {
        $CategoryName = $($Categories | ? {$Relationship.CategoryInstanceID -eq $_.CategoryInstanceID} | % {$_.LocalizedCategoryInstanceName})
        Write-Host "`t`t$CategoryName"
    }
}


$SMSProvider = $env:COMPUTERNAME

$Application = "TEST - Office 2016 - Deferred"
$APPQuery = Get-WmiObject -Namespace "Root\SMS\Site_$SiteCode" -Class SMS_ApplicationLatest -ComputerName $SMSProvider `
-Filter "LocalizedDisplayName='$Application'"

foreach ($CategoryInstance_UniqueID in $APPQuery.CategoryInstance_UniqueIDs) {
    $CategoryInstance_UniqueID
    $CATQuery = Get-WmiObject -Namespace "Root\SMS\Site_$SiteCode" -Class SMS_CategoryInstance -ComputerName $SMSProvider `
-Filter "CategoryInstance_UniqueID='$CategoryInstance_UniqueID'"
    $CATQuery.LocalizedCategoryInstanceName
    }



