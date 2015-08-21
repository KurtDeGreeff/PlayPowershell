<# 
This script stops the service, then waits for the service to stop before continuing with the reboot/shutdown 
The scritp can be pushed to a server/Pc using Group Policy or Registry or run manually.
The shutdown script Registry key is:
	HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\State\Machine\Scripts\Shutdown\

#>
# type the name of the service in the quotes here
$ServiceName = 'Service Name'

Stop-Service $ServiceName
write-host $ServiceName'...' -NoNewLine
$TestService = Get-Service  $Service | Select-Object 'Status'
While($TestService | where {$_.Status -eq 'Running'}){	
	Write-Host '.'-NoNewLine 
	Sleep 2	
	}
	
# If you want to shutdown the computer add the command "Shutdown /t 0" (without quoutes)onto the bottom line.
# If you want to Reboot the computer then add the command "Restart-computer" (without quotes) on the line below.