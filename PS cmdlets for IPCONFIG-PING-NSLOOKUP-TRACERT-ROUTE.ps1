#Windows PowerShell cmdlets for IPCONFIG, PING, NSLOOKUP, TRACERT, ROUTE 
#All cmdlets require Win8 or higher unless indicated otherwise

Get-Command -Module Net* | Group Module

#NIC Adapters
Get-NetAdapter
Get-NetAdapter –Physical
Get-NetAdapter –IncludeHidden
Get-NetAdapter | Where {$_.Virtual –eq $True}
Get-VMNetworkAdapter *
Get-NetAdapter | Where-Object -FilterScript {$_.LinkSpeed -eq "100 Mbps"}
Get-NetAdapter | Where-Object -FilterScript {$_.LinkSpeed -eq "100 Mbps"} | Set-NetIPInterface -InterfaceMetric 5
Get-NetAdapterBinding -InterfaceAlias "Ethernet 2"
Disable-NetAdapterBinding -Name "Ethernet 2" -ComponentID ms_pacer
Disable-NetAdapter -Name "Ethernet 2" -Confirm:$false

#IPCONFIG
Get-NetIPAddress
Get-NetIPAddress | Sort InterfaceIndex | FT InterfaceIndex, InterfaceAlias, AddressFamily, IPAddress, PrefixLength -Autosize
Get-NetIPAddress | ? AddressFamily -eq IPv4 | FT –AutoSize
Get-NetAdapter Wi-Fi | Get-NetIPAddress | FT -AutoSize
Get-NetIPConfiguration
Get-NetIpConfiguration | Select-Object interfaceindex, interfacealias, Ipv4address, @{ Label="DefaultGateway"; Expression={ $_.IPv4DefaultGateway.NextHop } }, 
@{ Label="DnsServers"; Expression={ $_.DnsServer.ServerAddresses } }
Get-NetIpConfiguration | format-table interfaceindex, interfacealias, Ipv4address, @{ Label="DefaultGateway"; Expression={ $_.IPv4DefaultGateway.NextHop } }, 
@{ Label="DnsServers"; Expression={ $_.DnsServer.ServerAddresses } } | Export-CSV .\output.csv
GIP
GIP -Detailed

#PING
Test-Connection # Win7
Test-NetConnection
Test-NetConnection www.microsoft.com
Test-NetConnection -ComputerName www.microsoft.com -InformationLevel Detailed
Test-NetConnection -ComputerName www.microsoft.com | Select -ExpandProperty PingReplyDetails | FT Address, Status, RoundTripTime
1..10 | % { Test-NetConnection -ComputerName www.microsoft.com -RemotePort 80 } | FT -AutoSize
Test-NetConnection www.xbox.com -Port 80
Test-NetConnection $SERVERNAME RDP

#DHCP
Get-DhcpServerv4Scope
Add-DhcpServerv4Scope -EndRange 172.16.12.100 -Name test2 -StartRange 172.16.12.50 -SubnetMask 255.255.255.0 -State InActive
Add-DhcpServerv4ExclusionRange -EndRange 172.16.12.75 -ScopeId 172.16.12.0 -StartRange 172.16.12.70
Add-DhcpServerv4Reservation -ClientId EE-05-B0-DA-04-00 -IPAddress 172.16.12.88 -ScopeId 172.16.12.0 -Description "Reservation for file server"
Set-DhcpServerv4OptionValue -Router 172.16.12.1 -ScopeId 172.16.12.0
Set-DhcpServerv4Scope -State Active

#DNS,NSLOOKUP
Resolve-DnsName www.microsoft.com 
Resolve-DnsName microsoft.com -type SOA
Resolve-DnsName microsoft.com -Server 8.8.8.8 –Type A
Clear-DNSClientCache #ipconfig /flushdns
Register-DNSClient #ipconfig /registerdns
Get-NetIPAddress | where {$_.PrefixOrigin -eq "DHCP" -or $_.SuffixOrigin -eq "DHCP"}  #Is DNS static or Dynamic?
Get-WmiObject win32_networkadapterconfiguration | where {$_.IPEnabled -and $_.DHCPEnabled} #Is DNS static or Dynamic? - Win7
Get-DnsServerZone
Get-DnsServerResourceRecord -ZoneName corp.contoso.com | Where-Object {$_.RecordType -eq "A"}
Add-DnsServerResourceRecordA -IPv4Address 172.16.11.239 -Name SEA-TEST -ZoneName corp.contoso.com

#ROUTE
Get-NetRoute -Protocol Local -DestinationPrefix 192.168*
Get-NetAdapter Wi-Fi | Get-NetRoute

#TRACERT
Test-NetConnection www.microsoft.com –TraceRoute
Test-NetConnection outlook.com -TraceRoute | Select -ExpandProperty TraceRoute | % { Resolve-DnsName $_ -type PTR -ErrorAction SilentlyContinue }

#NETSTAT
Get-NetTCPConnection
Get-NetTCPConnection | Group State, RemotePort | Sort Count | FT Count, Name –Autosize
Get-NetTCPConnection | ? State -eq Established | FT –Autosize
Get-NetTCPConnection | ? State -eq Established | ? RemoteAddress -notlike 127* | % { $_; Resolve-DnsName $_.RemoteAddress -type PTR -ErrorAction SilentlyContinue }