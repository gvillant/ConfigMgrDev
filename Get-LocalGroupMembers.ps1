<#
===================================================================================  
DESCRIPTION:    Function enumerates members of all local groups (or a given group). 
If -Server parameter is not specified, it will query localhost by default. 
If -Group parameter is not specified, all local groups will be queried. 
            
AUTHOR:    	Piotr Lewandowski 
VERSION:    1.0  
DATE:       29/04/2013  
SYNTAX:     Get-LocalGroupMembers [[-Server] <string[]>] [[-Group] <string[]>] 
             
EXAMPLES:   

Get-LocalGroupMembers -server "scsm-server" | ft -AutoSize

Server      Local Group          Name                 Type  Domain  SID
------      -----------          ----                 ----  ------  ---
scsm-server Administrators       Administrator        User          S-1-5-21-1473970658-40817565-21663372-500
scsm-server Administrators       Domain Admins        Group contoso S-1-5-21-4081441239-4240563405-729182456-512
scsm-server Guests               Guest                User          S-1-5-21-1473970658-40817565-21663372-501
scsm-server Remote Desktop Users pladmin              User  contoso S-1-5-21-4081441239-4240563405-729182456-1272
scsm-server Users                INTERACTIVE          Group         S-1-5-4
scsm-server Users                Authenticated Users  Group         S-1-5-11



"scsm-dc01","scsm-server" | Get-LocalGroupMembers -group administrators | ft -autosize

Server      Local Group    Name                 Type  Domain  SID
------      -----------    ----                 ----  ------  ---
scsm-dc01   administrators Administrator        User  contoso S-1-5-21-4081441239-4240563405-729182456-500
scsm-dc01   administrators Enterprise Admins    Group contoso S-1-5-21-4081441239-4240563405-729182456-519
scsm-dc01   administrators Domain Admins        Group contoso S-1-5-21-4081441239-4240563405-729182456-512
scsm-server administrators Administrator        User          S-1-5-21-1473970658-40817565-21663372-500
scsm-server administrators !svcServiceManager   User  contoso S-1-5-21-4081441239-4240563405-729182456-1274
scsm-server administrators !svcServiceManagerWF User  contoso S-1-5-21-4081441239-4240563405-729182456-1275
scsm-server administrators !svcscoservice       User  contoso S-1-5-21-4081441239-4240563405-729182456-1310
scsm-server administrators Domain Admins        Group contoso S-1-5-21-4081441239-4240563405-729182456-512
 
===================================================================================  

#>
Function Get-LocalGroupMembers
{
param(
[Parameter(ValuefromPipeline=$true)][array]$server = $env:computername,
$GroupName = $null
)
PROCESS {
    $finalresult = @()
    $computer = [ADSI]"WinNT://$server"

    if (!($groupName))
    {
    $Groups = $computer.psbase.Children | Where {$_.psbase.schemaClassName -eq "group"} | select -expand name
    }
    else
    {
    $groups = $groupName
    }
    $CurrentDomain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().GetDirectoryEntry() | select name,objectsid
    $domain = $currentdomain.name
    $SID=$CurrentDomain.objectsid
    $DomainSID = (New-Object System.Security.Principal.SecurityIdentifier($sid[0], 0)).value


    foreach ($group in $groups)
    {
    $gmembers = $null
    $LocalGroup = [ADSI]("WinNT://$server/$group,group")


    $GMembers = $LocalGroup.psbase.invoke("Members")
    $GMemberProps = @{Server="$server";"Local Group"=$group;Name="";Type="";ADSPath="";Domain="";SID=""}
    $MemberResult = @()


        if ($gmembers)
        {
        foreach ($gmember in $gmembers)
            {
            $membertable = new-object psobject -Property $GMemberProps
            $name = $gmember.GetType().InvokeMember("Name",'GetProperty', $null, $gmember, $null)
            $sid = $gmember.GetType().InvokeMember("objectsid",'GetProperty', $null, $gmember, $null)
            $UserSid = New-Object System.Security.Principal.SecurityIdentifier($sid, 0)
            $class = $gmember.GetType().InvokeMember("Class",'GetProperty', $null, $gmember, $null)
            $ads = $gmember.GetType().InvokeMember("adspath",'GetProperty', $null, $gmember, $null)
            $MemberTable.name= "$name"
            $MemberTable.type= "$class"
            $MemberTable.adspath="$ads"
            $membertable.sid=$usersid.value
            

            if ($userSID -like "$domainsid*")
                {
                $MemberTable.domain = "$domain"
                }
            
            $MemberResult += $MemberTable
            }
            
         }
         $finalresult += $MemberResult 
    }
    $finalresult | select server,"local group",name,type,domain,sid
    }
}
