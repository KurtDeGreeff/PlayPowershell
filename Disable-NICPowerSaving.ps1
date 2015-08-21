$LogFile = "C:\Windows\Temp\Disable-NICPowerSaving.log"
$NICS = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002BE10318}\*" -Name "Characteristics" -ErrorAction SilentlyContinue | ?{ $_.Characteristics -match "132" }
ForEach ($NIC in $NICS)
{
	$RegKey = $NIC.PSPath
	Add-Content -path $LogFile -value "Regkey for the NIC is: $RegKey"
	$Adaptername = $(Get-ItemProperty -Path $NIC.PSPath -Name "DriverDesc").DriverDesc
	Add-Content -path $LogFile -value "The name for the NIC is: $Adaptername"
	$CurrentValue = $(Get-ItemProperty -Path $NIC.PSPath -Name "PnPCapabilities" -ErrorAction SilentlyContinue).PnPCapabilities
	Add-Content -path $LogFile -value "The current value of the PnPCapabilities key is: $CurrentValue"
	Set-itemproperty -path $RegKey -name 'PnPCapabilities' -Type DWORD -value '280'
	$NewPnPCapabilities = Get-ItemProperty -Path $RegKey -Name "PnPCapabilities" -ErrorAction SilentlyContinue
	$NewValue = $NewPnPCapabilities.PnPCapabilities
	Add-Content -path $LogFile -value "The new value of the PnPCapabilities key is: $NewValue" 
}