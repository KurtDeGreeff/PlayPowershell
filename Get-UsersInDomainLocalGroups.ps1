function Get-UsersInDomainLocalGroups {
    $Groups = Get-ADGroup -Filter 'GroupScope -eq "DomainLocal"'
    foreach ($Group in $Groups) {
        $Users = $Group | Get-ADGroupMember | Where-Object {$_.ObjectClass -eq 'User'}
        if ($Users -ne $null) {
            foreach ($User in $Users) {
                $Object = New-Object -TypeName PSObject
                $Object | Add-Member -MemberType noteproperty -name 'Group' -Value $Group.Name
                $Object | Add-Member -MemberType noteproperty -name 'UserName' -value $User.samaccountname
                $Object
            }
        }
    }
}