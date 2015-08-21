$objUser = New-Object System.Security.Principal.NTAccount("administrator")
$strSID = $objUser.Translate([System.Security.Principal.SecurityIdentifier])
$strSID.Value


$ldapRoot="LDAP://172.18.2.22/dc=xxx,dc=yyyl"
$directoryEntry = New-Object System.DirectoryServices.DirectoryEntry($ldapRoot)
$directoryEntry.psbase.AuthenticationType=[System.DirectoryServices.AuthenticationTypes]::FastBind
$objSearcher = New-Object System.DirectoryServices.DirectorySearcher($directoryEntry)

