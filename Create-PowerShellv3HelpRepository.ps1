<########################################################################################

Name		:	Create-PowerShellv3HelpRepository.ps1
Date		:	January 3rd 2013
Author		:	Bjorn Houben
Blog        :   http://blog.bjornhouben.com
Website		:	http://www.bjornhouben.com
Linkedin	:	http://nl.linkedin.com/in/bjornhouben

Purpose		:   With PowerShell v3, not all help is included. Instead it needs to be downloaded from the internet.
                When no internet access is available (or desirable) and you want to save bandwidth you can create a local repository.

                This script creates the local PowerShell v3 Help Repository and creates a scheduledjob to update it daily.

Assumptions	:	
                

Known issues:	Created scheduled job is configured to run as the user that ran the script. Change manually if desired.

Limitations	:	

Notes   	:   -Based on the blog post : http://learn-powershell.net/2012/06/29/setting-up-a-windows-powershell-help-repository/
                
                -A file named "1. Update Command To Run on Systems to update PowerShell Help.ps1" is placed in the share as well that contains
                command you need to run on systems you want to update so you only have to browse to the share if you want to perform a manual update.

                -Consider deploying a GPO containing a scheduled task to update PowerShell v3 Help on a regular basis for all systems.
                http://technet.microsoft.com/en-us/library/cc725745.aspx
                This way you also don't have to wait for the updated PowerShell v3 Help fles to be downloaded when you need them.


Disclaimer	:	This script is provided AS IS without warranty of any kind. I disclaim all implied warranties including, without limitation,
			    any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or
			    performance of the sample scripts and documentation remains with you. In no event shall I be liable for any damages whatsoever
			    (including, without limitation, damages for loss of business profits, business interruption, loss of business information,
			    or other pecuniary loss) arising out of the use of or inability to use the script or documentation. 

To improve  :	Automatically create scheduled job that runs as NT AUTHORITY/SYSTEM

Copyright   :   I believe in sharing knowledge, so this script and its use is subject to : http://creativecommons.org/licenses/by-sa/3.0/

History     :	Januari 3 2013	:	Created script
 
########################################################################################>


#Declare variables
$DesiredPowerShellHelpFolderDrive = "C:"
$DesiredPowerShellHelpFolderName = "PowerShellHelp"
$DesiredPowerShellHelpShareName = "PowerShellHelp"
$ShareFullAccessGroup = "Administrators"
$ShareReadAccessGroup = "Everyone"
$Scheduledjobname = "Update-PowerShellHelp"

#Start of script
$DesiredPowerShellHelpFolderFullPath = $DesiredPowerShellHelpFolderDrive + "\" + $DesiredPowerShellHelpFolderName
$updatecommandfile = $DesiredPowerShellHelpFolderFullPath + "\" + "1. Update Command To Run on Systems to update PowerShell Help.ps1" 

IF((Test-Path -path $DesiredPowerShellHelpFolderFullPath -ErrorAction SilentlyContinue) -ne $TRUE) #Create the repository folder if it does not exist
{
    New-Item -Path $DesiredPowerShellHelpFolderDrive -Name $DesiredPowerShellHelpFolderName -ItemType Directory
}


IF((Get-SmbShare -name $DesiredPowerShellHelpShareName -ErrorAction SilentlyContinue) -eq $NULL) #Create the share if it does not exist
{
    New-SmbShare –Name $DesiredPowerShellHelpShareName –Path $DesiredPowerShellHelpFolderFullPath –FullAccess $ShareFullAccessGroup –ReadAccess $ShareReadAccessGroup
}


#Download the help files to the new share initially
Save-Help -DestinationPath $sharename -Module * -Force -ErrorAction SilentlyContinue

#Create a job to daily download update PowerShell Help
#PowerShell scheduled jobs are stored in Task Scheduler in: Task Scheduler Library\Microsoft\Windows\PowerShell\Scheduled Jobs 
$trigger = New-JobTrigger -Daily -At 10:05pm
IF((Get-ScheduledJob -name $Scheduledjobname -ErrorAction SilentlyContinue) -eq $NULL) #If scheduledjob does not exist, create it.
{
    #Create the scheduledjob
    #Beware that the current credentials will be used to run the scheduled task. If you want to use another account use -credential parameter of change afterwards
    Register-ScheduledJob -Name $Scheduledjobname -Trigger $trigger -ScriptBlock {Save-Help -DestinationPath $sharename -Module * -Force -ErrorAction SilentlyContinue}
}

#Determine the sharename
$fqdn = [System.Net.Dns]::GetHostByName(($env:computerName)).Hostname
$sharename = "\\" + $fqdn + "\" + $DesiredPowerShellHelpFolderName

#Get updated help manually from a client by running:
write-host "Get updated help from a client by running:"
write-host "Update-Help -Module * -SourcePath $sharename -Force -ErrorAction SilentlyContinue"
"Update-Help -Module * -SourcePath $sharename -Force -ErrorAction SilentlyContinue" | out-file -filepath $updatecommandfile -Force

#Consider deploying a GPO containing a scheduled task to update PowerShell Help v3 on a regular basis.
#http://technet.microsoft.com/en-us/library/cc725745.aspx


<#
#Undo changes by running the selection below

#Remove registeredjob
Get-ScheduledJob -name $Scheduledjobname | unregister-scheduledjob

#Remove share
Get-SmbShare -name $DesiredPowerShellHelpShareName | remove-smbshare

#Remove folder
remove-item $DesiredPowerShellHelpFolderFullPath -Recurse -Force

#>