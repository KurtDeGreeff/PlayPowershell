
function PushToUdpPort {
################################################################
#.Synopsis
#  Send byte array over UDP to IP address and port number.
#.Parameter ByteArray
#  Array of [Byte] objects for the UDP payload.
#.Parameter IP
#  IP address or FQDN of the destination host.
#.Parameter Port
#  UDP port number at destination host.
#.Example
#
# [byte[]] $payload = 0x41, 0x42, 0x43, 0x44, 0x45
# PushToUdpPort $payload -ip "www.sans.org" -port 1531
#
################################################################ 

[CmdletBinding()] 
Param ( [Parameter(Mandatory = $True)] [Byte[]] $ByteArray, 
        [Parameter(Mandatory = $True)] [String] $IP,
        [Parameter(Mandatory = $True)] [Int] $Port
      )
 
$UdpClient = New-Object System.Net.Sockets.UdpClient 
$UdpClient.Connect($IP,$Port) 
$UdpClient.Send($ByteArray, $ByteArray.length) | out-null
}






function WakeOnLAN {
################################################################
#.Synopsis
#  Broadcast a Wake On LAN magic packet to a MAC address.
#.Parameter MACAddress
#  The hardware MAC address of computer to wake up as a
#  string with dashes or colons, e.g., "90:1F:82:00:03:40"
#.Example
#  "00:1F:82:00:03:00" | WakeOnLAN 
################################################################ 

[CmdletBinding()] 
Param ( [Parameter(Mandatory = $True, 
                   ValueFromPipeline = $True, 
                   ValueFromPipelineByPropertyName = $True)] 
        [Alias("MAC")]
        [String] $MACAddress )
 
[byte[]] $MagicPacket = 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
$MagicPacket += (($MACAddress -split '[\:\-]' | foreach {[byte] ('0x' + $_)} ) * 16)  
$UdpClient = New-Object System.Net.Sockets.UdpClient 
$UdpClient.Connect( ([System.Net.IPAddress]::Broadcast) ,9) 
$UdpClient.Send($MagicPacket,$MagicPacket.length) | out-null
}

