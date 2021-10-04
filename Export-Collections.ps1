
#$AllDeviceCollections = Get-CMDeviceCollection -Name "M_GrG_APP_ACA_Isie_6.2.0_SEVEN"
$AllDeviceCollections = Get-CMDeviceCollection 
$CSVFile = "E:\temp\Export-Collections_v&.csv"

$hashQuery = @{
    CollectionID       = $Collection.CollectionID
    CollectionName     = $Collection.Name
    CollectionRuleID   = $CollectionRule.QueryID
    CollectionRuleName = $CollectionRule.RuleName
    CollectionRule     = $CollectionRule.QueryExpression
    }
$Output = @()

foreach ($Collection in $AllDeviceCollections) {
    foreach ($CollectionRule in $Collection.CollectionRules) {
        write-host "importing $($CollectionRule.RuleName)" -ForegroundColor Green
        $ObjQuery = New-Object PSObject # -ArgumentList $hashQuery
        $ObjQuery | Add-Member -Name CollectionID -MemberType NoteProperty -Value $Collection.CollectionID
        $ObjQuery | Add-Member -Name CollectionName -MemberType NoteProperty -Value $Collection.Name
        $ObjQuery | Add-Member -Name CollectionType -MemberType NoteProperty -Value $Collection.CollectionType
        $ObjQuery | Add-Member -Name CollectionRefreshType -MemberType NoteProperty -Value $Collection.RefreshType
        $ObjQuery | Add-Member -Name CollectionCurrentStatus -MemberType NoteProperty -Value $Collection.CurrentStatus
        $ObjQuery | Add-Member -Name CollectionLastRefreshTime -MemberType NoteProperty -Value $Collection.LastRefreshTime
        $ObjQuery | Add-Member -Name CollectionLastMemberChangeTime -MemberType NoteProperty -Value $Collection.LastMemberChangeTime
        $ObjQuery | Add-Member -Name CollectionLocalMemberCount -MemberType NoteProperty -Value $Collection.LocalMemberCount
        $ObjQuery | Add-Member -Name CollectionMemberCount -MemberType NoteProperty -Value $Collection.MemberCount
        $ObjQuery | Add-Member -Name LimitToColID -MemberType NoteProperty -Value $Collection.LimitToCollectionID
        $ObjQuery | Add-Member -Name LimitToColName -MemberType NoteProperty -Value $Collection.LimitToCollectionName
        $ObjQuery | Add-Member -Name CollectionSchedType -MemberType NoteProperty -Value $Collection.RefreshSchedule[0].SmsProviderObjectPath
        $ObjQuery | Add-Member -Name CollectionSchedDaySpan -MemberType NoteProperty -Value $Collection.RefreshSchedule[0].DaySpan
        $ObjQuery | Add-Member -Name CollectionSchedHourSpan -MemberType NoteProperty -Value $Collection.RefreshSchedule[0].HourSpan
        $ObjQuery | Add-Member -Name CollectionSchedMinuteSpan -MemberType NoteProperty -Value $Collection.RefreshSchedule[0].MinuteSpan
        $ObjQuery | Add-Member -Name CollectionSchedStartTime -MemberType NoteProperty -Value $Collection.RefreshSchedule[0].StartTime
        $ObjQuery | Add-Member -Name CollectionRuleType -MemberType NoteProperty -Value $CollectionRule.SmsProviderObjectPath
        $ObjQuery | Add-Member -Name CollectionRuleID -MemberType NoteProperty -Value $CollectionRule.QueryID
        $ObjQuery | Add-Member -Name CollectionRuleName -MemberType NoteProperty -Value $CollectionRule.RuleName
        $ObjQuery | Add-Member -Name CollectionRuleExpression -MemberType NoteProperty -Value $CollectionRule.QueryExpression

        $Output += $ObjQuery
       }
    }

if (Test-Path $CSVFile) {mi $CSVFile -Destination "$CSVFile.old" -Force}
$Output | export-csv -Path $CSVFile -NoClobber -Delimiter ";" -NoTypeInformation -Force -Encoding ASCII

$Output