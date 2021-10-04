Function Get-RecursiveAzureAdGroupMemberUsers{
    [cmdletbinding()]
    param(
       [parameter(Mandatory=$True,ValueFromPipeline=$true)]
       $AzureGroup
    )
        Begin{
            If(-not(Get-AzureADCurrentSessionInfo)){Connect-AzureAD}
        }
        Process {
            Write-Verbose -Message "Enumerating $($AzureGroup.DisplayName)"
            $Members = Get-AzureADGroupMember -ObjectId $AzureGroup.ObjectId -All $true
            
            $UserMembers = $Members | Where-Object{$_.ObjectType -eq 'User'}
            If($Members | Where-Object{$_.ObjectType -eq 'Group'}){
                $UserMembers += $Members | Where-Object{$_.ObjectType -eq 'Group'} | ForEach-Object{ Get-RecursiveAzureAdGroupMemberUsers -AzureGroup $_}
            }
        }
        end {
            Return $UserMembers
        }
    }