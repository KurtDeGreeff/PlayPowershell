<#Create Folder with NTFS Permissions

This example creates a new folder and illustrates how you can add new permissions to the existing permissions#>

$Path = 'c:\protectedFolder' 
 
# create new folder 
$null = New-Item -Path $Path -ItemType Directory 
 
# get permissions 
$acl = Get-Acl -Path $path 
 
# add a new permission 
$permission = 'Everyone', 'FullControl', 'ContainerInherit, ObjectInherit', 'None', 'Allow' 
$rule = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList $permission 
$acl.SetAccessRule($rule)
 
# add another new permission 
# WARNING: Replace username "Tobias" with the user name or group that you want to grant permissions 
$permission = 'Tobias', 'FullControl', 'ContainerInherit, ObjectInherit', 'None', 'Allow' 
$rule = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList $permission 
$acl.SetAccessRule($rule)
 
# set new permissions 
$acl | Set-Acl -Path $path