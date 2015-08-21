##############################################################################
#  Script: Get-Constructor-Hints.ps1
#    Date: 16.May.2007
# Version: 1.0
#  Author: Jason Fossen (www.WindowsPowerShellTraining.com)
# Purpose: Show information about the possible arguments to .NET constructors.
#          Pass in the name of a .NET class, such as "System.String", and
#          some crudely-formatted "help" is shown.
#   Legal: Script provided "AS IS" without warranties or guarantees of any
#          kind.  USE AT YOUR OWN RISK.  Public domain, no rights reserved.
##############################################################################


Function Get-Constructor-Hints ($classname) {
    $command = "[$classname]" + '.GetConstructors() | foreach-object { $_.getparameters() } | select-object  name,member' 
    invoke-expression $command
}

Get-Constructor-Hints $args[0] | format-table -autosize

