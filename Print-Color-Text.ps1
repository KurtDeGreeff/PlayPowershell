##############################################################################
#  Script: Print-Color-Text.ps1
#    Date: 16.May.2007
# Version: 1.0
#  Author: Jason Fossen (www.WindowsPowerShellTraining.com)
# Purpose: Demo how to change color of text or background in the shell, to
#          change the titlebar text, or to produce the system beep sound.
#   Legal: Script provided "AS IS" without warranties or guarantees of any
#          kind.  USE AT YOUR OWN RISK.  Public domain, no rights reserved.
##############################################################################


# Here are the available colors for use in the shell:

$AvailableColors = @"
Blue
Green
Cyan
Red
Magenta
Yellow
White
Black
DarkBlue
DarkGreen
DarkCyan
DarkRed
DarkMagenta
DarkYellow
Gray
DarkGray
"@

$Colors = $AvailableColors.Split("`n")
clear-host  


# To change the default foreground and/or background colors for the shell:

ForEach ($Color in $Colors) {
    [System.Console]::Set_BackgroundColor($Color)
    [System.Console]::Set_ForegroundColor("White")
    Clear-Host
    "`n`nYou can change the foreground or background colors"
    Start-Sleep -milliseconds 500
}


# To reset your foreground and background colors to their defaults:

[System.Console]::ResetColor()
Clear-Host


# To change the foreground and/or the background color of text:

ForEach ($Color in $Colors) {
    Write-Host "This color is $Color" -foregroundcolor $Color
    Write-Host "Or change the background for each line" -backgroundcolor $Color
}


# To mix different colors of text on a single line (-NoNewLine):

ForEach ($Color in $Colors) {
    Write-Host "One Line Many Colors! " -ForeGroundColor $Color -backgroundcolor "Black" -NoNewLine
}


# To change the text in the shell's titlebar:

[System.Console]::Set_Title("Monad Binad Trinad")


# To make your computer say "Beep!"

[System.Console]::Beep()


# To disable the beep.sys device driver:
#   sc.exe stop beep
#   sc.exe config beep start= disabled



