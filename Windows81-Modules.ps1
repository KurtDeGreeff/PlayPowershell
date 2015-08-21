# Windows 8.1 new modules

########################################### WindowsSearch ####################################

Get-WindowsSearchSetting
Set-WindowsSearchSetting –EnableWebResultsSetting $FALSE
Set-WindowsSearchSetting –EnableWebResultsSetting $TRUE –SafeSearchSetting Strict

########################################### Windows Defender #################################

Get-MPPreference | Export-CLIXML C:\DefenderSettings.XML

#import backup settings on a new computer
$Settings = Import-CLIXML C:\DefenderSettings.XML
Set-MPPreference –UILockdown $Settings.UILockdown
Set-MPPreference –ExclusionPath $Settings.ExclusionPath

Get-MPThreatCatalog | Format-Table
Get-MPThreatCatalog | Export-CSV C:\BadGuys.csv

Update-MPSignature
Start-MPScan

Get-MPComputerStatus

######################################### DISM #############################################

Get-WindowsImage –ImagePath D:\Sources\Install.wim

Get-WindowsOptionalFeature –online | Format-Table # Get-WindowsFeature in server versions
Enable-WindowsOptionalFeature –online –Featurename IIS-WebServerRole
Remove-WindowsOptionalFeature –online –Featurename WindowsMediaPlayer

Set-WindowsProductKey –online –productkey ‘AAAAA-BBBBB-CCCCC-DDDDD-EEEEE’

Get-WindowsEdition –online

######################################## SMBShare ##########################################

Get-Command –module SmbShare

#create a new share Data (C:\Shares\Data). Grant full access to local Administrators and change access to Users
New-Item C:\Shares\Data –itemtype directory –force
New-SMBShare –Name Data –Path C:\Shares\Data –FullAccess Administrators –ChangeAccess Users

Get-SMBShare | Get-SMBShareAccess | Sort-Object Name
Get-SMBShare | Get-SMBShareAccess | Sort-Object Name | Export-CSV C:\Folder\ShareList.csv

#add user Ernie to the Data share, and allow him Read access
Grant-SMBShareAccess –name “Data” –AccountName Ernie -AccessRight Read –force

#Revoke access to security group Accounting
Get-SMBShare | Revoke-SMBShareAccess –AccountName Accounting –force

Get-SMBOpenFile
Get-SMBOpenFile | Where { $_.Path –like ‘*ImportantFile.doc*’ }

#see the names of people who are accessing the server
Get-SMBSession | Select-object ClientUserName

# to ensure files are all disconnected 
Get-SMBOpenFile | Close-SMBOpenFile –force

#disconnecting users from a session in a share 
Get-SMBSession | Close-SMBSession –force

##################################### Print Management ###################################

Get-Printer
Get-Printer | Get-PrintConfiguration

#Get remote print jobs
Get-Printjob –Printername “Laserjet5” –computername “PrintServer”

#suspend print jobs to do maintenance
Get-Printer –name “Laserjet5” | Get-Printjob | Suspend-Printjob
Get-Printer | Get-Printjob | Suspend-Printjob

#and resume them too
Get-Printer | Get-Printjob | Resume-Printjob

#Remove defunct printer drivers
Remove-Printerdriver “Laserjet 1”

#Create printer share
Set-Printer –name “Laserjet1” –Sharename “PRINTER01” –shared $TRUE

#or even rename it
Set-Printer –name “Laserjet 1” –Sharename “AccountingPrinter01” –shared $TRUE

#################################### Scheduled Tasks #####################################

Get-Command –Module ScheduledTasks
Get-Help New-ScheduledTask –Examples
Get-Help New-ScheduledTaskTrigger –Examples
Get-ScheduledTask
Get-ScheduledTask | where { $_.State –eq ‘Disabled’ }

#find all tasks for DiskDiagnostic
Get-ScheduledTask –TaskPath \Microsoft\Windows\DiskDiagnostic\
Get-ScheduledTask –TaskPath \Microsoft\Windows\DiskDiagnostic\ | Unregister-ScheduledTask –whatif

#Get all running scheduled tasks, STOP and Disable them
$TaskList=Get-ScheduledTask | where { $_.State –eq ‘Running’ }
$TaskList | Stop-ScheduledTask
$TaskList | Disable-ScheduledTask

$TaskList | Enable-ScheduledTask
Get-ScheduledTask –TaskPath ‘\Microsoft\Windows\Multimedia\’ | Get-ScheduledTaskInfo

#Get all tasks with missed runs
Get-ScheduledTask | Get-ScheduledTaskInfo | Where { $_.NumberOfMissedRuns –gt 0 } | Format-Table –Autosize