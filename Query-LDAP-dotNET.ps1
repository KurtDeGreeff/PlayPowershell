#Acces Non-Microsoft LDAP servers via .NET

$LDAPDirectoryService = '192.168.1.1:389' 
$DomainDN = 'dc=mycompany,dc=com' 
$LDAPFilter = '(&(cn=SomeGroup))' 
 
 
$null = [System.Reflection.Assembly]::LoadWithPartialName('System.DirectoryServices.Protocols')
$null = [System.Reflection.Assembly]::LoadWithPartialName('System.Net')
$LDAPServer = New-Object System.DirectoryServices.Protocols.LdapConnection $LDAPDirectoryService 
$LDAPServer.AuthType = [System.DirectoryServices.Protocols.AuthType]::Anonymous
 
$LDAPServer.SessionOptions.ProtocolVersion = 3
$LDAPServer.SessionOptions.SecureSocketLayer =$false
  
$Scope = [System.DirectoryServices.Protocols.SearchScope]::Subtree
$AttributeList = @('*')
 
$SearchRequest = New-Object System.DirectoryServices.Protocols.SearchRequest -ArgumentList $DomainDN,$LDAPFilter,$Scope,$AttributeList 
 
$groups = $LDAPServer.SendRequest($SearchRequest)
 
foreach ($group in $groups.Entries) 
{
  $users=$group.attributes['memberUid'].GetValues('string')
  foreach ($user in $users) {
    Write-Host $user 
  }
}