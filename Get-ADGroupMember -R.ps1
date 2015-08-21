function Get-MembersFromAD{
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [string]$DistinguishedGroupName
    )

    Write-Verbose "Getting `"$DistinguishedGroupName`""
    $group = [adsi]"LDAP://$DistinguishedGroupName"

    Write-Verbose "Getting members ..."
    foreach($DN in $group.member){        
        $member = [adsi]"LDAP://$DN"
        if($member.objectClass -contains 'group'){
            Write-Verbose "RECURSIVE"
            $peeps += @(Get-MembersFromAD $member.distinguishedName -Verbose)
        }
        else{
            $peeps += @($member.sAMAccountName)
        }
    }

    return $peeps
}

Get-MembersFromAD 'CN=Group Name,OU=Groups,OU=Practice,OU=Location,DC=company,DC=com' -Verbose