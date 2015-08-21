ipmo showui
#List ip addresses via WMI
Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=TRUE -ComputerName . | Select-Object -Property IPAddress

Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=TRUE -ComputerName . | Select-Object -ExpandProperty IPAddress

#List network adapter config
Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=TRUE –ComputerName .

Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=TRUE -ComputerName . | Select-Object -Property [a-z]* -ExcludeProperty IPX*,WINS*

#List All MAC addresses
get-wmiobject Win32_NetworkAdapterConfiguration | format-table MacAddress, Description -autosize

#DHCP Enabled with TCP/IP Adapters
Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter "IPEnabled=true and DHCPEnabled=true" -ComputerName .

#Enable DHCP on all adapters
Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=true -ComputerName . | ForEach-Object -Process {$_.InvokeMethod("EnableDHCP", $null)}

#Release DHCP from DHCP server 192.168.1.1
Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter "IPEnabled=true and DHCPEnabled=true" -ComputerName . | Where-Object -FilterScript {$_.DHCPServer -contains "192.168.1.1"} | ForEach-Object -Process {$_.InvokeMethod("ReleaseDHCPLease",$null)} #replace ReleaseDHCPRelease with ReleaseDHCPLeaseAll or RenewDHCPLeaseAll to release or renew all adapters

#Ping IP
Get-WmiObject -Class Win32_PingStatus -Filter "Address='127.0.0.1'" -ComputerName . | Select-Object -Property Address,ResponseTime,StatusCode

#Ping Entire Subnet 192.168.2.0/24
1..254| ForEach-Object -Process {Get-WmiObject -Class Win32_PingStatus -Filter ("Address='192.168.2." + $_ + "'") -ComputerName .} | Select-Object -Property Address,ResponseTime,StatusCode

<# StatusCode – Ping command status codes.

0	Success
11001	Buffer Too Small
11002	Destination Net Unreachable
11003	Destination Host Unreachable
11004	Destination Protocol Unreachable
11005	Destination Port Unreachable
11006	No Resources
11007	Bad Option
11008	Hardware Error
11009	Packet Too Big
11010	Request Timed Out
11011	Bad Request
11012	Bad Route
11013	TimeToLive Expired Transit
11014	TimeToLive Expired Reassembly
11015	Parameter Problem
11016	Source Quench
11017	Option Too Big
11018	Bad Destination
11032	Negotiating IPSEC
11050	General Failure
#>

#Find the processes that use more than 10 MB of memory and kill them:
get-process | where { $_.WS -gt 100MB } | stop-process

#maps the share \\Server1\ShareFolder to local drive X:
(New-Object -ComObject WScript.Network).MapNetworkDrive("X:", \Server1sharefolder)

#MANAGE FIREWALL with NETSH
# netsh advfirewall export "c:\advfirewallpolicy.wfw"
# netsh advfirewall import "c:\newpolicy.wfw"
# netsh advfirewall firewall show rule name=all dir=in
# netsh advfirewall firewall add/set/show/delete rule ....   # Add/Modifies/Show/Delete rule
# netsh advfirewall monitor show firewall/Currentprofile
# netsh advfirewall show global
# >netsh advfirewall show allprofiles


































