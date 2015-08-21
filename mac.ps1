function func_MAC_address()
{
$input | ForEach-Object {
	$macAddressRecord = New-Object System.Management.Automation.PSObject
	$macAddressRecord.PSObject.TypeNames[0] = 'NetworkAdapterMacAddress'
	$macAddressRecord `
		| Add-Member -MemberType NoteProperty -Name Name -Value $_.Name -PassThru `
		| Add-Member -MemberType NoteProperty -Name MacAddress -Value $_.GetPhysicalAddress() -PassThru
}
}
$N=[System.Net.NetworkInformation.NetworkInterface]::GetAllNetworkInterfaces() | where { $_.Name -like 'Local Area Connection'} | func_MAC_address | Select-Object -property 'MacAddress'
$Mac=$N.MacAddress
$Mac
#  $Input = The current content of the pipeline.
#  $_ =     The current pipeline object; used in script blocks, filters, functions and loops