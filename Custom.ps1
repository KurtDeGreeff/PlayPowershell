"Path = "+ (Split-Path -parent $MyInvocation.MyCommand.Definition)

# Free Space on C:
$DiskDrive = Get-WmiObject -Class Win32_LogicalDisk | Where {$_.DeviceId -Eq "C:"}
$DriveSpace = ($DiskDrive.FreeSpace /1GB) 
"Free Diskspace C: = $DriveSpace GB"

#Available RAM
"RAM = "+((Get-WmiObject Win32_OperatingSystem).TotalVisibleMemorySize / 1kb).tostring("F00") +" MB"

# Don't hide file extensions
# $ext = New-Object -ComObject WScript.Shell
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name HideFileExt -Value 0

#Disable autorun
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer -Name NoDriveTypeAutorun -Value 255

# Disable Backup Notifications
# $ext.RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsBackup\DisableMonitoring","1","REG_DWORD")
Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsBackup -Name DisableMonitoring -Value 1

# Disable BitLocker Drive Encryption Service, HomeGroupListener,HomeGroupProvider,Ipv6,iSCSI,VPN,TabletInputService,Offline Files,..
Set-Service -Name BDESVC -StartupType disabled
Set-Service -Name HomeGroupListener -StartupType disabled
Set-Service -Name HomeGroupProvider -StartupType disabled
Set-Service -Name iphlpsvc -StartupType disabled
Set-Service -Name MSiSCSI -StartupType disabled
Set-Service -Name SstpSvc -StartupType disabled
Set-Service -Name SSDPSRV -StartupType disabled
# Set-Service -Name wscsvc -StartupType disabled
Set-Service -Name TabletInputService -StartupType disabled
Set-Service -Name upnphost -StartupType disabled
Set-Service -Name ehRecvr -StartupType disabled
Set-Service -Name ehSched -StartupType disabled
Set-Service -Name WwanSvc -StartupType disabled
Set-Service -Name CscService -StartupType disabled

#Disables User Access Control (UAC)
#Set-ItemProperty -path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name EnableLUA -Value 0

#Turn off Default Network Location Dialogue
New-Item HKLM:\System\CurrentControlSet\Control\Network\NewNetworkWindowOff

#Run winrm quickconfig defaults
echo Y | winrm quickconfig

#Run enable psremoting command with defaults
enable-psremoting -force

#Enabled Trusted Hosts for Universal Access
cd wsman:\localhost\client
Set-Item TrustedHosts * -force
restart-Service winrm












