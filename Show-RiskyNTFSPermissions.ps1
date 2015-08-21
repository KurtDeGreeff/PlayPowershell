<#Here is a quick and easy way to find NTFS permissions that are potentially dangerous. 
The script tests all folders in $pathsToCheck and reports any security access control entry that 
grants access to one of the filesystem flags defined in $dangerousBitMask.In the example, 
the script takes all paths found in your %PATH% environment variable. 
These paths are risk vectors and should be protected by NTFS privileges, 
granting write access only to Administrators and the system.#>

# list of paths to check for dangerous NTFS permissions 
$pathsToCheck = $env:Path -split ';' 
 
# these are the bits to watch for 
# if *any* one of these is set, the folder is reported 
$dangerousBitsMask = '011010000000101010110' 
$dangerousBits = [Convert]::ToInt64($dangerousBitsMask, 2)
 
# check all paths... 
$pathsToCheck | 
ForEach-Object { 
  $path = $_ 
  # ...get NTFS security descriptor... 
  $acl = Get-Acl -Path  $path 
  # ...check for any "dangerous" access right 
  $acl.Access |
  Where-Object { $_.AccessControlType -eq 'Allow' } |
  Where-Object { ($_.FileSystemRights -band $dangerousBits) -ne 0 } |
  ForEach-Object {
    # ...append path information, and display filesystem rights as bitmask 
    $ace = $_ 
    $bitmask = ('0' * 64) + [Convert ]::toString([int]$ace.FileSystemRights, 2)
    $bitmask = $bitmask.Substring($bitmask.length - 64)
    $ace | Add-Member -MemberType NoteProperty -Name Path -Value $path -PassThru | Add-Member -MemberType NoteProperty -Name Rights -Value $bitmask -PassThru 
  }
} |
Sort-Object -Property IdentityReference | 
Select-Object -Property IdentityReference, Path, Rights, FileSystemRights | 
Out-GridView