#Create AD Organizational Unit and 10 users
$NewOUSplat = @{ 
    Name="Fedpol" 
    Description="MyScript" 
    Path="DC=Contoso,DC=COM" 
    } 
New-ADOrganizationalUnit @NewOUSplat

for ($i=1;$i -le 10;$i++) { 
    $NewUserSplat = @{ 
        SamAccountName="User$i" 
        Name="User$i" 
        Path="OU=Fedpol,DC=Contoso,DC=COM" 
        } 
    New-ADUser @NewUserSplat 
    }

Get-ADUser -Filter * -SearchBase "OU=Fedpol,DC=Contoso,DC=COM" |
select SamAccountName


#CREATING A NEW USER
#Convert the password to a secure string
$pwd = ConvertTo-SecureString -string "ChangeMe12" -AsPlainText -force

#or ask the user to supply, which is safer
$pwd = Read-Host -AsSecureString

#create the user
New-ADUser -Name "Kurt De Greeff" -SamAccountName "kdgreeff" -GivenName "Kurt" -Surname "De Greeff" `
-DisplayName "Kurt De Greeff" -Path "OU=users,DC=fedpol,DC=local" -Enabled $true -AccountPassword $pwd

#Create users from csv where column headers match the parameter names so the pipeline does all the work
Import-CSV -Path C:\data\userlist.csv | New-ADUser -Enabled $true -AccountPassword $pwd

#MANAGING GROUP MEMBERSHIP
#Add-ADGroupMember does not support pipeline input, Add-ADPrincipalGroupMembership does 
Add-ADGroupMember -Identity "Marketing Users" -Members jadams,tthumb,mtwain

Import-CSV -Path C:\data\userlist.csv | New-ADUser -Enabled $true -AccountPassword $pwd -PassThru | 
Add-ADPrincipalGroupMembership -MemberOf "Marketing Users"

#RESETTING USER ACCOUNT PASSWORDS; ommitting the reset parameter indicates a change password (you need to supply old & new password)
Set-ADAccountPassword -Identity "tthumb" -NewPassword $pwd -Reset

#Change password at logon
Set-ADUser -Identity tthumb -ChangePasswordAtLogon $true


#SEARCHING AD OBJECTS
#The -LDAPFilter parameter takes a standard LDAP query as input: all computer objects that have their OperatingSystem attribute set to Windows Server 2008 R2 Enterprise. 
#The -SearchBase parameter provides the startlocation to search in the AD hierarchy.
#-SearchScope parameter tells how to recurse (all containers) underneath the search base to find the specified objects.
Get-ADObject -LDAPFilter "(&(operatingSystem=Windows Server 2008 R2 Enterprise)(objectClass=computer))" -SearchBase "dc=fedpol,dc=local" -SearchScope Subtree

#Use Search-ADAccount for preset conditions, such as disabled/locked out accounts or accounts with expired passwords.
Search-ADAccount -PasswordExpired -UsersOnly -SearchBase "OU=sdm,dc=cpandl,dc=com" -SearchScope OneLevel