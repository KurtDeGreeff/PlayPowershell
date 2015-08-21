##############################################################################
#  Script: Find_Big_Files.ps1
#    Date: 15.May.2007
# Version: 1.0
#  Author: Jason Fossen (www.WindowsPowerShellTraining.com)
# Purpose: Selects files by size and sorts from largest to smallest.
#   Notes: "MB" is built-in PowerShell shorthand for "1024 * 1024"
#   Legal: Script provided "AS IS" without warranties or guarantees of any
#          kind.  USE AT YOUR OWN RISK.  Public domain, no rights reserved.
##############################################################################

param ([String] $location = $pwd, [Int] $sizeMB = 5, [String] $filter = "*")

get-childitem $location -recurse -filter $filter | 
    where-object { $_.length -ge ($sizeMB * 1MB) } | 
    sort-object -desc length


