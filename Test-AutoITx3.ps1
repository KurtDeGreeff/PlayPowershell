#Requires -modules AutoItX3
CLS
 
# Import the module manfiest
Import-Module (${Env:ProgramFiles(x86)} + "\AutoIt3\AutoItX\AutoItX3.psd1")
 
Invoke-AU3Run("Notepad")
 
Wait-AU3WinActive("Untitled")
 
Send-AU3Key("I'm in notepad");
 
$winHandle = Get-AU3WinHandle("Untitled");
 
Sleep -Seconds 2
 
Close-AU3Win($winHandle)
 
# Get the list of AutoItX cmdlets
Get-Command *AU3*
 
# Get detailed help for a particular cmdlet
Get-Help Get-AU3WinHandle