##############################################################################
#  Script: IIS-Administration-Samples.ps1
#    Date: 12.Jun.2008
# Version: 1.0
#  Author: Jason Fossen (www.WindowsPowerShellTraining.com)
# Purpose: Just shows some commands for IIS7 or later.
#   Notes: Sometimes you'll need to re-create the ServerManager class object
#          ($iis) to refresh its references to dynamic items like worker 
#          processes.  Also, some objects have formatting issues where running
#          the script raises errors, but pasting the same commands into the
#          shell does not evoke those errors...
#   Legal: Script provided "AS IS" without warranties or guarantees of any
#          kind.  USE AT YOUR OWN RISK.  Public domain, no rights reserved.
##############################################################################


# Load the Microsoft.Web.Administration assembly to get the ServerManager class: 
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.Web.Administration") 

# The ServerManager class provides access to the entire IIS configuration: 
$iis = new-object Microsoft.Web.Administration.ServerManager 


# List application pool details:
$iis.ApplicationPools | format-table Name,ManagedPipelineMode,State 

 # List web sites:
$iis.Sites | format-table Name,State -auto

# List web sites and some of their logging details:
$iis.Sites | foreach-object {$_.Name ; $_.LogFile | format-table Enabled,Period,LogFormat,Directory -auto }

# Restart all currently stopped sites:
$iis.Sites | where-object {$_.State -eq "Stopped"} | foreach-object {$_.Start()} 

# List currently running worker processes:
$iis.WorkerProcesses | format-table AppPoolName,ProcessID -auto



