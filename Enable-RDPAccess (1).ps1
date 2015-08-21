[cmdletbinding()]
param(
	[parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
	[string[]]$ComputerName = $env:computername,
	[ValidateScript({Test-Path $_})]
	[string]$OutFolder = "c:\"
)

begin {
$SuccessComps = Join-Path $OutFolder "Successcomps.txt"
$FailedComps = Join-Path $OutFolder "FailedComps.txt"
}

process {
	foreach($Computer in $ComputerName) {
		if(!(Test-Connection -Computer $Computer -Count 1 -ea 0)) {
			Write-Host "$Computer : OFFLINE"
			"$Computer : OFFLINE" | Out-File -FilePath $FailedComps -Append
			Continue
		}
		
		try {
			$RDP = Get-WmiObject -Class Win32_TerminalServiceSetting `
								-Namespace root\CIMV2\TerminalServices `
								-Computer $Computer `
								-Authentication 6 `
								-ErrorAction Stop
								
		} catch {
			Write-Host "$Computer : WMIQueryFailed"
			"$Computer : WMIQueryFailed" | Out-File -FilePath $FailedComps -Append
			continue
		}
		
		if($RDP.AllowTSConnections -eq 1) {
			Write-Host "$Computer : RDP Already Enabled"
			"$Computer : RDP Already Enabled" | Out-File -FilePath $SuccessComps -Append
			continue
		} else {
			try {
				$result = $RDP.SetAllowTsConnections(1,1)
				if($result.ReturnValue -eq 0) {
					Write-Host "$Computer : Enabled RDP Successfully"
					"$Computer : RDP Enabled Successfully" | Out-File -FilePath $SuccessComps -Append
				} else {
					Write-Host "$Computer : Failed to enabled RDP"
					"$Computer : Failed to enable RDP" | Out-File -FilePath $FailedComps -Append

				}
			
			} catch {
				Write-Host "$computer : Failed to enabled RDP"
				"$Computer : Failed to enable RDP" | Out-File -FilePath $FailedComps -Append
			}
		}
	}

}

end {}