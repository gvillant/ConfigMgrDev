# Ce script compare les applications présentes dans 2 DPG différents. Décommenter les dernières étapes pour copier les applications du groupe source vers le groupe destination. 


$sitecode  = 'STG'
$provider  = 'FRPSCM01'
$DPGroupSource = 'DPG-Worldwide'
$namespace = "root\sms\site_$sitecode"
$DPGroupTarget = 'DPG-LOC-FR'

$DPGroupSourceID= (gwmi -n $namespace -query "select * from sms_distributionpointgroup where name='$DPGroupSource'" -comp $provider).groupid
$pkgSource = gwmi -n $namespace -query "select * from sms_dpgroupcontentinfo where groupid='$DPGroupSourceID' AND ObjectTypeID=31" -comp $provider |  sort name | select -expand name 

# $pkgSource

$DPGroupTargetID= (gwmi -n $namespace -query "select * from sms_distributionpointgroup where name='$DPGroupTarget'" -comp $provider).groupid
$pkgTarget = gwmi -n $namespace -query "select * from sms_dpgroupcontentinfo where groupid='$DPGroupTargetID' AND ObjectTypeID=31" -comp $provider |  sort name | select -expand name 

# $pkgTarget

# Trouve le contenu présent dans les 2 DPG
$CompareEqual = Compare-Object $pkgSource $pkgTarget -ExcludeDifferent -IncludeEqual 
#$CompareEqualApp = $result | Select-Object InputObject 

foreach ($EqualApp in $CompareEqual) { 
    $CompareEqualApp += $($_.InputObject)
    #write-host "$($_.InputObject) exists in file 1" 
        }
$CompareEqualApp 

$CompareEqual | 
%{ 
    "$($_.InputObject) : Remove from $DPGroupTarget" 
    $resultEqual += $($_.InputObject)
    Remove-CMContentDistribution -ApplicationName $($_.InputObject) -DistributionPointGroupName $DPGroupTarget -Force
}
$ResultEqual

<#
#Copie le contenu du DPGroup Source vers le DPGroup Target
foreach ($app in $pkgSource) { 
    write-host adding $app to dpGroup $DPGroupTarget 
    Start-CMContentDistribution -ApplicationName $app -DistributionPointGroupName $DPGroupTarget
    }

    #>


#Retire le contenu en doublon du DPGroup Target 
#foreach ($app in $CompareEqualApp) { 
#    write-host removing $app to dpGroup $DPGroupTarget
  #  Remove-CMContentDistribution -ApplicationName $app -DistributionPointGroupName $DPGroupTarget
#    }

 