##############################################################################
# Script Name: Use_RunDLL32.ps1
#     Version: 1.0
#      Author: Jason Fossen (www.WindowsPowerShellTraining.com)
#     Updated: 18.May.2007
#     Purpose: Will lock the desktop on Windows 2000 and later.
#       Notes: This script also demonstrates the use of RunDLL32.exe, which permits
#			   partial access to functions contained in DLL files and libraries.
#		       You have to know the name and location of the function first.
#       Legal: Script provided "AS IS" without warranties or guarantees of any
#              kind.  USE AT YOUR OWN RISK.  Public domain, no rights reserved.
##############################################################################


# This will lock the desktop.
RunDll32.exe user32.dll,LockWorkStation

# This will log the user off.
# RunDll32.exe shell32.dll,SHExitWindowsEx 0

# This will shutdown the computer.
# RunDll32.exe shell32.dll,SHExitWindowsEx 1

# This will reboot the computer.
# RunDll32.exe shell32.dll,SHExitWindowsEx 2

# This will do a forced shutdown.
# RunDll32.exe shell32.dll,SHExitWindowsEx 4

# This will power down the machine.
# RunDll32.exe shell32.dll,SHExitWindowsEx 8


