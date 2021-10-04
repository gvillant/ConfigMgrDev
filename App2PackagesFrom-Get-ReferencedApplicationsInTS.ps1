
Import-Module "D:\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1"
CD SOC:

$TS = "SOC00153"


function Get-ExecuteWqlQuery($siteServerName, $query)
{
  $returnValue = $null
  $connectionManager = New-Object Microsoft.ConfigurationManagement.ManagementProvider.WqlQueryEngine.WqlConnectionManager
  
  if($connectionManager.Connect($siteServerName))
  {
      $result = $connectionManager.QueryProcessor.ExecuteQuery($query)
      
      foreach($i in $result.GetEnumerator())
      {
        $returnValue = $i
        break
      }
      
      $connectionManager.Dispose() 
  }
  
  $returnValue
}

function Get-ApplicationObjectFromServer($appName,$siteServerName)
{    
    $resultObject = Get-ExecuteWqlQuery $siteServerName "select thissitecode from sms_identification" 
    $siteCode = $resultObject["thissitecode"].StringValue
    
    $path = [string]::Format("\\{0}\ROOT\sms\site_{1}", $siteServerName, $siteCode)
    $scope = New-Object System.Management.ManagementScope -ArgumentList $path
    
    $query = [string]::Format("select * from sms_application where LocalizedDisplayName='{0}' AND ISLatest='true'", $appName.Trim())
    
    $oQuery = New-Object System.Management.ObjectQuery -ArgumentList $query
    $obectSearcher = New-Object System.Management.ManagementObjectSearcher -ArgumentList $scope,$oQuery
    $applicationFoundInCollection = $obectSearcher.Get()    
    $applicationFoundInCollectionEnumerator = $applicationFoundInCollection.GetEnumerator()
    
    if($applicationFoundInCollectionEnumerator.MoveNext())
    {
        $returnValue = $applicationFoundInCollectionEnumerator.Current
        $getResult = $returnValue.Get()        
        $sdmPackageXml = $returnValue.Properties["SDMPackageXML"].Value.ToString()
        [Microsoft.ConfigurationManagement.ApplicationManagement.Serialization.SccmSerializer]::DeserializeFromString($sdmPackageXml)
    }
}


 function Load-ConfigMgrAssemblies()
 {
     
     $AdminConsoleDirectory = Split-Path $env:SMS_ADMIN_UI_PATH -Parent
     $filesToLoad = "Microsoft.ConfigurationManagement.ApplicationManagement.dll","AdminUI.WqlQueryEngine.dll", "AdminUI.DcmObjectWrapper.dll" 
     
     Set-Location $AdminConsoleDirectory
     [System.IO.Directory]::SetCurrentDirectory($AdminConsoleDirectory)
     
      foreach($fileName in $filesToLoad)
      {
         $fullAssemblyName = [System.IO.Path]::Combine($AdminConsoleDirectory, $fileName)
         if([System.IO.File]::Exists($fullAssemblyName ))
         {   
             $FileLoaded = [Reflection.Assembly]::LoadFrom($fullAssemblyName )
         }
         else
         {
              Write-Output ([System.String]::Format("File not found {0}",$fileName )) -backgroundcolor "red"
         }
      }
 }



$SiteCode = $SiteCode = (get-psdrive -PSProvider CMSite).Name
$SMSProvider = "INFRA-SCCM-1.agences.siege.socotec.fr"
$AppList = Get-CMApplication
$ProgList = Get-CMProgram
$TSList = Get-CMTaskSequence | where-object {$_.PackageID -eq $TS }


$LocBefore = $null
$LocBefore = Get-Location
Load-ConfigMgrAssemblies 
Set-Location "$($SiteCode):"

 
 
foreach ($TSInfo in $TSList)
{
    "{0}:{1}" -f $TSInfo.packageID, $TSInfo.Name
    $TSDependents = Get-WMIObject -NameSpace "Root\SMS\Site_$($SiteCode)" -Class SMS_TaskSequenceAppReferencesInfo | Where-Object {$_.PackageID -eq "$($TSInfo.PackageID)"}
 
    foreach ($TSDep in $TSDependents)
    {
        $Apps = $AppList | where-object { $_.CI_UniqueID -like "$($TSDep.RefAppModelName)*" }
 
        foreach ($App in $Apps)
            {
                "  {0}" -f $App.LocalizedDisplayName 

                ############################################################    
                $ApplicationName = $App.LocalizedDisplayName

                $application = [wmi](Get-WmiObject SMS_Application -Namespace root\sms\site_$($SiteCode) |  where {($_.LocalizedDisplayName -eq "$($ApplicationName)") -and ($_.IsLatest)}).__PATH

                $applicationXML = Get-ApplicationObjectFromServer "$($ApplicationName)" $SMSProvider

                if ($applicationXML.DeploymentTypes -ne $null)
                    { 
                        foreach ($a in $applicationXML.DeploymentTypes)
                            {
                                $InstallCommandLine = $a.Installer.InstallCommandLine
                                $ContentPath = $a.Installer.Contents[0].Location
                            }
                    }


                if (Get-CMPackage -Name "$($ApplicationName)")
                    {
                        Write-Output "Package already exists"
                        Set-Location $LocBefore
                        exit
                    }

                New-CMPackage -Name "$($ApplicationName)" -Path $ContentPath 
                New-CMProgram -PackageName "$($ApplicationName)" -StandardProgramName "Install $($ApplicationName)" -RunMode RunWithAdministrativeRights -UserInteraction $false -RunType Hidden -ProgramRunType WhetherOrNotUserIsLoggedOn -CommandLine $InstallCommandLine 

                $Package = Get-CMPackage -Name "$($ApplicationName)"

                $Program = Get-WmiObject -Class sms_program -Namespace root\sms\site_$SiteCode -Filter "PackageID = '$($Package.PackageID)'"

                 if (-not ($Program.ProgramFlags -band 0x00000001))
                    {
                        $Program.ProgramFlags = $Program.ProgramFlags -bxor 0x00000001
                        $Program.put()
                    }

                ############################################################


                #Set-CMApplication -Id $App.CI_ID -AutoInstall $true
                #$AppList = Get-CMApplication
            }
    }
 <#
    $TSDependents = Get-WMIObject -NameSpace "Root\SMS\Site_$($SiteCode)" -Class SMS_TaskSequencePackageReference | Where-Object {$_.PackageID -eq "$($TSInfo.PackageID)"}
 
    foreach ($TSDep in $TSDependents)
    {
        $Progs = $ProgList | where-object { $_.PackageID -like $TSDep.RefPackageID }
 
        foreach ($Prog in $Progs)
        {
            if (($Prog.ProgramFlags -band 33) -eq 0)
            {
                "  {0}:{1}:{2}" -f $Prog.PackageID, $Prog.PackageName, $Prog.ProgramName
                #Set-CMProgram -StandardProgram -ProgramName "$($Prog.ProgramName)" -Id $Prog.PackageID -EnableTaskSequence $true
                #$ProgList = Get-CMProgram
            }
        }
    }
    "  " #>
}

