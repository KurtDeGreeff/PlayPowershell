<# LDAP info
l=teamcli0-lda,dc=pol,dc=be
CN-bigboss,l=teamcli0-lda,dc=pol,dc=be
XBhaszDmKKduuXr4
#>

#Store credentials for repetive authentication
read-host -assecurestring | convertfrom-securestring | out-file C:\mysecstr.txt
$pass = get-content C:\mysecstr.txt | convertto-securestring
$mycred = new-object -typename System.Management.Automation.PSCredential -argumentlist “CN=bigboss,l=teamcli0-lda,dc=pol,dc=be”,$pass

# PDC Server
$server = "10.5.21.180"

#Connect to OpenLDAP
connect-ldap -server $server -cred $mycred

#Base DN
$basedn = "l=teamcli0-lda,dc=pol,dc=be"
get-ldap -server $server -cred $mycred -dn $basedn # -search "(&(objectclass=group)(cn=*))"

#All Groups
$groupdn = "ou=Groups,l=teamcli0-lda,dc=pol,dc=be"
get-ldap -server $server -cred $mycred -dn $groupdn | -search "(objectClass=posixGroup)"

#All users
$userdn = "ou=People,l=teamcli0-lda,dc=pol,dc=be"
get-ldap -server $server -cred $mycred -dn $userdn -Search "(objectClass=person)" |
select cn,sn,uid,gidNumber,sambaHomePath,homeDirectory,sambaLogonScript, givenName,description,displayName,employeeNumber | ft -AutoSize | Out-File C:\ldapUsers.txt

$userdn = "ou=People,l=teamcli0-lda,dc=pol,dc=be"
get-ldap -server $server -cred $mycred -dn $userdn -Search "(objectClass=person)" |
select cn,sn,uid,gidNumber,sambaHomePath,homeDirectory,sambaLogonScript, givenName,description,displayName,employeeNumber | ConvertTo-Csv

Out-File C:\ldapUsers.txt
Export-Csv -Path c:\ldapUsers.csv


#All computers
$compdn = "ou=Computers,l=teamcli0-lda,dc=pol,dc=be"
get-ldap -server $server -cred $mycred -dn $compdn

"System.Collections.Generic.List`1[System.String]"