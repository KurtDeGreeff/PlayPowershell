Installation

From PowerShell, create a $profile if you don't have one:
if (!(test-path $profile)) { new-item -path $profile -itemtype file -force }

Open the profile in notepad:
notepad.exe $profile

Add the following line and save the file:
. /path/to/sudo.ps1

sudo will be available in all new PowerShell windows