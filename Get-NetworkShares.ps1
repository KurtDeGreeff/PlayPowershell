[cmdletbinding()]
param(
	[parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
	[string[]]$ComputerName = $env:computername,
	[string]$OutputDir
)

begin {$OutputArray = @()}

process {
	foreach($Computer in $ComputerName) {
		$OutputObj = New-Object –TypeName PSObject –Prop (@{
				'ComputerName'=$Computer.ToUpper();
				'ShareName' = $null;
                'Status'=$null;
                'EveryOneFullControl'=$false
			})
	
	
		Write-Verbose "Working on $Computer"
		if(!(Test-Connection -Computer $Computer -Count 1 -Ea 0)) {
			Write-Verbose "$Computer is offline"
			$OutputObj = New-Object –TypeName PSObject –Prop (@{
				'ComputerName'=$Computer.ToUpper();
				'ShareName' = $null;
                'Status'="OFFLINE";
                'EveryOneFullControl'=$null
			})
			$OutputObj
			$OutputArray +=$OutputObj
			
			Continue
		}
		
		try {
			$Shares = Get-WmiObject -Class Win32_LogicalShareSecuritySetting `
									-ComputerName $Computer `
									-ErrorAction Stop
			$Status = "Successful"						
		} catch {
			Write-Verbose "Failed to Query WMI class. More details: $_"
			$OutputObj = New-Object –TypeName PSObject –Prop (@{
				'ComputerName'=$Computer.ToUpper();
				'ShareName' = $null;
                'Status'="WMIFailed";
                'EveryOneFullControl'=$null
			})
			
			$OutputObj
			$OutputArray +=$OutputObj
			
			Continue
		}
		
		foreach($Share in $Shares) {
			$OutputObj = New-Object –TypeName PSObject –Prop (@{
				'ComputerName'=$Computer.ToUpper();
				'ShareName' = $Share.Name;
                'Status'=$Status;
                'EveryOneFullControl'=$false
			})
			$OutputObj.ShareName = $Share.Name
			$Permissions = $Share.GetSecurityDescriptor()
			foreach($perm in $Permissions.Descriptor.DACL) {
				if($Perm.Trustee.Name -eq "EveryOne" -and $Perm.AccessMask -eq "2032127" -and $Perm.AceType -eq 0) {
					$OutputObj.EveryOneFullControl = $true
				} else {
				
				}
			}
		$OutputObj
		$OutputArray +=$OutputObj
		}
	}
	
}


end {
	if($OutputDir) {
		$File = Join-Path $OutputDir ("SharePermissions {0}.log" -f $(Get-Date -Format("MMddyyyyHHmmss")))
		$File
		$OutputArray | ? {$_.EveryOneFullControl}| % {
			"\\{0}\{1}" -f $_.ComputerName, $_.ShareName | Out-File -FilePath $File -Force
		}
	}

}