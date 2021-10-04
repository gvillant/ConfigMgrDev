# credits to  http://thedesktopteam.com/blog/raphael/sccm-2012-removing-old-revision/
# Get revisions count for specified application

$RemoveRevision = $TRUE

$cmapps = $null
$cmApps = Get-CMApplication "EPDM-PRO-2016-EDRAWINGS"
foreach ($cmApp in $cmApps) {
	$cmAppRevision = $cmApp | Get-CMApplicationRevisionHistory
	
    #Displays revision current number and revision count. 
    "{0} - {1} - {2}" -f $cmApp.LocalizedDisplayName, $cmApp.SDMPackageVersion, $cmAppRevision.Count

    #Remove Revisions
    if ($RemoveRevision){
       for ($i = 0;$i -lt $cmAppRevision.Count-1;$i++) { 
            Try {
                Remove-CMApplicationRevisionHistory -Id $cmApp.CI_ID -revision $cmAppRevision[$i].CIVersion -force 
                write-Host "Removing $($cmApp.LocalizedDisplayName) Revision $($cmAppRevision[$i].CIVersion) ... "
                }
            Catch {
                Write-Host -ForegroundColor 'red' "$($cmApp.LocalizedDisplayName) : Erreur $($_.Exception.Message)"
                }
              }
        write-host -NoNewline -ForegroundColor Green "Done !"
        }
    }


