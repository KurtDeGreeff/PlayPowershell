#finding the groups of which  local accounts are members
$data = Get-CimInstance -ClassName Win32_UserAccount -Filter “LocalAccount = $true” |
foreach { $groups = Get-CimAssociatedInstance -InputObject $PSItem -ResultClassName Win32_Group | select -ExpandProperty Name
$PSItem | Add-Member -MemberType NoteProperty -Name “Groups” -Value ($groups -join “;”) -PassThru } 
$data | select Caption, Groups


#Allows code to check the Windows group membership of a Windows user.
System.Security.Principal.WindowsPrincipal


function Get-GroupMembership
{      param(
        $UserName = $env:username,       
        $Domain = $env:userdomain    
    )     $user = Get-WmiObject -Class Win32_UserAccount -Filter "Name='$UserName' and Domain='$Domain'"
    $user.GetRelated('Win32_Group')
}

####LDAP 
$user = [adsi] "LDAP://localhost:389/cn=MyerKen,ou=West,ou=Sales,dc=Fabrikam,dc=COM"
$user.MemberOf


(New-Object System.Security.Principal.WindowsPrincipal([System.Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)



#Check user group membership
$CurrentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent() 
$WindowsPrincipal = New-Object System.Security.Principal.WindowsPrincipal($CurrentUser)

if($WindowsPrincipal.IsInRole("Domain Admins"))
{
    "User is member of domain  admins"
    # you code goes here
}
else
{
   ...
}

##########################################################
$CurrentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$WindowsPrincipal = New-Object System.Security.Principal.WindowsPrincipal($CurrentUser)

if($WindowsPrincipal.IsInRole(“NL.XS.Administration”))
{
\\FS01\groups\install\mappings\guimap.exe b: \\FS01\Administration
Get-Process guimap | ForEach-Object { $_.WaitForExit() }
}
if($WindowsPrincipal.IsInRole(“NL.XS.Support”))
{
\\FS01\groups\install\mappings\guimap.exe t: \\FS01\Support
}