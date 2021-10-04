


#Requires -version 2

<#
.SYNOPSIS
               The script is auditing AD user objects and generates an Excel report based on the collected data
    
    10/16/2013: try catch added for each user account / more notification
               
.NOTES
               File Name           : Audit-ADUsers.ps1
                              
.EXAMPLE
               .\Audit-ADUsers.ps1 -Path C:\Temp -Domain "corpnet.net"
               
.EXAMPLE
               .\Audit-ADUsers.ps1 -Path C:\Temp -Forest "corpnet.net"

.EXAMPLE
               .\Audit-ADUsers.ps1 -Path C:\Temp -ExistingData C:\Temp\CORPNET-UserAccounts.csv

.EXAMPLE
               .\Audit-ADUsers.ps1 -Path C:\Temp -Domain "corpnet.net" -CollectOnly
               
.EXAMPLE
               .\Audit-ADUsers.ps1 -Path C:\Temp -Domain "corpnet.net" -InactiveDays 360

.EXAMPLE
               .\Audit-ADUsers.ps1 -Path C:\Temp -Domain "corpnet.net" -PasswordAge 90
               
.PARAMETER Domain
               Collect data from the specified domain. Cannot be used with Forest and ExistingData parameters.

.PARAMETER Forest
               Collect data from the specified forest and the child domains. Create a specific Excel worksheet for the forest.
               Cannot be used with Domain and ExistingData parameters.
               
.PARAMETER ExistingData
               Reuse a CSV file generated previously by the script. Only one domain can be treated.
               Cannot be used with Domain and Forest parameters.
               
.PARAMETER Path
               Path for the exported files
               
.PARAMETER CollectOnly
               Collect data but don't generate the Excel report. Cannot be used with ExistingData parameter.
               
.PARAMETER InactiveDays
               The number of inactive days for a user account to define it as inactive (default 180). 
               
.PARAMETER PasswordAge
               The number of days to define a password as old (default 120). 
#>

param
(              
               [Parameter(ParameterSetName="Domain",Mandatory=$true)]
               [String] $Domain,
               
               [Parameter(ParameterSetName="Forest",Mandatory=$true)]
               [String[]] $Forest,
               
               [Parameter(ParameterSetName="Data",Mandatory=$true)]
               [ValidateScript({Test-Path $_})]
               [String] $ExistingData,
               
               [Parameter(Mandatory=$true)]
               [ValidateScript({Test-Path $_ -PathType Container})]
               [String] $Path,
               
               [parameter(ParameterSetName="Domain")]
    [parameter(ParameterSetName="Forest")]
               [Switch] $CollectOnly,
               
               [parameter(ParameterSetName="Domain")]
    [parameter(ParameterSetName="Forest")]
               [int] $InactiveDays = 180,
               
               [parameter(ParameterSetName="Domain")]
    [parameter(ParameterSetName="Forest")]
               [int] $PasswordAge = 120
)

#Region Functions
####################################################
# Functions
####################################################

#---------------------------------------------------
# Return the NETBIOS name of a AD Domain
#---------------------------------------------------
Function Get-NETBiosName ( $dn, $ConfigurationNC )
{
               try
               {
                              $Searcher = New-Object System.DirectoryServices.DirectorySearcher 
                              $Searcher.SearchScope = "subtree" 
                              $Searcher.PropertiesToLoad.Add("nETBIOSName")| Out-Null
                              $Searcher.SearchRoot = "LDAP://cn=Partitions,$ConfigurationNC"
                              $Searcher.Filter = "(nCName=$dn)"
                              $NetBIOSName = ($Searcher.FindOne()).Properties.Item("nETBIOSName")
                              Return $NetBIOSName
               }
               catch
               {
                              Return $null
               }
}

#---------------------------------------------------
# Compare userAccountControl attribute with specific
# flags from $script:HtUACValues variable
#---------------------------------------------------
function Check-UserAccountControl ($Obj)
{
               foreach ( $Key in $script:HtUACValues.Keys )
               {
                              if ( $Obj.useraccountcontrol -band $script:HtUACValues[$Key])
                              {
                                            if ( $Obj.isActive )
                                            {
                                                           $script:HtUsersCount['isActive'][$Key]++
                                            }
                                            else
                                            {
                                                           $script:HtUsersCount['isInactive'][$Key]++
                                            }
                                            
                                            $Obj.$Key = $true
                                            $Standard = $false
                              }
               }
               
               if ( $Standard )
               {
                              if ( $Obj.isActive )
                              {
                                            $script:HtUsersCount['isActive']['isStandard']++
                              }
                              else
                              {
                                            $script:HtUsersCount['isInactive']['isStandard']++
                              }
               }
               
               Return $Obj
}

#---------------------------------------------------
# Create a specific title style in Excel
#---------------------------------------------------
function Add-MyTitleStyle
{
               # Check if style is not already existing
               $Style = $WorkBook.Styles | Where-Object { $_.Name -eq "TitleAuditAD" }
               
               if ( !$Style )
               {
                              $Style = $WorkBook.Styles.Add("TitleAuditAD")
                              $Style.IncludeAlignment = $false
                              $Style.IncludeNumber = $false
                              $Style.IncludePatterns = $false
                              $Style.IncludeProtection = $false
                              
                              # Define font style
                              $Style.Font.Bold = $true
                              $Style.Font.Color = 6968388
                              $Style.Font.ColorIndex = 50
                              $Style.Font.Size = 11
                              $Style.Font.ThemeColor = 4
                              
                              # Define borders style
                              $Style.Borders.item(4).Color = 15123099
                              $Style.Borders.item(4).ColorIndex = 37
                              $Style.Borders.item(4).ThemeColor = 5
                              $Style.Borders.item(4).LineStyle = 1
                              $Style.Borders.item(4).Weight = -4138
                              $Style.Borders.item(4).TintAndShade = +0.4
                              
                              $Style.IncludeBorder = $true
               }
}

#---------------------------------------------------
# Create a specific Excel worksheet for each domain
#---------------------------------------------------
function Create-MyWorkSheet ($WorkBook,$Name,$Array)
{
               # Create the worksheet
               $WorkSheet = $WorkBook.WorkSheets.Add()
               $WorkSheet.Name = $Name
               
               # hide the grid lines
               $WorkSheet.Select()
               $script:Excel.ActiveWindow.Displaygridlines = $false
               
               # Data to import in the first table of the worksheet
               $UsersVolumetry = @{ 
                                                                                         Actives = @($script:HtUsersCount['isActive']['Count']); 
                                                                                         Inactives = @($script:HtUsersCount['isInActive']['Count'])
                                                                          }
               
               $TableTitle = "Volumetry of user accounts"
               
               # Call the function Create-MyTable to create the first table
               Create-MyTable $WorkSheet $TableTitle @(2,1) $UsersVolumetry $null $true $false
               
               # Define the data range for the first chart
               $DataRange = $WorkSheet.Range($WorkSheet.Cells.Item(3,1),$WorkSheet.Cells.Item(4,2))
               $ChartRange = $WorkSheet.Range($WorkSheet.Cells.Item(7,1),$WorkSheet.Cells.Item(20,2))
               
               # Call the function Create-MyChart to create the first chart
               Create-MyChart $WorkSheet $DataRange $ChartRange $xlChart::xlPie $null
               
               # Data to import in the second table of the worksheet
               $StdStatusOfActiveUsers = ($Array | Where-Object { $_.isActive -eq $true -and $_.isLocked -eq $false -and $_.isPwdExpired -eq $false -and $_.isExpired -eq $false -and $_.isDisabled -eq $false}).Count
               $StdStatusOfInactiveUsers = ($Array | Where-Object { $_.isActive -eq $false -and $_.isLocked -eq $false -and $_.isPwdExpired -eq $false -and $_.isExpired -eq $false -and $_.isDisabled -eq $false}).Count
               
               $UsersStatus = @{ 
                                            Locked = @($script:HtUsersCount['isActive']['isLocked'],$script:HtUsersCount['isInActive']['isLocked']);
                                            "Password Expired" = @($script:HtUsersCount['isActive']['isPwdExpired'],$script:HtUsersCount['isInActive']['isPwdExpired']);
                                            Expired = @($script:HtUsersCount['isActive']['isExpired'],$script:HtUsersCount['isInActive']['isExpired']);
                                            Disabled = @($script:HtUsersCount['isActive']['isDisabled'],$script:HtUsersCount['isInActive']['isDisabled']);
                                            Standard = @($StdStatusOfActiveUsers,$StdStatusOfInactiveUsers)
                              }
                              
               
               $TableTitle = "Status of user accounts"
               
               # Call the function Create-MyTable to create the second table
               Create-MyTable $WorkSheet $TableTitle @(3,4) $UsersStatus @('Status','Active Accounts','Inactive Accounts') $false $true

               # Define the data range for the second chart
               $ChartTitle = "Status of active user accounts"
               $DataRange = $WorkSheet.Range($WorkSheet.Cells.Item(3,4),$WorkSheet.Cells.Item(8,5))
               $ChartRange = $WorkSheet.Range($WorkSheet.Cells.Item(10,4),$WorkSheet.Cells.Item(26,6))
               
               # Call the function Create-MyChart to create the second chart
               Create-MyChart $WorkSheet $DataRange $ChartRange $xlChart::xlBarClustered $ChartTitle

               # Data to import in the third table of the worksheet
               $StdConfigOfActiveUsers = ($Array | Where-Object { $_.isActive -eq $true -and $_.isDESKeyOnly -eq $false -and $_.isPwdOld -eq $false -and $_.isPwdEncryptedTextAllowed -eq $false -and $_.isPreAuthNotRequired -eq $false -and $_.isPwdNotRequired -eq $false -and $_.isPwdNeverExpires -eq $false }).Count
               $StdConfigOfInactiveUsers = ($Array | Where-Object { $_.isActive -eq $false -and $_.isDESKeyOnly -eq $false -and $_.isPwdOld -eq $false -and $_.isPwdEncryptedTextAllowed -eq $false -and $_.isPreAuthNotRequired -eq $false -and $_.isPwdNotRequired -eq $false -and $_.isPwdNeverExpires -eq $false }).Count
               
               $UsersConfig = @{ 
                                            "Encrypted test password allowed" = @($script:HtUsersCount['isActive']['isPwdEncryptedTextAllowed'],$script:HtUsersCount['isInActive']['isPwdEncryptedTextAllowed']);
                                            "Password older than $PasswordAge days" = @($script:HtUsersCount['isActive']['isPwdOld'],$script:HtUsersCount['isInActive']['isPwdOld']);
                                            "Using DES key only" = @($script:HtUsersCount['isActive']['isDESKeyOnly'],$script:HtUsersCount['isInActive']['isDESKeyOnly']);
                                            "Pre-authentication not required" = @($script:HtUsersCount['isActive']['isPreAuthNotRequired'],$script:HtUsersCount['isInActive']['isPreAuthNotRequired']);
                                            "Password not required" = @($script:HtUsersCount['isActive']['isPwdNotRequired'],$script:HtUsersCount['isInActive']['isPwdNotRequired']);
                                            "Password never expires" = @($script:HtUsersCount['isActive']['isPwdNeverExpires'],$script:HtUsersCount['isInActive']['isPwdNeverExpires']);
                                            "Standard" = @($StdConfigOfActiveUsers,$StdConfigOfInactiveUsers)
                              }
               
               $TableTitle = "Configuration of user accounts"
               
               # Call the function Create-MyTable to create the third table
               Create-MyTable $WorkSheet $TableTitle @(3,8) $UsersConfig @('Options','Active Accounts','Inactive Accounts') $false $true

               $ChartTitle = "Configuration of active user accounts"
               
               # Define the data range for the third chart
               $DataRange = $WorkSheet.Range($WorkSheet.Cells.Item(3,8),$WorkSheet.Cells.Item(10,9))
               $ChartRange = $WorkSheet.Range($WorkSheet.Cells.Item(12,8),$WorkSheet.Cells.Item(28,10))
               
               # Call the function Create-MyChart to create the third chart
               Create-MyChart $WorkSheet $DataRange $ChartRange $xlChart::xlColumnClustered $ChartTitle
}

#---------------------------------------------------
# Create a table in Excel
#---------------------------------------------------
function Create-MyTable ($WorkSheet,$Title,$Position,$Data,$Header,$ShowTotals,$ShowHeaders)
{
               $Cells = $WorkSheet.Cells
               
               # Specify the initial position of the table
               $InitialRow = $Position[0]
               $CurrentRow = $InitialRow
               $InitialCol = $Position[1]
               $CurrentCol = $InitialCol
                              
               # Add table header if parameter header is provided
               if ($Header)
               {
                              $Header | %{
                                            $Cells.item($CurrentRow,$CurrentCol) = $_
                                            $Cells.item($CurrentRow,$CurrentCol).font.bold = $True
                                            $CurrentCol++
                              }             
               }

               # Add table content
               foreach ($Key in $Data.Keys)
               {
                   $CurrentRow++
                   $CurrentCol = $InitialCol
                   $cells.item($CurrentRow,$CurrentCol) = $Key
                              
                              $nbItems = $Data[$Key].Count
                              for ( $i=0; $i -lt $nbItems; $i++ )
                              {
                                            $CurrentCol++
                              $cells.item($CurrentRow,$CurrentCol) = $Data[$Key][$i]
                              $cells.item($CurrentRow,$CurrentCol).NumberFormat ="0"
                              }                            
               }
               
               # Define the data range
               $Range = $WorkSheet.Range($WorkSheet.Cells.Item($InitialRow,$InitialCol),$WorkSheet.Cells.Item($CurrentRow,$CurrentCol))
               
               # Define the table style
               $ListObject = $WorkSheet.ListObjects.Add([Microsoft.Office.Interop.Excel.XlListObjectSourceType]::xlSrcRange,$Range,$null,[Microsoft.Office.Interop.Excel.XlYesNoGuess]::xlYes,$null)
               $ListObject.TableStyle = "TableStyleLight6"
               $ListObject.ShowTotals = $ShowTotals
               $ListObject.ShowHeaders = $ShowHeaders
               
               # Sort data based on the 2nd column
               $SortRange = $WorkSheet.Range($WorkSheet.Cells.Item($InitialRow+1,$InitialCol+1).Address($False,$False)) # address: Convert cells position 1,1 -> A:1
               $WorkSheet.Sort.SortFields.Clear()
               [void]$WorkSheet.Sort.SortFields.Add($SortRange,0,1,0)
               $WorkSheet.Sort.SetRange($Range)
               $WorkSheet.Sort.Header = 1 # exclude header
               $WorkSheet.Sort.Orientation = 1
               $WorkSheet.Sort.Apply()
               
               # Create the title and apply a style
               $cells.item(1,$InitialCol) = $Title
               $RangeTitle = $WorkSheet.Range($WorkSheet.Cells.Item(1,$InitialCol),$WorkSheet.Cells.Item(1,$CurrentCol))
               $RangeTitle.MergeCells = $true
               $RangeTitle.Style = "TitleAuditAD"
               
               # http://msdn.microsoft.com/en-us/library/microsoft.office.interop.excel.constants.aspx
               $RangeTitle.HorizontalAlignment = -4108
               $RangeTitle.ColumnWidth = 20
}

#---------------------------------------------------
# Create a chart in Excel
#---------------------------------------------------
function Create-MyChart ($WorkSheet,$DataRange,$ChartRange,$ChartType,$Title)
{
               # Add the chart
               $Chart = $WorkSheet.Shapes.AddChart().Chart
               $Chart.ChartType = $ChartType
               
               # Apply a specific style for each type
               if ( $ChartType -like "xlPie" )
               {             
                              $Chart.ApplyLayout(6,$Chart.ChartType)

                              # http://msdn.microsoft.com/fr-fr/library/microsoft.office.interop.excel._chart.setsourcedata(v=office.11).aspx
                              $Chart.SetSourceData($DataRange)
               }
               else
               {             
                              $Chart.SetSourceData($DataRange,[Microsoft.Office.Interop.Excel.XLRowCol]::xlRows)
                              
                              # http://msdn.microsoft.com/en-us/library/office/bb241345(v=office.12).aspx
                              $Chart.Legend.Position = -4107
                              
                              $NbSeries = $Chart.SeriesCollection().Count
                              
                              # Define data labels
                              for ( $i=1 ; $i -le $NbSeries; ++$i )
                              {
                                            $Chart.SeriesCollection($i).HasDataLabels = $true
                                            $Chart.SeriesCollection($i).DataLabels(0).Position = 3
                              }
                              
                              $Chart.HasAxis([Microsoft.Office.Interop.Excel.XlAxisType]::xlCategory) = $false
                              $Chart.HasAxis([Microsoft.Office.Interop.Excel.XlAxisType]::xlValue) = $false
               }

               if ( $Title )
               {
                              $Chart.HasTitle = $true
                              $Chart.ChartTitle.Text = $Title
               }

               # Define the position of the chart
               $ChartObj = $Chart.Parent

               $ChartObj.Height = $ChartRange.Height
               $ChartObj.Width = $ChartRange.Width
               
               $ChartObj.Top = $ChartRange.Top
               $ChartObj.Left = $ChartRange.Left
}

#---------------------------------------------------
# Merge each domain hastable with the global hastable
#---------------------------------------------------
function Merge-Hastable ($source,$destination)
{
               foreach ( $Key in $source.Keys)
               {
                              foreach ( $subKey in $source[$Key].Keys )
                              {
                                            $destination[$Key][$subKey] += $source[$Key][$subKey]
                              }
               }
               
               Return $destination
}

#EndRegion

#Region Variables
####################################################
# Variables
####################################################

# Hashtable containing the list of userAccountControl attribute flags
$script:HtUACValues = @{
                                            isDisabled = 2;
                                            isPwdNotRequired = 32;
                                            isPwdEncryptedTextAllowed = 128;
                                            isPwdNeverExpires = 65536;
                                            isDESKeyOnly = 2097152;
                                            isPreAuthNotRequired = 4194304;
                              }

# Hastable to store the differents results
$script:HtUsersCount = @{
                                            isActive = @{
                                                                          Count = 0;
                                                                          isDESKeyOnly = 0;
                                                                          isDisabled = 0;
                                                                          isLocked = 0;
                                                                          isPreAuthNotRequired = 0;
                                                                          isPwdEncryptedTextAllowed = 0;
                                                                          isPwdNeverExpires = 0;
                                                                          isPwdNotRequired = 0;
                                                                          isPwdExpired = 0;
                                                                          isStandard = 0;
                                                           }
                                            isInactive = @{
                                                                          Count = 0;
                                                                          isDESKeyOnly = 0;
                                                                          isDisabled = 0;
                                                                          isLocked = 0;
                                                                          isPreAuthNotRequired = 0;
                                                                          isPwdEncryptedTextAllowed = 0;
                                                                          isPwdNeverExpires = 0;
                                                                          isPwdNotRequired = 0;
                                                                          isPwdExpired = 0;
                                                                          isStandard = 0;
                                                           }
                              }

$ArrObj = @()
$PDCEmulators = @()
$CurrentDateTFT = (Get-Date).ToFileTimeUTC()
$InactiveDate = (Get-Date).AddDays(-$InactiveDays).ToFileTimeUtc()
$PwdLastSetDate = (Get-Date).AddDays(-$PasswordAge).ToFileTimeUtc()
#$script:Excel = New-Object -ComObject "Excel.Application"
#[System.Threading.Thread]::CurrentThread.CurrentCulture = [System.Globalization.CultureInfo] "en-US"
#$xlChart=[Microsoft.Office.Interop.Excel.XLChartType]

# Create the Directory searcher to collect user objects
$ADSearcher = New-Object System.DirectoryServices.DirectorySearcher
$ADSearcher.PageSize = 1000
$ADSearcher.Filter = "(&(objectCategory=person)(objectClass=user))"
$UserProperties = @("accountexpires","samaccountname","displayname","distinguishedname","lastlogontimestamp","lockouttime","msds-psoapplied","pwdlastset","scriptpath","sidhistory","samaccounttype","useraccountcontrol","useprincipalname")
$ADSearcher.PropertiesToLoad.AddRange(@($UserProperties))

#EndRegion


#Region Main
####################################################
# Main
####################################################
try
{
               # Connect to the specified forest and create the list of child domains if forest parameter used
               if ($Forest)
               {
                              Write-Host "Enumerating domains in the forest: " -NoNewline
                              Write-Host $Forest -ForegroundColor Magenta
                              
                              $ForestContext = new-object System.directoryServices.ActiveDirectory.DirectoryContext("Forest",$Forest)
                              $ObjForest = [System.DirectoryServices.ActiveDirectory.Forest]::GetForest($ForestContext)
                              
                              foreach ($ObjDomain in $ObjForest.Domains)
                              {
                                            Write-Host "`t$($ObjDomain.Name): " -NoNewline
                                            
                                            if ( -not([string]::IsNullOrEmpty($ObjDomain.PDCRoleOwner)) )
                                            {
                                                           Write-Host "data will be collected from $($ObjDomain.PDCRoleOwner)"
                                                           $PDCEmulators += $ObjDomain.PDCRoleOwner
                                            }
                                            else
                                            {
                                                           Write-host "unable to contact the PDC Emulator $($ObjDomain.PDCRoleOwner)" -ForegroundColor Red
                                            }
                              }
                              
               }
               # Connect to the specified domain if domain parameter used
               elseif ($Domain)
               {
                              $DomainContext = new-object System.directoryServices.ActiveDirectory.DirectoryContext("Domain",$Domain)
                              $ObjDomain = [System.DirectoryServices.ActiveDirectory.Domain]::GetDomain($DomainContext)
                              $PDCEmulators += $ObjDomain.PDCRoleOwner
               }
               # Use the file specified with ExistingData
               else
               {
                              $ArrObj = Import-Csv -Path $ExistingData -Delimiter ";"
               }
               
               # Construct the hashtable based on the file specified with ExistingData
               if ( $PsCmdlet.ParameterSetName -match "Data" )
               {
                              
                              $Properties = @('isActive','isDESKeyOnly','isDisabled','isLocked','isPreAuthNotRequired','isPwdEncryptedTextAllowed','isPwdNeverExpires','isPwdExpired')
                              
                              $Counter = 0
                              
                              foreach ( $Obj in $ArrObj )
                              {
                                            Write-Progress -activity "Loading data..." -status "Treatment of $Counter/$($ArrObj.Count)" -PercentComplete (($Counter / $ArrObj.Count) * 100)
                                            
                                            if ($Obj.isActive -eq $true)
                                            {
                                                           $script:HtUsersCount['isActive']['Count']++
                                                           
                                                           foreach ( $Property in $Properties )
                                                           {
                                                                          if ( $Obj.$Property -eq $true )
                                                                          {
                                                                                         $script:HtUsersCount['isActive'][$Property]++
                                                                          }
                                                           }
                                            }
                                            else
                                            {
                                                           $script:HtUsersCount['isInactive']['Count']++
                                                           
                                                           foreach ( $Property in $Properties )
                                                           {
                                                                          if ( $Obj.$Property -eq $true )
                                                                          {
                                                                                         $script:HtUsersCount['isInactive'][$Property]++
                                                                          }
                                                           }
                                            }
                                            
                                            $Counter++
                              }
                              
                              Write-Progress -activity "Loading data..." -Completed -Status "Completed"
                              
                              Write-Host "Creating the Excel spreadsheet..."
                              
                              if ( !$WorkBook )
                              {
                                            $script:Excel = New-Object -ComObject "Excel.Application"
                                            [System.Threading.Thread]::CurrentThread.CurrentCulture = [System.Globalization.CultureInfo] "en-US"
                                            $xlChart=[Microsoft.Office.Interop.Excel.XLChartType]
                                            
                                            # Create the workbook
                                             $WorkBook = $script:Excel.Workbooks.Add()
                                            Add-MyTitleStyle
                              }
                              
                              Create-MyWorkSheet $WorkBook "Users" $ArrObj
                              $script:Excel.Visible = $True
               }
               # Connect to each PDC Emulator to collect data
               elseif ( $PDCEmulators.Count -ge 1 )
               {
                              $objRootDSE = [System.DirectoryServices.DirectoryEntry] "LDAP://rootDSE"
                              
                              foreach ( $PDCEmulator in $PDCEmulators )
                              {
                                            if ( [ADSI]::Exists("LDAP://$($PDCEmulator)") )
                                            {
                                                           
                                                           # Connect to the PDC Emulator
                                                           $ObjDeDomain = [ADSI] "LDAP://$($PDCEmulator)"
                                                           $ADSearcher.SearchRoot = $ObjDeDomain
                                                           
                                                           # Get the domain NETBIOS name
                                                           $DomainNameString = Get-NETBiosName $objDeDomain.distinguishedName $objRootDSE.configurationNamingContext
                                                           
                                                           # Collect user accounts
                                                           $Users = $ADSearcher.FindAll()
                                                           
                                                           for ( $i=0; $i -lt $Users.Count; $i++ )
                                                           {
                                                                          Write-Progress -activity "Loading data..." -status "$($DomainNameString): treatment of $i/$($Users.Count) Users" -PercentComplete (($i / $Users.Count) * 100)
                                                                          
                                                                          try
                                                                          {
                                                                                         $UserObj = New-Object PsObject -Property `
                                                                                                                                     @{
                                                                                                                                                    samaccountname = [string] $Users[$i].Properties['samaccountname'];
                                                                                                                                                    distinguishedname = [string] $Users[$i].Properties['distinguishedname'];
                                                                                                                                                    useprincipalname = [string] $Users[$i].Properties['useprincipalname'];
                                                                                                                                                    displayname = [string] $Users[$i].Properties['displayname'];
                                                                                                                                                    useraccountcontrol = $Users[$i].Properties['useraccountcontrol'].Item(0);
                                                                                                                                                    isActive = $true;                                                                           # defined by the attribute lastLogonTimestamp
                                                                                                                                                    isLocked = $false;                                                              # defined by the attribute lockoutTime
                                                                                                                                                    isDisabled = $false;                                               # defined by the attribute userAccountControl
                                                                                                                                                    isExpired = $false;                                               # defined by the attribute accountExpires
                                                                                                                                                    isPwdExpired = $false;                                               # defined by the attribute userAccountControl
                                                                                                                                                    isPwdNeverExpires = $false;                                      # defined by the attribute userAccountControl
                                                                                                                                                    isPwdNotRequired = $false;                                      # defined by the attribute userAccountControl
                                                                                                                                                    isPwdEncryptedTextAllowed = $false; # defined by the attribute userAccountControl
                                                                                                                                                    isDESKeyOnly = $false;                                               # defined by the attribute userAccountControl
                                                                                                                                                    isPreAuthNotRequired = $false;                 # defined by the attribute userAccountControl
                                                                                                                                                    isPwdOld = $false                                                               # defined by the attribute pwdLastSet
                                                                                                                                     }
                                                                                         
                                                                                         # Identify active accounts
                                                                                         if ( ([string]::IsNullOrEmpty($Users[$i].Properties['lastlogontimestamp'])) -or ($Users[$i].Properties['lastlogontimestamp'] -lt $InactiveDate) )
                                                                                         {
                                                                                                       $UserObj.isActive = $false
                                                                                                        $script:HtUsersCount['isInactive']['Count']++       
                                                                                         }
                                                                                         else
                                                                                         {
                                                                                                        $script:HtUsersCount['isActive']['Count']++
                                                                                                       
                                                                                         }
                                                                                         
                                                                                         # Use Directory Entry to retrieve msds-user-account-control-computed attribute
                                                                                         $DeUser = $Users[$i].GetDirectoryEntry()
                                                                                         $DeUser.RefreshCache("msds-user-account-control-computed")

                                                                                         # Return the value of msds-user-account-control-computed
                                                                                         $UserAccountFlag = $DeUser.Properties["msds-user-account-control-computed"].Value
                                                                                         
                                                                                         # Identify if account is locked
                                                                                         if ( $UserAccountFlag -band 16 )
                                                                                         {
                                                                                                       $UserObj.isLocked = $true
                                                                                                       
                                                                                                       if ( $UserObj.isActive )
                                                                                                       {
                                                                                                                      $script:HtUsersCount['isActive']['isLocked']++
                                                                                                       }
                                                                                                       else
                                                                                                       {
                                                                                                                      $script:HtUsersCount['isInactive']['isLocked']++
                                                                                                       }
                                                                                         }
                                                                                         
                                                                                         # Identify is password is expired
                                                                                         if ( $UserAccountFlag -band 8388608 )
                                                                                         {
                                                                                                       $UserObj.isPwdExpired = $true
                                                                                                       
                                                                                                       if ( $UserObj.isActive )
                                                                                                       {
                                                                                                                      $script:HtUsersCount['isActive']['isPwdExpired']++
                                                                                                       }
                                                                                                       else
                                                                                                       {
                                                                                                                      $script:HtUsersCount['isInactive']['isPwdExpired']++
                                                                                                       }
                                                                                         }

                                                                                         # Identify expired accounts
                                                                                         if ( $Users[$i].Properties['accountexpires'].Item(0) -lt $CurrentDateTFT )
                                                                                         {
                                                                                                       $UserObj.isExpired = $true
                                                                                                       
                                                                                                       if ( $UserObj.isActive )
                                                                                                       {
                                                                                                                      $script:HtUsersCount['isActive']['isExpired']++
                                                                                                       }
                                                                                                       else
                                                                                                       {
                                                                                                                      $script:HtUsersCount['isInactive']['isExpired']++
                                                                                                       }
                                                                                         }
                                                                                         
                                                                                         # Identify pwdLastSet older than $PasswordAge days
                                                                                         if ( $Users[$i].Properties['pwdlastset'] -lt $PwdLastSetDate )
                                                                                         {
                                                                                                       $UserObj.isPwdOld = $true
                                                                                                       
                                                                                                       if ( $UserObj.isActive )
                                                                                                       {
                                                                                                                      $script:HtUsersCount['isActive']['isPwdOld']++
                                                                                                       }
                                                                                                       else
                                                                                                       {
                                                                                                                      $script:HtUsersCount['isInactive']['isPwdOld']++
                                                                                                       }
                                                                                         }
                                                                                         
                                                                                         # Check the configuration of user accounts based on the attribute userAccountControl
                                                                                         $UserObj = Check-UserAccountControl $UserObj
                                                                                         
                                                                                         $ArrObj += $UserObj
                                                                          }
                                                                          catch
                                                                          {
                                                                                         Write-Host "Error while treating the account $($Users[$i]): $($_.Exception.Message)"
                                                                          }
                                                           }
                                                           
                                                           Write-Progress -activity "Loading data..." -Completed -Status "Completed"
                                                           # Export data to csv file
                                                           $ArrObj | Export-Csv -Path "$($Path)\$($DomainNameString)-UserAccounts.csv" -Delimiter ";" -NoTypeInformation -Force
                                                           
                                                           Write-host "$($DomainNameString): Data exported to " -NoNewline
                                                           Write-host "$($Path)\$($DomainNameString)-UserAccounts.csv" -ForegroundColor Green
                                                           
                                                           # Construct the Excel report
                                                           if ($CollectOnly -eq $false)
                                                           {
                                                                          
                                                                          if ( !$WorkBook )
                                                                          {
                                                                                         $script:Excel = New-Object -ComObject "Excel.Application"
                                                                                         [System.Threading.Thread]::CurrentThread.CurrentCulture = [System.Globalization.CultureInfo] "en-US"
                                                                                         $xlChart=[Microsoft.Office.Interop.Excel.XLChartType]
                                                                                         
                                                                                         # Create the workbook
                                                                                         $WorkBook = $script:Excel.Workbooks.Add()
                                                                                         Add-MyTitleStyle
                                                                          }
                                                                          
                                                                          Write-Host "$($DomainNameString): Creating the Excel spreadsheet..."
                                                                          Create-MyWorkSheet $WorkBook "$($DomainNameString) - Users" $ArrObj
                                                           }
                                                           
                                                           # Merge data collected for the global report
                                                           if ( $Forest )
                                                           {
                                                                          if ( $htForestUsersCount )
                                                                          {
                                                                                         $htForestUsersCount = Merge-Hastable $script:HtUsersCount $htForestUsersCount
                                                                                         $ArrForestObj += $ArrObj
                                                                          }
                                                                          else
                                                                          {
                                                                                         $htForestUsersCount = $script:HtUsersCount
                                                                                         $ArrForestObj = $ArrObj
                                                                          }
                                                           }
                                                           
                                                           # Reset hashtable and array
                                                           $script:HtUsersCount = @{
                                                                                                       isActive = @{
                                                                                                                                     Count = 0;
                                                                                                                                     isDESKeyOnly = 0;
                                                                                                                                     isDisabled = 0;
                                                                                                                                     isLocked = 0;
                                                                                                                                     isPreAuthNotRequired = 0;
                                                                                                                                     isPwdEncryptedTextAllowed = 0;
                                                                                                                                     isPwdNeverExpires = 0;
                                                                                                                                     isPwdNotRequired = 0;
                                                                                                                                     isPwdExpired = 0;
                                                                                                                                     isStandard = 0;
                                                                                                                      }
                                                                                                       isInactive = @{
                                                                                                                                     Count = 0;
                                                                                                                                     isDESKeyOnly = 0;
                                                                                                                                     isDisabled = 0;
                                                                                                                                     isLocked = 0;
                                                                                                                                     isPreAuthNotRequired = 0;
                                                                                                                                     isPwdEncryptedTextAllowed = 0;
                                                                                                                                     isPwdNeverExpires = 0;
                                                                                                                                     isPwdNotRequired = 0;
                                                                                                                                     isPwdExpired = 0;
                                                                                                                                     isStandard = 0;
                                                                                                                      }
                                                                                         }
                                                           
                                                           $ArrObj = @()
                                            }
                                            else
                                            {
                                                           Write-Host "Unable to connect to the PDC Emulator $($objDomain.PDCRoleOwner)" -ForegroundColor Red
                                            }
                              }
                              
                              # Construct the global spreadsheet
                              if ( ($CollectOnly -eq $false) -and $Forest )
                              {
                                            Write-Host "Creating the Excel spreadsheet of the forest..."
                                            $script:HtUsersCount = $htForestUsersCount 
                                            Create-MyWorkSheet $WorkBook "Forest - Users" $ArrForestObj
                              }
                              
                              # Saving
                              $WorkBook.SaveAs("$Path\Report-UserAccounts.xlsx")
                              
                              Write-Host "Excel report created: " -NoNewline 
                              Write-Host  "$($Path)\Report-UserAccounts.xlsx" -ForegroundColor Green
                              
                              #make Excel visible 
                              $script:Excel.Visible = $True        
               }
               else
               {
                              Write-Host "Unable to collect data. The list of PDC Emulators is empty." -ForegroundColor Yellow
               }
}
Catch
{
               Write-Host "$($_.Exception.Message)" -ForegroundColor Red
}

#EndRegion
