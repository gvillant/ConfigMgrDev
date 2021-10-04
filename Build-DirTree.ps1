

#region variables
$MyTable = @(
    "c:\temp\test"
    "c:\temp\test2"
    "c:\temp\test2"
        )

#region function
function BuildDir () {

foreach ($obj in $MyTable) {
    write-host "$obj" -foregroundcolor green
        }
    }

#region Main
BuildDir

