#requires -version 2
[CmdletBinding()]
param(
    # CIDR notation network address, or using subnet mask. Examples: '192.168.0.1/24', '10.20.30.40/255.255.0.0'.
    [Parameter(Mandatory=$True)][string[]] $NetworkAddress,
    # Causes PSipcalc to return a boolean value for whether the specified IP is in the specified network. Includes network address and broadcast address.
    [string] $Contains,
    # Enumerates all IPs in subnet (potentially resource-expensive). Ignored if you use -Contains.
    [switch] $Enumerate
)

# PowerShell ipcalc clone: PSipcalc.
# Copyright (c), 2015, Svendsen Tech
# All rights reserved.

## Author: Joakim Svendsen

# Original release 2015-07-13 (ish) v1.0 (or whatever...)
# 2015-07-16: Standardized the TotalHosts and UsableHosts properties to always be of the type int64.
# Formely TotalHosts was a string, except for network lengths of 30-32, when it was an int32. UsableHosts used to be int32.

# 2015-07-15: Added -Contains and fixed some comment bugs(!) plus commented a bit more and made minor tweaks. v1.1, I guess.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
# This is a regex I made to match an IPv4 address precisely ( http://www.powershelladmin.com/wiki/PowerShell_regex_to_accurately_match_IPv4_address_%280-255_only%29 )
$IPv4Regex = '(?:(?:0?0?\d|0?[1-9]\d|1\d\d|2[0-5][0-5]|2[0-4]\d)\.){3}(?:0?0?\d|0?[1-9]\d|1\d\d|2[0-5][0-5]|2[0-4]\d)'

function Convert-IPToBinary
{
    param(
        [string] $IP
    )
    $IP = $IP.Trim()
    if ($IP -match "\A${IPv4Regex}\z")
    {
        try
        {
            return ($IP.Split('.') | ForEach-Object { [System.Convert]::ToString([byte] $_, 2).PadLeft(8, '0') }) -join ''
        }
        catch
        {
            Write-Warning -Message "Error converting '$IP' to a binary string: $_"
            return $Null
        }
    }
    else
    {
        Write-Warning -Message "Invalid IP detected: '$IP'."
        return $Null
    }
}

function Convert-BinaryToIP
{
    param(
        [string] $Binary
    )
    $Binary = $Binary -replace '\s+'
    if ($Binary.Length % 8)
    {
        Write-Warning -Message "Binary string '$Binary' is not evenly divisible by 8."
        return $Null
    }
    [int] $NumberOfBytes = $Binary.Length / 8
    $Bytes = @(foreach ($i in 0..($NumberOfBytes-1))
    {
        try
        {
            #$Bytes += # skipping this and collecting "outside" seems to make it like 10 % faster
            [System.Convert]::ToByte($Binary.Substring(($i * 8), 8), 2)
        }
        catch
        {
            Write-Warning -Message "Error converting '$Binary' to bytes. `$i was $i."
            return $Null
        }
    })
    return $Bytes -join '.'
}

function Get-ProperCIDR
{
    param(
        [string] $CIDRString
    )
    $CIDRString = $CIDRString.Trim()
    $o = '' | Select-Object -Property IP, NetworkLength
    if ($CIDRString -match "\A(?<IP>${IPv4Regex})\s*/\s*(?<NetworkLength>\d{1,2})\z")
    {
        # Could have validated the CIDR in the regex, but this is more informative.
        if ([int] $Matches['NetworkLength'] -lt 0 -or [int] $Matches['NetworkLength'] -gt 32)
        {
            Write-Warning "Network length out of range (0-32) in CIDR string: '$CIDRString'."
            return
        }
        $o.IP = $Matches['IP']
        $o.NetworkLength = $Matches['NetworkLength']
    }
    elseif ($CIDRString -match "\A(?<IP>${IPv4Regex})[\s/]+(?<SubnetMask>${IPv4Regex})\z")
    {
        $o.IP = $Matches['IP']
        $SubnetMask = $Matches['SubnetMask']
        if (-not ($BinarySubnetMask = Convert-IPToBinary $SubnetMask))
        {
            return # warning displayed by Convert-IPToBinary, nothing here
        }
        # Some validation of the binary form of the subnet mask, 
        # to check that there aren't ones after a zero has occurred (invalid subnet mask).
        # Strip all leading ones, which means you either eat 32 1s and go to the end (255.255.255.255),
        # or you hit a 0, and if there's a 1 after that, we've got a broken subnet mask, amirite.
        if ((($BinarySubnetMask) -replace '\A1+') -match '1')
        {
            Write-Warning -Message "Invalid subnet mask in CIDR string '$CIDRString'. Subnet mask: '$SubnetMask'."
            return
        }
        $o.NetworkLength = [regex]::Matches($BinarySubnetMask, '1').Count
    }
    else
    {
        Write-Warning -Message "Invalid CIDR string: '${CIDRString}'. Valid examples: '192.168.1.0/24', '10.0.0.0/255.0.0.0'."
        return
    }
    # Check if the IP is all ones or all zeroes (not allowed: http://www.cisco.com/c/en/us/support/docs/ip/routing-information-protocol-rip/13788-3.html )
    if ($o.IP -match '\A(?:(?:1\.){3}1|(?:0\.){3}0)\z')
    {
        Write-Warning "Invalid IP detected in CIDR string '${CIDRString}': '$($o.IP)'. An IP can not be all ones or all zeroes."
        return
    }
    return $o
}

# Not used.
function Get-IPRange
{
    param(
        [string] $StartBinary,
        [string] $EndBinary
    )
    $StartIPArray = @((Convert-BinaryToIP $StartBinary) -split '\.')
    $EndIPArray = ((Convert-BinaryToIP $EndBinary) -split '\.')
    Write-Verbose -Message "Start IP: $($StartIPArray -join '.')"
    Write-Verbose -Message "End IP: $($EndIPArray -join '.')"
    $FirstOctetArray = @($StartIPArray[0]..$EndIPArray[0])
    $SecondOctetArray = @($StartIPArray[1]..$EndIPArray[1])
    $ThirdOctetArray = @($StartIPArray[2]..$EndIPArray[2])
    $FourthOctetArray = @($StartIPArray[3]..$EndIPArray[3])
    # Four levels of nesting... Slow.
    $IPs = @(foreach ($First in $FirstOctetArray)
    {
        foreach ($Second in $SecondOctetArray)
        {
            foreach ($Third in $ThirdOctetArray)
            {
                foreach ($Fourth in $FourthOctetArray)
                {
                    "$First.$Second.$Third.$Fourth"
                }
            }
        }
    })
    $IPs = $IPs | Sort-Object -Unique -Property @{Expression={($_ -split '\.' | ForEach-Object { '{0:D3}' -f [int]$_ }) -join '.' }}
    return $IPs
}

# Used. ;)
function Get-IPRange2
{
    param(
        [string] $StartBinary,
        [string] $EndBinary
    )
    [int64] $StartInt = [System.Convert]::ToInt64($StartBinary, 2)
    [int64] $EndInt = [System.Convert]::ToInt64($EndBinary, 2)
    for ($BinaryIP = $StartInt; $BinaryIP -le $EndInt; $BinaryIP++)
    {
        Convert-BinaryToIP ([System.Convert]::ToString($BinaryIP, 2).PadLeft(32, '0'))
    }
}

function Test-IPIsInNetwork {
    param(
        [string] $IP,
        [string] $StartBinary,
        [string] $EndBinary
    )
    $TestIPBinary = Convert-IPToBinary $IP
    [int64] $TestIPInt64 = [System.Convert]::ToInt64($TestIPBinary, 2)
    [int64] $StartInt64 = [System.Convert]::ToInt64($StartBinary, 2)
    [int64] $EndInt64 = [System.Convert]::ToInt64($EndBinary, 2)
    if ($TestIPInt64 -ge $StartInt64 -and $TestIPInt64 -le $EndInt64)
    {
        return $True
    }
    else
    {
        return $False
    }
}

function Get-NetworkInformationFromProperCIDR
{
    param(
        [psobject] $CIDRObject
    )
    $o = '' | Select-Object -Property IP, NetworkLength, SubnetMask, NetworkAddress, HostMin, HostMax, 
        Broadcast, UsableHosts, TotalHosts, IPEnumerated, BinaryIP, BinarySubnetMask, BinaryNetworkAddress,
        BinaryBroadcast
    $o.IP = [string] $CIDRObject.IP
    $o.BinaryIP = Convert-IPToBinary $o.IP
    $o.NetworkLength = [int32] $CIDRObject.NetworkLength
    $o.SubnetMask = Convert-BinaryToIP ('1' * $o.NetworkLength).PadRight(32, '0')
    $o.BinarySubnetMask = ('1' * $o.NetworkLength).PadRight(32, '0')
    $o.BinaryNetworkAddress = $o.BinaryIP.SubString(0, $o.NetworkLength).PadRight(32, '0')
    if ($Contains)
    {
        if ($Contains -match "\A${IPv4Regex}\z")
        {
            # Passing in IP to test, start binary and end binary.
            return Test-IPIsInNetwork $Contains $o.BinaryNetworkAddress $o.BinaryNetworkAddress.SubString(0, $o.NetworkLength).PadRight(32, '1')
        }
        else
        {
            Write-Error "Invalid IPv4 address specified with -Contains"
            return
        }
    }
    $o.NetworkAddress = Convert-BinaryToIP $o.BinaryNetworkAddress
    if ($o.NetworkLength -eq 32 -or $o.NetworkLength -eq 31)
    {
        $o.HostMin = $o.IP
    }
    else
    {
        $o.HostMin = Convert-BinaryToIP ([System.Convert]::ToString(([System.Convert]::ToInt64($o.BinaryNetworkAddress, 2) + 1), 2)).PadLeft(32, '0')
    }
    #$o.HostMax = Convert-BinaryToIP ([System.Convert]::ToString((([System.Convert]::ToInt64($o.BinaryNetworkAddress.SubString(0, $o.NetworkLength)).PadRight(32, '1'), 2) - 1), 2).PadLeft(32, '0'))
    #$o.HostMax = 
    [string] $BinaryBroadcastIP = $o.BinaryNetworkAddress.SubString(0, $o.NetworkLength).PadRight(32, '1') # this gives broadcast... need minus one.
    $o.BinaryBroadcast = $BinaryBroadcastIP
    [int64] $DecimalHostMax = [System.Convert]::ToInt64($BinaryBroadcastIP, 2) - 1
    [string] $BinaryHostMax = [System.Convert]::ToString($DecimalHostMax, 2).PadLeft(32, '0')
    $o.HostMax = Convert-BinaryToIP $BinaryHostMax
    $o.TotalHosts = [int64][System.Convert]::ToString(([System.Convert]::ToInt64($BinaryBroadcastIP, 2) - [System.Convert]::ToInt64($o.BinaryNetworkAddress, 2) + 1))
    $o.UsableHosts = $o.TotalHosts - 2
    # ugh, exceptions for network lengths from 30..32
    if ($o.NetworkLength -eq 32)
    {
        $o.Broadcast = $Null
        $o.UsableHosts = [int64] 1
        $o.TotalHosts = [int64] 1
        $o.HostMax = $o.IP
    }
    elseif ($o.NetworkLength -eq 31)
    {
        $o.Broadcast = $Null
        $o.UsableHosts = [int64] 2
        $o.TotalHosts = [int64] 2
        # Override the earlier set value for this (bloody exceptions).
        [int64] $DecimalHostMax2 = [System.Convert]::ToInt64($BinaryBroadcastIP, 2) # not minus one here like for the others
        [string] $BinaryHostMax2 = [System.Convert]::ToString($DecimalHostMax2, 2).PadLeft(32, '0')
        $o.HostMax = Convert-BinaryToIP $BinaryHostMax2
    }
    elseif ($o.NetworkLength -eq 30)
    {
        $o.UsableHosts = [int64] 2
        $o.TotalHosts = [int64] 4
        $o.Broadcast = Convert-BinaryToIP $BinaryBroadcastIP
    }
    else
    {
        $o.Broadcast = Convert-BinaryToIP $BinaryBroadcastIP
    }
    # I had to create this Get-IPRange function because a 32-digit binary number wouldn't fit in an int64...
    ### no, I didn't... Get-IPRange2 in effect; significantly faster.
    if ($Enumerate)
    {
        $IPRange = @(Get-IPRange2 $o.BinaryNetworkAddress $o.BinaryNetworkAddress.SubString(0, $o.NetworkLength).PadRight(32, '1'))
        if ((31, 32) -notcontains $o.NetworkLength )
        {
            $IPRange = $IPRange[1..($IPRange.Count-1)] # remove first element
            $IPRange = $IPRange[0..($IPRange.Count-2)] # remove last element
        }
        $o.IPEnumerated = $IPRange
    }
    else {
        $o.IPEnumerated = @()
    }
    return $o
}

$NetworkAddress | ForEach-Object { Get-ProperCIDR $_ } | ForEach-Object { Get-NetworkInformationFromProperCIDR $_ }
