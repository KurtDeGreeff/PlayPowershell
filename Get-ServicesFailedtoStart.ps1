<#
	.Synopsis
		Script to get list of services failed to start after server reboot
	.Description
		Script to get list of services failed to start after server reboot.
	.Parameter ComputerName
		Name(s) of computers which you want to examine for service startup failures
	.Example
		Get-ServicesFiledToStart.ps1 -ComputerName Server1
		This will query list of services failed to start after server reboot
	.Output
		PS C:\Scripts> .\Get-ServicesFailedtoStart.ps1 | ft -AutoSize

		Name         startmode state   exitcode Message
		----         --------- -----   -------- -------
		BlueSoleilCS Auto      Stopped     1067 The process terminated unexpectedly.
		UI0Detect    Manual    Stopped        1 Incorrect function.
	.Notes
		Author : Sitaram Pamarthi
		WebSite: http://techibee.com
		twitter: https://www.twitter.com/pamarths
		Facebook: https://www.facebook.com/pages/TechIbee-For-Every-Windows-Administrator/134751273229196

#>
[cmdletbinding()]
Param(
[string[]]$ComputerName = $env:ComputerName
)

foreach($Computer in $ComputerName) {
	if(Test-Connection -Computer $Computer -Count 1 -quiet) {
		try {
			$services = Get-WMIObject -Class Win32_Service -Filter "State='Stopped'" -ComputerName $Computer -EA stop
			foreach($service in $services) {
				if(!(($service.exitcode -eq 0) -or ($service.exitcode -eq 1077))) {
					$Error = Invoke-Expression "net helpmsg $($service.Exitcode)"
					$Service | select Name, Startmode, State, Exitcode,@{Label="Message";Expression={$Error[1]}}
				}
			}
		} catch {
			Write-Verbose "Failed to query service status. $_"
		}
	} else {
		Write-Verbose "$Computer : OFFLINE"
	}
}