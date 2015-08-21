<#Update Offline Virtual Machine with PowerShell and WSUS Offline Update
Source: http://goo.gl/w1nDPE
Within the folder structure is a folder called Client. 
This is the structure we need to expose to our offline virtual machines. 
The process we’re going to follow will be very simple:

Create a VHD file structure
Mount the VHD file
Partition and format the VHD file
Copy the folder structure to the VHD file
Dismount the VHD file
The following process is repeated for each virtual machine you supply:

Get a list of virtual machines that are off.
Attach the VHD file to the virtual machines, one at a time.
Inject a setting to launch a script into the virtual machine Registry.
Temporarily adjust the Registry to automatically log in as a user with local Admin rights.
Temporarily disable the User Account Control (UAC).
Temporarily change the Windows PowerShell execution policy.
Inject a small script to identify our VHD and launch the update script.
Power up the virtual machine and wait for it to update, then shut down automatically.
Remove the WSUS Offline Updates VHD.
Power up the virtual machine and leave it running for about two hours to allow it to process the updates.
Power down after the allocated time period.
We do this until we’ve run out of virtual machines that we want to patch...#>

# Create the VHD file
$VHDPath=’C:\WsusOffline\Updates.VHDX’
New-VHD $VHDPath -SizeBytes 20GB -Dynamic

# Attach the VHD to the Windows File system
Mount-VHD $VHDPath

# Partition the VHD
$VHD=Get-VHD $VHDPath | Get-Disk
$Drive=$VHD | Initialize-Disk -PartitionStyle MBR –PassThru |
New-Partition –AssignDriveLetter –UseMaximumSize |
Format-Volume –FileSystem NTFS –NewFileSystemLabel ‘WSUSOffline’ –Confirm:$false

# copy the folder structure
Copy-Item -path 'C:\wsusoffline\client' -Recurse -destination (“$($Drive.DriveLetter):\client”) -Force

Dismount-VHD $VHDPath
$Drive=Get-Volume | where { $_.FileSystemLabel -eq 'WSUSOffline' }
$Appname="$($Drive.Driveletter):\client\cmd\doupdate.cmd"
invoke-expression $appname
stop-computer

$VMlist=Get-VM | Where { $_.State –eq 'Off' }
Foreach ($VM in $VMlist)
{
# Get virtual machine Name
$VMName=$VM.VMName

# Get the location of the VHD
$VMDiskPath=(Get-VM $VMName | Get-VMHardDiskDrive).Path

# Mount the VHD and get it's Drive letter
Mount-DiskImage $VMDiskPath
$DriveLetter=((Get-DiskImage $VMDiskpath | get-disk | get-partition | Where { $_.Type -eq 'Basic' }).DriveLetter)+":"

# Then create a folder to hold our autolaunch Script
$ScriptFolder=$DriveLetter+"\ProgramData\Scripts\"
New-Item $ScriptFolder -ItemType Directory -force

# Copy over our little PowerShell script to trigger to update media
Copy-Item "C:\Wsusoffline\UpdatePC.PS1" $ScriptFolder
}

# Connect to the Registry remotely and grab some settings
$RemoteReg=$DriveLetter+"\Windows\System32\config\Software"

# Load the remote file registry
REG LOAD 'HKLM\REMOTEPC' $RemoteReg

# Capture the original properties for Autologin
$Key='HKLM:\REMOTEPC\Microsoft\Windows NT\CurrentVersion\Winlogon'
$Admin=(Get-ItemProperty $KEY -name AutoAdminLogon -ErrorAction SilentlyContinue).AutoAdminLogon
$Domain=(Get-ItemProperty $KEY -name DefaultDomainName -ErrorAction SilentlyContinue).DefaultDomainName
$Username=(Get-ItemProperty $KEY -name DefaultUserName -ErrorAction SilentlyContinue).DefaultUserName
$Password=(Get-ItemProperty $KEY -name DefaultPassword -ErrorAction SilentlyContinue).DefaultPassword

# Then pass in the new values which presume all
# Offline VMs have the same ID and Password for the local
# Admin account.
Set-ItemProperty $KEY -name AutoAdminLogon –value 1 -force
Set-ItemProperty $KEY -name DefaultDomainName -value 'localhost' -force
Set-ItemProperty $KEY -name DefaultUserName -Value 'Administrator' -force
Set-ItemProperty $KEY -name DefaultPassword -Value 'P@ssw0rd' -force

# We now do the same for UAC
# Capture the old settings first
$Key='HKLM:\REMOTEPC\Microsoft\Windows\CurrentVersion\Policies\System'
$ConsentAdmin=(Get-ItemProperty $KEY -name ConsentPromptBehaviorAdmin -ErrorAction SilentlyContinue). ConsentPromptBehaviorAdmin
$ConsentUser=(Get-ItemProperty $KEY -name ConsentPromptBehaviorUser -ErrorAction SilentlyContinue). ConsentPromptBehaviorUser
$LUA=(Get-ItemProperty $KEY -name EnableLUA -ErrorAction SilentlyContinue).EnableLUA
$SecureDesk=(Get-ItemProperty $KEY -name PromptOnSecureDesktop -ErrorAction SilentlyContinue).PromptOnSecureDesktop

# And now we (Quick everybody HIDE!)
# Temporarily turn off UAC!
Set-ItemProperty $KEY -name ConsentPromptBehaviorAdmin –Value 0
Set-ItemProperty $KEY -name ConsentPromptBehaviorUser –Value 0
Set-ItemProperty $KEY -name EnableLUA –Value 1
Set-ItemProperty $KEY -name PromptOnSecureDesktop –Value 0

# Capture the Current Execution Policy for PowerShell
$Key='HKLM:\REMOTEPC\Microsoft\Powershell\1\Shellids\Microsoft.Powershell'
$PowershellPolicy=(Get-ItemProperty $KEY -name ExecutionPolicy -ErrorAction SilentlyContinue). ExecutionPolicy

# Set the Execution Policy to Bypass
Set-ItemProperty $KEY -name ExecutionPolicy –Value 'Bypass'

# Finally we tell the remote computer at First run to execute the UpdatePC script.
NEW-ITEMPROPERTY "HKLM:\REMOTEPC\Microsoft\Windows\CurrentVersion\Run\" -Name "PoshStart" -Value "`"C:\windows\System32\WindowsPowerShell\v1.0\powershell.exe`" -file C:\ProgramData\Scripts\UpdatePC.PS1"

# Then disconnect the remote registry
REG UNLOAD 'HKLM\REMOTEPC'

# And now dismount the Disk
dismount-diskimage $VMDiskPath

<#We need to attach the VHD to the virtual machine. We'll do this by adding in a SCSI controller to our virtual machine and then add the VHD to that SCSI controller. We are only going to add in a new SCSI controller if none already exists.#>
# Check for total SCSI Controllers
$TotalSCSI=(GET-VMScsiController -vmname $VMName).count
Get-VM –Vmname $VMName | Add-VMScsiController

# Attach the Updates VHDX file
Get-VM –Vmname $VMName | Add-VMHarddiskDrive –Controllertype SCSI –Path $VHDPath -ControllerNumber ($TotalScsi)

<#Now that we've done all the heavy lifting, here's the easy part. Start the virtual machine, wait for its first shutdown so we can detach the VHD, and then start it one final time to allow the updates to apply:#>
# Start the virtual machine
Start-VM -vmname $VMName

# A slight for faster machines to ensure the virtual machine
# State is passed back properly first
Start-Sleep -seconds 60

# Wait until the machine has pulled in the updates
# and Stops when it's done.
Do { $status=(Get-VM –vmname $VMname).state } until ($status –match 'Off')

# Detach Updates VHD from virtual machine
Get-VM –Vmname $VMName | Remove-VMHarddiskDrive –Controllertype SCSI –Path $VHDPath
If(!$TotalSCSI) { Remove-VMScsiController -vmname $VMname -ControllerNumber 0 }

Start-VM –vmname $VMName
Start-Sleep –seconds 7200; # 60 seconds in a minute, 60 minutes in an hour times 2
Stop-VM –vmname $VMName

<#Mount the virtual machine VHD file
Restore all the settings in the virtual machine registry
Remove the Windows PowerShell script we placed on the virtual machine
Detach the VHD file#>
# Reconnect VHD to Host so we can clean the registry back up
Mount-DiskImage $VMDiskPath
$DriveLetter=((Get-DiskImage $VMDiskpath | get-disk | get-partition | Where { $_.Type -eq 'Basic' }).DriveLetter)+":"

# Remove that PowerShell script
$ScriptFolder=$DriveLetter+"\ProgramData\Scripts\"
Remove-Item $ScriptFolder -ItemType Directory –recurse -force

# Connect to the Registry remotely and grab some settings
$RemoteReg=$DriveLetter+"\Windows\System32\config\Software"

# Load the remote file registry
REG LOAD 'HKLM\REMOTEPC' $RemoteReg

# Restore the original properties for Autologin
$Key='HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon'
Set-ItemProperty $KEY -name AutoAdminLogon –value $Admin -force
Set-ItemProperty $KEY -name DefaultDomainName -value $Domain -force
Set-ItemProperty $KEY -name DefaultUserName -Value $Username -force
Set-ItemProperty $KEY -name DefaultPassword -Value $Password -force

# We now do the same for UAC
# Restore the old settings first
$Key='HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Policies\System'
Set-ItemProperty $KEY -name ConsentPromptBehaviorAdmin –Value $ConsentAdmin
Set-ItemProperty $KEY -name ConsentPromptBehaviorUser –Value $ConsentUser
Set-ItemProperty $KEY -name EnableLUA –Value $SilentlyContinue
Set-ItemProperty $KEY -name PromptOnSecureDesktop –Value $SecureDesk

# Restore the original Execution Policy
$Key='HKLM:\REMOTEPC\Microsoft\Powershell\1\Shellids\Microsoft.Powershell'
Set-ItemProperty $KEY -name ExecutionPolicy –Value $PowershellPolicy

# Then Remove the autostart for the Script
SET-ITEMPROPERTY "HKLM:\REMOTEPC\Microsoft\Windows\CurrentVersion\Run\" -Name "PoshStart" -Value $NULL

# Then disconnect the remote registry
REG UNLOAD 'HKLM\REMOTEPC'

# And now dismount the Disk
dismount-diskimage $VMDiskPath