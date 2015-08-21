##############################################################################
#  Script: Get-Loaded-Classes.ps1
#    Date: 16.May.2007
# Version: 1.0
#  Author: Jason Fossen (www.WindowsPowerShellTraining.com)
# Purpose: To see a list of all the classes from all the assemblies 
#          currently loaded into PowerShell:
#   Legal: Script provided "AS IS" without warranties or guarantees of any
#          kind.  USE AT YOUR OWN RISK.  Public domain, no rights reserved.
##############################################################################


Function Get-Loaded-Classes {
    [System.AppDomain]::CurrentDomain.GetAssemblies() | 
    foreach-object { $_.GetExportedTypes() } | 
    select-object fullname,assembly
}


get-loaded-classes | format-list


