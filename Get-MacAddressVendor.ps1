function Get-MacAddressVendor {
    <#
        .SYNOPSIS
            Get vendor information from MAC address.
        .DESCRIPTION
            This script uses the free API from www.macvendorlookup.com to look up vendor information for the supplied MAC address.
        .NOTES
            Author: Øyvind Kallstad
            Date: 09.04.2015
            Version: 1.1
    #>
    [CmdletBinding()]
    param (
        # MAC Address
        [Parameter(Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string] $MacAddress = ([System.Net.NetworkInformation.NetworkInterface]::GetAllNetworkInterfaces() | Where-Object {$_.OperationalStatus -eq 'Up' -and $_.NetworkInterfaceType -ne [System.Net.NetworkInformation.NetworkInterfaceType]::Loopback})[0].GetPhysicalAddress()
    )

    try {
        $uri = [uri]"http://www.macvendorlookup.com/api/v2/$($MacAddress)"
        $result = Invoke-RestMethod -Uri $uri
        Write-Output $result
    }
    catch {Write-Warning $_.Exception.Message}
}