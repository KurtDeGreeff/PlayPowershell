function Get-IPConfig{

param ( $RemoteComputer="LocalHost",

 $OnlyConnectedNetworkAdapters=$true

   )
gwmi -Class Win32_NetworkAdapterConfiguration -ComputerName $RemoteComputer | 
Where { $_.IPEnabled -eq $OnlyConnectedNetworkAdapters } | 
Format-List @{ Label="Computer Name"; Expression= { $_.__SERVER }}, 
IPEnabled, Description, MACAddress, IPAddress, IPSubnet, DefaultIPGateway, 
DHCPEnabled, DHCPServer, @{ Label="DHCP Lease Expires"; Expression= { 
[dateTime]$_.DHCPLeaseExpires }}, @{ Label="DHCP Lease Obtained"; Expression= { 
[dateTime]$_.DHCPLeaseObtained }}

}
Get-IPConfig