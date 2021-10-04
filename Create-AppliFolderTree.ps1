
Param(
  [string]$Release = 'R01',
  [string]$Techno = 'MSI',
  [int]$DTCount = 1,
  [parameter(Mandatory=$true)][string]$Appli
    )


$SourcePath = '\\fff.lan\sccmfolder\FFF\Softwares'
$AppliFolder = "$Appli-$Release"

write-host will create "$SourcePath\$AppliFolder"
write-host will create "$SourcePath\$AppliFolder\DT01-$AppliFolder-$Techno"


New-Item -Path "$SourcePath\$AppliFolder" -ItemType Directory
New-Item -Path "$SourcePath\$AppliFolder\_ico" -ItemType Directory
New-Item -Path "$SourcePath\$AppliFolder\_docs" -ItemType Directory
New-Item -Path "$SourcePath\$AppliFolder\DT01-$AppliFolder-$Techno-Description" -ItemType Directory
if ($DTCount -eq '2') {New-Item -Path "$SourcePath\$AppliFolder\DT02-$AppliFolder-$Techno-Description" -ItemType Directory}
if ($DTCount -eq '3') {New-Item -Path "$SourcePath\$AppliFolder\DT03-$AppliFolder-$Techno-Description" -ItemType Directory}
if ($DTCount -eq '4') {New-Item -Path "$SourcePath\$AppliFolder\DT04-$AppliFolder-$Techno-Description" -ItemType Directory}
