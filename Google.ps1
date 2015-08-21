##############################################################################
#  Script: Google.ps1
#    Date: 25.Jun.2007
# Version: 1.0
#  Author: Jason Fossen (www.WindowsPowerShellTraining.com)
# Purpose: Pops up Internet Explorer to Google and performs search on
#          the word(s) passed in as arguments (or Firefox).  
#   Legal: Script provided "AS IS" without warranties or guarantees of any
#          kind.  USE AT YOUR OWN RISK.  Public domain, no rights reserved.
#          Google is a registered trademark of Google Inc.
##############################################################################


function google
{
    # If you want to use Firefox, edit and uncomment next two lines:
    # C:\'Program Files'\'Mozilla Firefox'\firefox.exe http://www.google.com/search?q=$args
    # return  #Function exits, IE is not launched.

    $IE = new-object -com "InternetExplorer.Application"
    $IE.navigate2("http://www.google.com/search?q=$args")
    $IE.Left = 50
    $IE.Top = 50
    $IE.Width = 974
    $IE.Height = 718
    $IE.visible = $True
    $WshShell = new-object -com "WScript.Shell" 
    $Result = $WshShell.AppActivate("Windows Internet Explorer")
}

google "$args"



