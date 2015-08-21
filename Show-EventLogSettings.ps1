##############################################################################
#  Script: Show-EventLogSettings.ps1
#    Date: 21.May.2007
# Version: 1.0
#  Author: Jason Fossen (www.WindowsPowerShellTraining.com)
# Purpose: Simply dumps config settings for the local event logs.
#   Legal: Script provided "AS IS" without warranties or guarantees of any
#          kind.  USE AT YOUR OWN RISK.  Public domain, no rights reserved.
##############################################################################

get-eventlog -list | 
format-table LogDisplayName,MaximumKilobytes,OverFlowAction,MinimumRetentionDays -auto

