<#
.SYNOPSIS
   This script creates a shortcut to Notepad on the Desktop
.DESCRIPTION
   This script creates a Wscript.shell item, then creates 
   a shortcut on the desktop to Notepad.exe.
.NOTES
    File Name  : New-Shortcut.ps1
    Author     : Thomas Lee - tfl@psp.co.uk
    Requires   : PowerShell Version 2.0
.LINKS
    This post is a re-implementation of an MSDN Script
        http://msdn.microsoft.com/en-us/library/0ea7b5xe%28VS.85%29.aspx
    Posted to Powershell Scripts Blog
        HTTP://Pshscripts.blogspot.com
.EXAMPLE
   Left as an exercise for the reader
#>

# create wscript object
$WshShell = New-Object -com WScript.Shell

#Get Desktop location
$Desktop  = $WshShell.SpecialFolders.item("Desktop")

# create a new shortcut
$ShellLink                  = $WshShell.CreateShortcut($Desktop + "\Shortcut Script.lnk")
$ShellLink.TargetPath       = $WScript.ScriptFullName
$ShellLink.WindowStyle      = 1
$ShellLink.Hotkey           = "CTRL+SHIFT+F"
$ShellLink.IconLocation     = "notepad.exe, 0"
$ShellLink.Description      = "Shortcut Script"
$ShellLink.WorkingDirectory = $Desktop

#Save the link to the desktop
$ShellLink.Save()
