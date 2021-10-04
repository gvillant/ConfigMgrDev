$collCollections = Get-WmiObject -Namespace "root\SMS\Site_FFF" -Class SMS_Collection | 
    where {$_.Name -like "Intel *" -And $_.CollectionID -like "FFF*" -And $_.LimitToCollectionName -like "All Systems*"}

foreach ($objItem in $collCollections) {
$objItem.LimitToCollectionName = "AMT Root Collection"
$objItem.LimitToCollectionID = "FFF00211"
$objItem.Put()
}
