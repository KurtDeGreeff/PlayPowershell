# Send Wake-on-Lan Magic Packet to specified Mac address
[CmdletBinding()]
Param ($MacString=$(Throw 'Mac address is required'))
 
$Table=@{
    Hyperion  ='00-00-00-00-00-44';
    Nova      ='00-00-00-00-00-C8';
    Desktop   ='00-00-00-00-00-1B';
    Laptop    ='00-00-00-00-00-18';
    Playroom  ='00-00-00-00-00-5C';
    Betty     ='00-00-00-00-00-32';
    gr8       ='00-00-00-00-00-D7'
}
If ($Table.ContainsKey($MacString)) {$MacString=$Table[$MacString]}
 
Write-Verbose "Using MAC string $MacString"
 
If ($MacString -NotMatch '^([0-9A-F]{2}[:-]){5}([0-9A-F]{2})$') {
    Throw 'Mac address must be 6 hex bytes separated by : or -'
}
 
# Split and convert to array of bytes
$Mac=$MacString.Split('-:')|%{[Byte]"0x$_"}
 
# Packet is byte array; first six bytes are 0xFF, followed by 16 copies of the MAC address
$Packet = [Byte[]](,0xFF*6)+($Mac*16)
Write-Verbose "Broadcast packet: $([BitConverter]::ToString($Packet))"
 
$UdpClient=New-Object System.Net.Sockets.UdpClient
$UdpClient.Connect(([System.Net.IPAddress]::Broadcast),4000)
[Void]$UdpClient.Send($Packet,$Packet.Length)
$UdpClient.Close()
Write-Verbose "Wake-on-Lan Packet sent to $MacString"