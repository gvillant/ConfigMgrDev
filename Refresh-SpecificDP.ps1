Function Refresh-SpecificDP {
    param( 
        [Parameter(Position=1,Mandatory=$true)]$siteCode, 
        [Parameter(Position=2,Mandatory=$true)]$packageID,
        [Parameter(Position=3,Mandatory=$true)]$dpName

    )

    $dpFound = $false

    If ($packageID.Length -ne 8)
    {
        Throw "Invalid package"
    }

    $distPoints = Get-WmiObject -Namespace "root\SMS\Site_$($siteCode)" -Query "Select * From SMS_DistributionPoint WHERE PackageID='$packageID'"
    
    ForEach ($dp In $distPoints)
    {
        If ((($dp.ServerNALPath).ToUpper()).Contains($dpName.ToUpper()))
        {
            $dpFound = $true

            Try {
                $dp.RefreshNow = $true
                $dp.Put() | Out-Null
                $dpName + " - " + $packageID
                }

            Catch [Exception]
            {
                return $_.Exception.Message
            }
        }
    }
    If ($dpFound -eq $false)
    {
        Throw "No results returned."
    }
}

foreach ($package in gc C:\temp\aumelscm01.txt) {
    write-host $package
    Refresh-SpecificDP STG $package aumelscm01
    }
