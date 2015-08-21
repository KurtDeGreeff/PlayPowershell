function Get-MACAddress {
    <#
        .SYNOPSIS
            Sends an Address Resolution Protocol (ARP) request to obtain the physical address that corresponds to the specified destination IPv4 address.
        .NOTES
            http://poshcode.org/2763
    #>
    param (
        [Parameter(Position = 0)]
        [ValidateNotNullorEmpty()]
        [string] $IPAddress = ([System.Net.NetworkInformation.NetworkInterface]::GetAllNetworkInterfaces() | Where-Object {$_.OperationalStatus -eq 'Up' -and $_.NetworkInterfaceType -ne [System.Net.NetworkInformation.NetworkInterfaceType]::Loopback})[0].GetIPProperties().UnicastAddresses.Address.ToString()
    )

    $sign = @"
        using System;
        using System.Collections.Generic;
        using System.Text;
        using System.Net;
        using System.Net.NetworkInformation;
        using System.Runtime.InteropServices;
 
        public static class NetUtils
        {
           [System.Runtime.InteropServices.DllImport("iphlpapi.dll", ExactSpelling = true)]
           static extern int SendARP(int DestIP, int SrcIP, byte[] pMacAddr, ref int PhyAddrLen);
 
           public static string GetMacAddress(String addr)
           {
                try
                {                  
                    IPAddress IPaddr = IPAddress.Parse(addr);
                    byte[] mac = new byte[6];
                    int L = 6;
                    SendARP(BitConverter.ToInt32(IPaddr.GetAddressBytes(), 0), 0, mac, ref L);
                    String macAddr = BitConverter.ToString(mac, 0, L);
                    return (macAddr.Replace('-',':'));
                }
 
                catch (Exception ex)
                {
                    return (ex.Message);              
                }
           }
        }
"@

    $type = Add-Type -TypeDefinition $sign -Language CSharp -PassThru
    Write-Output ($type::GetMacAddress($IPAddress))
}