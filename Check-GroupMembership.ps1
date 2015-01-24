####################################
#Function to check group membership
####################################
function Check-GroupMembership ([System.Security.Principal.WindowsIdentity]$User, [string]$GroupName)
{
$WindowsPrincipal = New-Object System.Security.Principal.WindowsPrincipal($User)
 
if($WindowsPrincipal.IsInRole($GroupName))
{
$bIsMember = $true
} else {
$bIsMember = $false
}
return $bIsMember
}

#Current User Example:
$me = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$group = “administrators”
$IsMember = Check-GroupMembership $me $group

#########################
#Get Group Membership Fast - Translate SID to Name  
#########################
[System.Security.Principal.WindowsIdentity]::GetCurrent().Groups.Value |
  ForEach-Object {
    $sid = $_
    $objSID = New-Object System.Security.Principal.SecurityIdentifier($sid) 
    $objUser = $objSID.Translate( [System.Security.Principal.NTAccount]) 
    $objUser.Value
  }

#######################################
# obtain current user Group Membership
#######################################
$CurrentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent() 
$WindowsPrincipal = New-Object System.Security.Principal.WindowsPrincipal($CurrentUser)

if($WindowsPrincipal.IsInRole("Domain Admins"))
{  "User is member of domain  admins" }
else
{  "User is not a member of domain admins" }