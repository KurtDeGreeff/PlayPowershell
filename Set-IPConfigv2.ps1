# script parameters
param(
[string[]] $Computers = $env:computername,
[switch] $ChangeSettings,
[switch] $EnableDHCP,
[switch] $Batch
)
$nl = [Environment]::NewLine
# check for Admin rights
if ($ChangeSettings -or $EnableDHCP){
	If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")){
		Write-Warning "You need Administrator rights to run this script!"
		Break
	}
}
else{
$nl
Write-Warning "For changing settings add -ChangeSettings as parameter, if not this script is output only"
}
# script variables

$Domain = "domain.local"
$DNSSuffix = @("domain.local", "domain.com")
$DNSServers = @("10.10.0.1", "10.10.0.2", "10.10.0.3", "10.10.0.4")
$WINSServers = @("10.10.0.5", "10.10.0.6")
$Gateway = @("10.10.255.254")
# script functions
Function NewNICDetails($NIC, $Computer){
	# retrieve updated values for changed NIC
	$UpdatedNIC = Get-WMIObject Win32_NetworkAdapterConfiguration -Computername $Computer | where{$_.Index -eq $NIC.Index}
	ShowDetails $UpdatedNIC
}

Function ChangeIPConfig($NIC){
	if ($EnableDHCP){$NIC.EnableDHCP()}
	#uncomment line(s) if applicable
	#$NIC.SetGateways($Gateway)
	#$NIC.SetWINSServer($WINSServers)
	$DNSServers = Get-random $DNSservers -Count 4
	$NIC.SetDNSServerSearchOrder($DNSServers)
	$NIC.SetDynamicDNSRegistration("TRUE")
	$NIC.SetDNSDomain($Domain)
	# remote WMI registry method for updating DNS Suffix SearchOrder
	$registry = [WMIClass]"\\$computer\root\default:StdRegProv"
	$HKLM = [UInt32] "0x80000002"
	$registry.SetStringValue($HKLM, "SYSTEM\CurrentControlSet\Services\TCPIP\Parameters", "SearchList", $DNSSuffix)
}

Function ShowDetails($NIC){
	Write-Output "$("Hostname = ")$($NIC.DNSHostName)"
	Write-Output "$("DNSDomain= ")$($NIC.DNSDomain)"
	Write-Output "$("Domain DNS Registration Enabled = ")$($NIC.DomainDNSRegistrationEnabled)"
	Write-Output "$("Full DNS Registration Enabled = ")$($NIC.FullDNSRegistrationEnabled)"
	Write-Output "$("DNS Domain Suffix Search Order = ")$($NIC.DNSDomainSuffixSearchOrder)"
	Write-Output "$("MAC address = ")$($NIC.MACAddress)"
	Write-Output "$("DHCP enabled = ")$($NIC.DHCPEnabled)"
	# show all IP adresses on this NIC
	$x = 0
	foreach ($IP in $NIC.IPAddress){
		Write-Output "$("IP address $x =")$($NIC.IPAddress[$x])$("/")$($NIC.IPSubnet[$x])"
		$x++
	}
	Write-Output "$("Default IP Gateway = ")$($NIC.DefaultIPGateway)"
	Write-Output "$("DNS Server Search Order = ")$($NIC.DNSServerSearchOrder)"
}
# actual script execution
foreach ($Computer in $Computers){
	if (Test-connection $Computer -quiet -count 1){
	Try {
		[array]$NICs = Get-WMIObject Win32_NetworkAdapterConfiguration -Computername $Computer -EA Stop | where{$_.IPEnabled -eq "TRUE"}
		}
	Catch {
		Write-Host $nl "    ====INACCESIBLE====" $nl
		Write-Warning "$($error[0])"
		Write-Output "$($nl)$($Computer.ToUpper())$(" is INACCESIBLE")"
		Write-Host $nl
		continue
		}
	# Generate selection menu only if there is indeed more than 1 NIC
	$NICindex = $NICs.count
	$SelectIndex = 0
	if ($NICindex -gt 1){
		if ($Batch){
			# only perform action if $NICindex -eq 1
			Write-Host $nl "    ====SKIPPED====" $nl
			Write-Output "$($nl)$($Computer.ToUpper())$(" skipped due to multiple NICs")"
			continue
			}
		else{
			Write-Host "$nl Selection for " $Computer.ToUpper() ": $nl"
			For ($i=0;$i -lt $NICindex; $i++) {
				Write-Host -ForegroundColor Green $i --> $($NICs[$i].Description)
				}
				Write-Host -ForegroundColor Green q --> Quit
				Write-Host $nl
			# Wait for user selection input
			Do {
				$SelectIndex = Read-Host "Select connection (default = $SelectIndex) or 'q' to quit"
				If ($SelectIndex -NotLike "q*"){$SelectIndex = $SelectIndex -as [int]}
			}
			Until (($SelectIndex -lt $NICindex -AND $SelectIndex -match "\d") -OR $SelectIndex -Like "q*")
			If ($SelectIndex -Like "q*"){continue}
			}
		}
	# Show selected network card name + current values
	Write-Host $nl "     ====BEFORE====" $nl
	Write-Output "$($nl)$(" IP settings on:")$($Computer.ToUpper())$($nl)$($nl)$(" for ")$($NICs[$SelectIndex].Description)$(":")"
	Write-Output $(ShowDetails $NICs[$SelectIndex])$($nl)
	# Change settings for selected network card if option is true and show updated values
	If ($ChangeSettings){
		ChangeIPConfig $NICs[$SelectIndex]
		Write-Host $nl "    ====AFTER====" $nl
		Write-Output "$($nl)$(" IP settings on:")$($Computer.ToUpper())$($nl)$($nl)$(" for ") $($NICs[$SelectIndex].Description)$(":")"
		Write-Output $(NewNICDetails $NICs[$SelectIndex] $Computer)$($nl)
		}
	}
}