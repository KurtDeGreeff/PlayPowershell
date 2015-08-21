#Automating Active Directory tasks

# find your own user account by SAMAccountName 
Get-ADUser -Identity $env:USERNAME
 
# find user account by DN 
Get-ADUser -Identity 'CN=TWeltner,OU=Users,OU=Hannover,OU=Trainees,DC=powershell,DC=local'
 
# find your own user account and return all available attributes 
Get-ADUser -Identity $env:USERNAME -Properties *
 
# find your own user account and change attributes 
Get-ADUser -Identity $env:USERNAME | Set-QADUser -Description 'My account'
 
# find all user accounts where the SAMAccount name starts with "T" 
Get-ADUser -Filter 'SAMAccountName -like "T*"'
 
# find user account "ThomasP" and use different logon details for AD 
 
# logon details for your AD 
$cred = Get-Credential
$IPDC = '10.10.11.2'
Get-ADUser -Identity ThomasP -Credential $cred -Server $IPDC
 
# find all groups and output results to gridview 
Get-ADGroup -Filter * | Out-GridView
 
# find all groups below a given search root 
Get-ADGroup -Filter * -SearchBase 'OU=test,DC=powershell,DC=local'
 
# get all members of a group 
Get-ADGroupMember -Identity 'Domain Admins'
 
# create new user account named "Tom" 
# define password 
$secret = 'Initial$$00' | ConvertTo-SecureString -AsPlainText -Force
$secret = Read-Host -Prompt 'Password' -AsSecureString
New-ADUser -Name Tom -SamAccountName Tom -ChangePasswordAtLogon $true -AccountPassword $secret -Enabled $true
 
# delete user account "Tom" 
Remove-ADUser -Identity Tom -Confirm:$false
 
# create an organizational unit named "NewOU1" in powershell.local 
New-ADOrganizationalUnit -Name 'NewOU1' -Path 'DC=powershell,DC=local'
 
# all user accounts not used within last 180 days 
$FileTime = (Get-Date).AddDays(-180).ToFileTime()
$ageLimit = "(lastLogontimestamp<=$FileTime)"
Get-ADUser -LDAPFilter $ageLimit


# create new AD group 
New-ADGroup -DisplayName PowerShellGurus -GroupScope DomainLocal -Name PSGurus
 
# get group 
Get-ADGroup -Identity PSGurus -Credential $cred -Server 172.16.14.53
 
# select users by some criteria 
$newMembers = Get-ADUser -Filter 'Name -like "User*"'
# add them to new AD group 
Add-ADGroupMember -Identity 'PSGurus' -Members $newMembers
