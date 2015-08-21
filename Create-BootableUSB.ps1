# Script to create bootable W7 USB media with source files located on W2K12 WDS Server. 
# Folder is selected by user, but should select C:\MEDIA001\CONTENT as default.
# This way, the user can also select his own media folder to create a bootable USB.
# Script needs to be launched from a W2K12 WDS server with administrator rights.
# Author: Kurt De Greeff - Team Client

#Requires -Version 3

Function Display-Prompt {
Param (
[string] $PrompText,
[int] $PromptWaitTime,
[string] $PromptTitle,
[int] $PromptType
)
$PromptShell = New-Object -ComObject Wscript.shell
$PromptAnswer = $PromptShell.popup($PrompText,$PromptWaitTime,$PromptTitle,$PromptType)
}

<# Prompttype can be one of following:
0 : OK button
1 : OK,Cancel
2 : Abort,Retry,Ignore
3 : Yes,No,Cancel
4 : Yes,No
5 : Retry,Cancel
6 : Cancel,Try Again,Continue
16: STOP icon
32: QUESTION icon
48: EXCLAMATION icon
64: INFORMATION icon
4096: System message box in topmost window
Return values: -1,OK=1,Cancel=2,Abort=3,Retry=4,Ignore=5,Yes=6,No=7,TryAgain=10,Continue=11
#>

Function Select-Folder {
Param (
$message = 'Select a folder',
$path = 0
)
$object = New-Object -ComObject Shell.Application
$folder = $object.BrowseForFolder(0, $message, 80, $path)
if ($folder -ne $null) { $folder.self.Path}
}

$identity = [security.principal.WindowsIdentity]::GetCurrent()
$principal = New-Object security.principal.windowsprincipal $identity
$isAdmin = $principal.IsInRole([security.principal.windowsbuiltinrole]::Administrator)
if ($isAdmin -eq $false) 
{Display-Prompt -PromptTitle "Required to run as administrator" -PrompText 'This script must be run from an elevated Administrator prompt!' -PromptType 48 -PromptWaitTime 5;exit}

<#$Script = $MyInvocation.PSCommandPath
$Args = '-noprofile -nologo -executionpolicy bypass -file "{0}"' -f $Script
Start-Process -FilePath 'powershell.exe' -ArgumentList $args -Verb RunAs
exit
}
'Running with admin privileges'
#>

Display-Prompt -PromptTitle "Running as Administrator" -PrompText 'Script running with Administrator Privileges.' -PromptType 64 -PromptWaitTime 1

#Find Driveletter USB Media
Write-Host (Get-date -Format u)' Please make sure your USB is NOT yet inserted. If so, please remove it now, then press OK button.'
Display-Prompt -PromptTitle "Remove USB if needed" -PrompText 'Please make sure your USB is NOT yet inserted. If so, please remove it now, then press OK button.' -PromptType 48
$before = (Get-Volume).Driveletter
$beforeDisk = (Get-Disk).Number

Write-Host (Get-date -Format u) 'You may now insert your USB. ALL data on it will be ERASED. Press OK when ready.'
Display-Prompt -PromptTitle "Insert USB" -PrompText 'You may now insert your USB. ALL data will be erased. Press OK when ready.' -PromptType 48
$after = (Get-Volume).Driveletter
$afterDisk = (Get-Disk).Number

$MountDrive = (Compare-Object $before $after -PassThru)
$MountDrive += ":"
$DiskNumber = (Compare-Object $beforeDisk $afterDisk -PassThru)

$source = Select-Folder -message 'Select your Media Content Folder!  Please Select C:\MEDIA001\CONTENT folder as Default, if no newer is available!' -path "c:\"

if ($source -eq $null) {exit}

Write-Host (Get-date -Format u) "Mounting USB with driveletter $MountDrive"
Display-Prompt -PromptTitle "Information" -PrompText  "Mounting USB with driveletter $MountDrive" -PromptType 64 -PromptWaitTime 1

Write-Host (Get-date -Format u) "Will now format the drive $MountDrive .."
Display-Prompt -PromptTitle "Information" -PrompText  "Will now format the drive $MountDrive .." -PromptType 64 -PromptWaitTime 2

#get-disk -Number $DiskNumber | Clear-Disk -RemoveData -Confirm:$false
#$MountDrivemin = (ls function:[d-z]: -n | ?{!(Test-Path $_)})[0] -replace ':','' 
#$MountDrivemin += ':'
#New-partition -DiskNumber $DiskNumber -UseMaximumSize -IsActive -DriveLetter ([char]$MountDrivemin)  | 
#Format-Volume -FileSystem NTFS -NewFileSystemLabel W7 -Confirm:$false

Get-disk -Number $DiskNumber | Clear-Disk -RemoveData -RemoveOEM -PassThru -Confirm:$false |
New-Partition -UseMaximumSize -IsActive  | Get-Volume -OutVariable disk | Format-Volume -FileSystem NTFS -Confirm:$false
if (!(test-path ($disk.Driveletter+':'))) {
Get-Partition -DiskNumber $DiskNumber | 
Set-Partition -NewDriveLetter ([char]((ls function:[d-z]: -n | ?{!(Test-Path $_)})[0] -replace ':','')) | 
Get-Volume -OutVariable disk
}

#$Destination = $disk.Driveletter + ':'
$Destination = ((get-disk -Number $DiskNumber | Get-partition).DriveLetter + ":")
if (!(test-path $Destination)) {exit}

Write-Host (Get-date -Format u) "Drive $Destination is NTFS and bootable"
Display-Prompt -PromptTitle "Information" -PrompText  "Drive $Destination is NTFS and bootable" -PromptType 64 -PromptWaitTime 1

Write-Host (Get-date -Format u) "Will now create Windows 7 USB installation from $source"
Display-Prompt -PromptTitle "Information" -PrompText  "Will now create Windows 7 USB media from $source" -PromptType 64 -PromptWaitTime 2

if (Test-Path -Path $source) {
"$source exists" ;
Write-Host (Get-date -Format u)" Please wait until process is finished..."
Display-Prompt -PromptTitle "Information" -PrompText  "Please wait unplugging USB until process is finished... " -PromptType 64 -PromptWaitTime 3
Start-Process Robocopy -argumentList "$source $Destination /E" -Wait }
else {"There is no valid media folder choosen"}

Write-Host (Get-date -Format u)" Finished! You have now a bootable W7 installation stick."
Display-Prompt -PromptTitle "Information" -PrompText  "Finished! You have now a bootable W7 installation stick." -PromptType 64 -PromptWaitTime 5





