"Path = "+ (Split-Path -parent $MyInvocation.MyCommand.Definition)

# Free Space on C:
$DiskDrive = Get-WmiObject -Class Win32_LogicalDisk | Where {$_.DeviceId -Eq "C:"}
$DriveSpace = ($DiskDrive.FreeSpace /1GB) 
"Free Disk Space on C: = $DriveSpace GB"

# Don't hide file extensions
$ext = New-Object -ComObject WScript.Shell
$ext.RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\HideFileExt","0","REG_DWORD")

