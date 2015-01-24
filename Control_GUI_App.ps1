##############################################################################
#  Script: Control_GUI_App.ps1
#    Date: 27.Mar.2007
# Version: 2.0
#  Author: Jason Fossen (www.WindowsPowerShellTraining.com)
# Purpose: Demos use of SendKeys(), Start-Sleep, and AppActivate().
#   Legal: Script provided "AS IS" without warranties or guarantees of any
#          kind.  USE AT YOUR OWN RISK.  Public domain, no rights reserved.
##############################################################################


# Create the famous oWshShell object used in many VBScripts.
$oWshShell = New-Object -COMobject "WScript.Shell" -Strict 2>$Null


# Delete the exported file from last time...(housecleaning)
Remove-Item "$env:userprofile\desktop\EventLog.evt" 2>$Null


# Launch the MMC snap-in for Event Viewer.
Invoke-Expression "$Env:SystemRoot\system32\eventvwr.msc /s"


# Make the script pause for two seconds to let the snap-in show.
# If you try to send keystrokes to an application that has not yet fully 
# launched, the application will simply miss the keystrokes.
Start-Sleep -seconds 2


# Though Event Viewer should be in the foreground, this helps to ensure it.
# AppActivate() looks for the exact titlebar name of a running application and
# then brings that application to the foreground and gives it the focus.
# You can use this method to switch between different applications.  You can also
# give AppActivate() a process ID number (PID) to bring to the foreground.  
$Result = $oWshShell.AppActivate("Event Viewer")


# Now send keystrokes to Event Viewer.  The Start-Sleep commands are not really needed,
# but slowing the execution down a bit makes the demo look better!
  
$oWshShell.SendKeys("{PGUP}")     # Hit Page Up key to put focus at top of tree.
$oWshShell.SendKeys("{DOWN}")     # Hit the down-arrow key.
Start-Sleep -milliseconds 400
$oWshShell.SendKeys("{DOWN}")
Start-Sleep -milliseconds 400
$oWshShell.SendKeys("{DOWN}")
Start-Sleep -milliseconds 400
$oWshShell.SendKeys("%A")         # Hit Alt-A for the Action menu.
Start-Sleep -milliseconds 400
$oWshShell.SendKeys("{DOWN}")
Start-Sleep -milliseconds 400
$oWshShell.SendKeys("{ENTER}")    # Hit Enter key.
Start-Sleep -milliseconds 400
$oWshShell.SendKeys("$env:userprofile\desktop\EventLog.evt")
Start-Sleep -seconds 2
$oWshShell.SendKeys("{TAB}")      # Tab over to Save button.
Start-Sleep -milliseconds 400
$oWshShell.SendKeys("{TAB}")
Start-Sleep -milliseconds 400
$oWshShell.SendKeys("{ENTER}")
Start-Sleep -milliseconds 500
$oWshShell.SendKeys("%{F4}")      # Alt-F4 closes the MMC window.


# Now just to do something fun....  But also notice that parentheses (()), the
# tilde character (~), the percentage sign (%), the power sign (^), and the plus
# sign (+) must be placed inside of curly brackets into order to be sent to the
# application because these characters are meaningful to the SendKeys() method.
notepad.exe
Start-Sleep -seconds 1

# And, again, the following Sleep commands are just for effect.  Otherwise, the
# picture would show up so fast as to appear to have been from a file that was opened.
$Result = $oWshShell.AppActivate("Untitled")
$oWshShell.SendKeys("{ENTER}")
$oWshShell.SendKeys("        /\_/\")
Start-Sleep -milliseconds 400
$oWshShell.SendKeys("{ENTER}")
$oWshShell.SendKeys("       / 0 0 \")
Start-Sleep -milliseconds 400
$oWshShell.SendKeys("{ENTER}")
$oWshShell.SendKeys("      ====v====")
Start-Sleep -milliseconds 400
$oWshShell.SendKeys("{ENTER}")
$oWshShell.SendKeys("       \  W  /")
Start-Sleep -milliseconds 400
$oWshShell.SendKeys("{ENTER}")
$oWshShell.SendKeys("       |     |     _")
Start-Sleep -milliseconds 400
$oWshShell.SendKeys("{ENTER}")
$oWshShell.SendKeys("       / ___ \    /")
Start-Sleep -milliseconds 400
$oWshShell.SendKeys("{ENTER}")
$oWshShell.SendKeys("      / /   \ \  |")
Start-Sleep -milliseconds 400
$oWshShell.SendKeys("{ENTER}")
$oWshShell.SendKeys("     {(}{(}{(}-----{)}{)}{)}-'") # Notice the curly brackets.
Start-Sleep -milliseconds 400
$oWshShell.SendKeys("{ENTER}")
$oWshShell.SendKeys("     /         \")
Start-Sleep -milliseconds 400
$oWshShell.SendKeys("{ENTER}")
$oWshShell.SendKeys("     {(}      ___{)}") # More curly brackets.
Start-Sleep -milliseconds 400
$oWshShell.SendKeys("{ENTER}")
$oWshShell.SendKeys("      \__.=|___E")
Start-Sleep -milliseconds 400
$oWshShell.SendKeys("{ENTER}")
$oWshShell.SendKeys("             /")
$oWshShell.SendKeys("{ENTER}")
Start-Sleep -seconds 2
$oWshShell.SendKeys("%{F4}")  # To close Notepad.
$oWshShell.SendKeys("%N")     # To say No to saving.


# The following is the syntax for sending special keystrokes with SendKeys().
# Shift Key      +
# Ctrl Key       ^
# Alt Key        %
# Backspace      {BACKSPACE}, {BS} or {BKSP}
# Break          {BREAK}
# Caps Lock      {CAPSLOCK}
# Delete         {DELETE} or {DEL}
# Cursor Up      {UP}
# Cursor Down    {DOWN}
# Cursor Right   {RIGHT}
# Cursor Left    {LEFT}
# End            {END}
# Enter          {ENTER} or ~
# Esc            {ESC}
# Home           {HOME}
# Insert         {INSERT} or {INS}
# Num Lock       {NUMLOCK}
# Page Down      {PGDN}
# Page Up        {PGUP}
# Scroll Lock    {SCROLLOCK}
# Tab            {TAB}
# F1, F2, F3...  {F1}, {F2}, {F3}...
# 
# To close a program, use Alt-F4 = %{F4}
# 
# To access menu commands, look for the underlined letters on the menus, then
# enter Alt-letter, e.g., %F to pull down the File menu, then %X to Exit.
# 
# Note: It's not possible to script Ctrl-Alt-Del.
# 
# To hold down one key and press others, the symbol for the held key should
# be followed with parentheses in which the other keys should be listed.  For 
# example, to send Shift-A-B, enter +(AB), or to send Alt-C-D-E, enter %(CDE).
# 
# To repeat a keystroke multiple times, inside curley brackets place the keystroke,
# a space character, and the multiple number.  For example, to enter the letter R
# tenty times, use {R 20}.


# END OF SCRIPT ****************************************************************
