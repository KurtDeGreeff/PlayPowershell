@ECHO OFF

REM *************************************************************************
REM
REM  This batch script is OPTIONAL, it's just a convenience if you want to follow along.
REM
REM  This script will do the following:
REM      1) change your default Windows Script Host to CSCRIPT.EXE
REM      2) put "CMD" on your folder context menus in Explorer
REM      3) change Explorer to show file extensions
REM      4) change Explorer to always show filename extensions on scripts specifically
REM      5) enable automatic filename completion with the tab key
REM	 6) show full paths in Windows Explorer (and other similar changes).
REM      7) put "PowerShell" on your folder context menus in Explorer
REM      8) disable the system beep driver.
REM *************************************************************************



cscript.exe //h:cscript //nologo //s

regedit.exe /s Put_PowerShell_On_Folder_Context_Menu.reg 
regedit.exe /s Put_CMD_On_Folder_Context_Menu.reg
regedit.exe /s Dont_Hide_File_Extensions.reg
regedit.exe /s Always_Show_Extensions_On_Scripts.reg
regedit.exe /s Enable_Unix-Style_Filename_Completion.reg
regedit.exe /s Windows_Explorer_Annoyances.reg
regedit.exe /s Software_Restriction_Policies_Basic_User.reg

sc.exe stop beep
sc.exe config beep start= disabled


