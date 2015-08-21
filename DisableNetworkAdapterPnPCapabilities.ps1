
#requires -Version 2.0

Function Disable-OSCNetAdapterPnPCapabilities
{
	#find only physical network,if value of properties of adaptersConfigManagerErrorCode is 0,  it means device is working properly. 
	#even covers enabled or disconnected devices.
	#if the value of properties of configManagerErrorCode is 22, it means the adapter was disabled. 
	$PhysicalAdapters = Get-WmiObject -Class Win32_NetworkAdapter|Where-Object{$_.PNPDeviceID -notlike "ROOT\*" `
	-and $_.Manufacturer -ne "Microsoft" -and $_.ConfigManagerErrorCode -eq 0 -and $_.ConfigManagerErrorCode -ne 22} 
	
	Foreach($PhysicalAdapter in $PhysicalAdapters)
	{
		$PhysicalAdapterName = $PhysicalAdapter.Name
		#check the unique device id number of network adapter in the currently environment.
		$DeviceID = $PhysicalAdapter.DeviceID
		If([Int32]$DeviceID -lt 10)
		{
			$AdapterDeviceNumber = "000"+$DeviceID
		}
		Else
		{
			$AdapterDeviceNumber = "00"+$DeviceID
		}
		
		#check whether the registry path exists.
		$KeyPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002bE10318}\$AdapterDeviceNumber"
		If(Test-Path -Path $KeyPath)
		{
			$PnPCapabilitiesValue = (Get-ItemProperty -Path $KeyPath).PnPCapabilities
			If($PnPCapabilitiesValue -eq 24)
			{
				Write-Warning """$PhysicalAdapterName"" - The option ""Allow the computer to turn off this device to save power"" has been disabled already."
			}
			If($PnPCapabilitiesValue -eq 0)
			{
				#check whether change value was successed.
				Try
				{	
					#setting the value of properties of PnPCapabilites to 24, it will disable save power option.
					Set-ItemProperty -Path $KeyPath -Name "PnPCapabilities" -Value 24 | Out-Null
					Write-Host """$PhysicalAdapterName"" - The option ""Allow the computer to turn off this device to save power"" was disabled."
				}
				Catch
				{
					Write-Host "Setting the value of properties of PnpCapabilities failed." -ForegroundColor Red
				}
			}
			If($PnPCapabilitiesValue -eq $null)
			{
				Try
				{
					New-ItemProperty -Path $KeyPath -Name "PnPCapabilities" -Value 24 -PropertyType DWord | Out-Null
					Write-Host """$PhysicalAdapterName"" - The option ""Allow the computer to turn off this device to save power"" was disabled."
				}
				Catch
				{
					Write-Host "Setting the value of properties of PnpCapabilities failed." -ForegroundColor Red
				}
			}
		}
		Else
		{
			Write-Warning "The path ($KeyPath) not found."
		}
	}
}

Disable-OSCNetAdapterPnPCapabilities