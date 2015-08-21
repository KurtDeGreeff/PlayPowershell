##############################################################################
#  Script: Get-Loaded-Assemblies.ps1
#    Date: 16.May.2007
# Version: 1.0
#  Author: Jason Fossen (www.WindowsPowerShellTraining.com)
# Purpose: To see a list of the assemblies currently loaded into PowerShell.
#   Legal: Script provided "AS IS" without warranties or guarantees of any
#          kind.  USE AT YOUR OWN RISK.  Public domain, no rights reserved.
##############################################################################


Function Get-Loaded-Assemblies {
    [System.AppDomain]::CurrentDomain.GetAssemblies() | 
    select-object FullName,Location
}

get-loaded-assemblies | format-list



