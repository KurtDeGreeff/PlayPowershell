####################################################################################
#.Synopsis 
#    Assigns a new random MAC address to a physical network interface.
#
#.Description 
#    Windows has a registry value which can be set to override the default MAC
#    address in a network interface card (NIC).  If you have multiple NICs, the
#    script will ask you which to modify.  The MAC will have a valid manufacturer
#    identifier from a common vendor like Intel, Apple or Netgear.  By default,
#    the script changes the MAC, releases the DHCP lease, disables the NIC, 
#    enables the NIC, and then renews the DHCP lease again; if you don't want
#    this behavior, use the -DoNotResetInterface switch, but note that the new  
#    MAC address will not become effective until after the NIC is disabled and
#    enabled again, whether you have a static or dynamic IP address.  Note that
#    many interfaces, such as for your particular 802.11 wireless card perhaps,
#    will not accept a custom MAC address unless a special bit in the MAC
#    indicates that it has been customized, so, in this case, use -Wireless switch.
#
#.Parameter InterfaceIndexNumber
#    If you know the correct index number of the NIC whose MAC you wish to change,
#    you don't have to be prompted every time for it.  If you have multiple
#    physical interfaces, run this script once manually to see the index list.
#
#.Parameter Wireless
#    Sets a bit flag in the MAC indicating to the wireless NIC driver that the
#    MAC has been customized.  Many wireless drivers require this in order to
#    accept and use a custom MAC address.
#
#.Parameter ResetDefault
#    Deletes the registry value for the custom MAC address, which resets to
#    the default MAC address built into the network interface card.
#
#.Parameter DoNotResetInterface
#    Prevents the script from disabling/enabling the interface and 
#    releasing/renewing its DHCP lease after making any changes.
#
#.Example 
#    new-macaddress.ps1
#
#    This will select a random MAC address with a valid vendor ID number, and
#    either assign the MAC to the sole physical interface, or, if there are
#    multiple interfaces, prompt the user to select the desired interface.
#
#.Example 
#    new-macaddress.ps1 -resetdefault 
#
#    Registry value for the custom MAC will be deleted.  The built-in MAC
#    of the NIC will be used instead, which is the factory default.
#
#.Example 
#    new-macaddress.ps1 -donotresetinterface
#
#    The modified interface will not be disabled and enabled, nor will its
#    DHCP lease be released and renewed.  The registry value for the MAC
#    address will still be modified however.
#
#Requires -Version 2.0 
#
#.Notes 
#  Author: Jason Fossen (http://blogs.sans.org/windows-security/)  
# Version: 1.0
# Updated: 29.May.2011
#   LEGAL: PUBLIC DOMAIN.  SCRIPT PROVIDED "AS IS" WITH NO WARRANTIES OR GUARANTEES OF 
#          ANY KIND, INCLUDING BUT NOT LIMITED TO MERCHANTABILITY AND/OR FITNESS FOR
#          A PARTICULAR PURPOSE.  ALL RISKS OF DAMAGE REMAINS WITH THE USER, EVEN IF
#          THE AUTHOR, SUPPLIER OR DISTRIBUTOR HAS BEEN ADVISED OF THE POSSIBILITY OF
#          ANY SUCH DAMAGE.  IF YOUR STATE DOES NOT PERMIT THE COMPLETE LIMITATION OF
#          LIABILITY, THEN DELETE THIS FILE SINCE YOU ARE NOW PROHIBITED TO HAVE IT.
####################################################################################

param ($InterfaceIndexNumber, [Switch] $Wireless, [Switch] $DoNotResetInterface, [Switch] $ResetDefault)



function random-mac ($ManufacturerName, $ManufacturerID, $Delimiter, [Switch] $TotallyRandom, [Switch] $LocallyAdministered, [Switch] $Multicast)
{   
####################################################################################
#.Synopsis
#   Generates a valid MAC address, with control over the unicast/multicast and
#   vendor-unique/locally-administered bit flags.
#.Parameter ManufacturerName
#   The name of one of the vendors below, otherwise, vendor chosen at random:
#   Netgear, DLink, ThreeCom, Intel, HP, Apple, AlliedTelesis, QLogic
#.Parameter ManufacturerID
#   A three-byte hex string, e.g., 0026F2, at the beginning of a MAC address,
#     if you wish to set your own vendor ID instead of using one of the built-in.
#.Parameter Delimiter 
#   Might be a colon or a dash in between each pair of hex characters; otherwise, none.
#.Parameter TotallyRandom 
#   Will generate a MAC that probably does not have a valid vendor ID since the
#   entire MAC address will be generated at random.  This MAC will be anomalous. 
#.Parameter LocallyAdministered
#   Will set the bit to indicate that this MAC address has been set locally to
#   override the burned-in MAC address of the NIC.  Default is to not set this
#   bit, i.e., to indicate that the MAC address has *not* been overridden.  This
#   switch will modify the first byte of the vendor ID portion of the MAC.
#.Parameter Multicast
#   Will set the bit to indicate that this MAC address is for multicast use (rare).
#   The default is to not set this bit, i.e., the MAC address is for unicast (typical).
#   This switch will modify the first byte of the vendor ID portion of the MAC. 
#Requires -Version 2.0
####################################################################################

	# $mac will be padded with random hex later, but add a random vendor ID by default.
    if ($TotallyRandom) { $mac = "" }  
	else
	{
		# First three bytes will come from the manufacturer ID number.
		# Some input checking of the manufacturer selection...
		if ($ManufacturerName -and $ManufacturerName.StartsWith("3")) { $ManufacturerName = "ThreeCom" } 
		if ($ManufacturerName -and $ManufacturerName.ToUpper().StartsWith("D-")) { $ManufacturerName = "DLink" }
		if ($ManufacturerID -and $ManufacturerID.ToString().length -gt 12) { $ManufacturerID = $ManufacturerID.ToString().SubString(0,12) } 
		
		# Manufacturer identifiers last updated on 5.Feb.2011:
		$vendor = @{
			"Netgear" = "0024B2 0026F2 30469A A021B7 C03F0E C43DC7 E0469A E091F5 000FB5 00146C 00184D 001B2F 001E2A 001F33 00223F 00095B" ;
			"DLink" = "00055D 000D88 000F3D 001195 001346 0015E9 00179A 00195B 001B11 001CF0 001E58 002191 0022B0 002401 00265A 0050BA 0080C8 14D64D 1CAFF7 1CBDB9 340804 5CD998 F07D68" ;
			"ThreeCom" = "000102 000103 00029C 00040B 00051A 00068C 000A04 000A5E 000BAC 000D54 000E6A 000FCB 00104B 00105A 0012A9 00147C 0016E0 00186E 001AC1 001CC5 001EC1 0020AF 002257 002473 002654 00301E 005004 005099 0050DA 006008 00608C 006097 009004 00A024 00D096 00D0D8 02608C 02C08C 08004E 20FDF1 4001C6" ;
			"Intel" = "0002B3 000347 000423 0007E9 000CF1 000E0C 000E35 001111 0012F0 001302 001320 0013CE 0013E8 001500 001517 00166F 001676 0016EA 0016EB 0018DE 0019D1 0019D2 001B21 001B77 001CBF 001CC0 001DE0 001DE1 001E64 001E65 001E67 001F3B 001F3C 00207B 00215C 00215D 00216A 00216B 0022FA 0022FB 002314 002315 0024D6 0024D7 0026C6 0026C7 00270E 002710 0050F1 009027 00A0C9 00AA00 00AA01 00AA02 00D0B7 081196 0CD292 100BA9 183DA2 247703 4025C2 448500 4C8093 502DA2 58946B 648099 64D4DA 685D43 74E50B 78929C 809B20 88532E 8CA982 A088B4 AC7289 BC7737 DCA971" ;
			"HP" = "0001E6 0001E7 0002A5 0004EA 000802 000883 0008C7 000A57 000BCD 000D9D 000E7F 000EB3 000F20 000F61 001083 0010E3 00110A 001185 001279 001321 001438 0014C2 001560 001635 001708 0017A4 001871 0018FE 0019BB 001A4B 001B78 001CC4 001E0B 001F29 00215A 002264 00237D 002481 0025B3 002655 00306E 0030C1 00508B 0060B0 00805F 0080A0 080009 18A905 1CC1DE 2C27D7 3C4A92 643150 68B599 78ACC0 78E3B5 78E7D1 984BE1 B499BA B8AF67 D48564 D8D385 F4CE46" ;
			"Apple" = "000393 000502 000A27 000A95 000D93 0010FA 001124 001451 0016CB 0017F2 0019E3 001B63 001CB3 001D4F 001E52 001EC2 001F5B 001FF3 0021E9 002241 002312 002332 00236C 0023DF 002436 002500 00254B 0025BC 002608 00264A 0026B0 0026BB 003065 0050E4 00A040 041E64 080007 1093E9 109ADD 18E7F4 24AB81 28E7CF 34159E 3C0754 40A6D9 40D32D 442A60 581FAA 5855CA 58B035 5C5948 60334B 60FB42 64B9E8 70CD60 78CA39 7C6D62 7CC537 7CF05F 88C663 8C5877 8C7B9D 9027E4 90840D 9803D8 A46706 A4B197 B8FF61 C42C03 C82A14 C8BCC8 CC08E0 D49A20 D83062 D89E3F D8A25E DC2B61 E0F847 E4CE8F E80688 F0B479 F81EDF" ;
			"AlliedTelesis" = "0000CD 0000F4 000941 000A79 000DDA 001130 001577 001AEB 002687 009099 00A0D2 ECCD6D" ;
			"QLogic" = "000E1E 001B32 0024FF 00C0DD 00E08B"
		}

		# Check that $ManufacturerName actually matches one of the valid $vendors here.
		if ($ManufacturerName -and ($vendor.keys -notcontains $ManufacturerName)) 
		{ throw "`nYou must choose a vendor from this list:`n" + $vendor.keys } 
		
		# Generate the first three bytes of the MAC or use the $ManufacturerID instead.
		if ($ManufacturerID) { $mac = $ManufacturerID.ToString().ToUpper() -replace '[^A-F0-9]',"" }
		elseif ($ManufacturerName) { $mac = get-random -input @($vendor.$ManufacturerName -split " ") } 
		else { $mac = get-random -input @($vendor.$(get-random -input @($vendor.keys)) -split " ") } 
    }
    
    # Now padright with random hex characters until we have twelve chars.
    while ($mac.length -lt 12) 
	{ 
		$mac += "{0:X}" -f $(get-random -min 0 -max 16) 
	} 
    
	# Now set the unicast/multicast flag bit.
	# First low-order bit (right-most bit): 0 = unicast, 1 = multicast
    # For the bit flags, see http://en.wikipedia.org/wiki/MAC_address	
	[Byte] $firstbyte = "0x" + $mac.substring(0,2)      # Convert first two hex chars to a byte.

	if ($multicast)
	{
		$firstbyte = [Byte] $firstbyte -bor [Byte] 1     # Set low-order bit to 1: multicast
		$mac = ("{0:X}" -f $firstbyte).padleft(2,"0") + $mac.substring(2) 
	}
	else
	{
		$firstbyte = [Byte] $firstbyte -band [Byte] 254  # Set low-order bit to 0: unicast
		$mac = ("{0:X}" -f $firstbyte).padleft(2,"0") + $mac.substring(2) 
	}
	
	
	# Now set the vendor-unique/locally-administered flag.
	# Next-to-low-order bit (second from right): 0 = unique vendor, 1 = locally administered
	if ($locallyadministered)
	{
		$firstbyte = [Byte] $firstbyte -bor [Byte] 2     # Set second low-order bit to 1: locally
		$mac = ("{0:X}" -f $firstbyte).padleft(2,"0") + $mac.substring(2) 
	}
	else
	{
		$firstbyte = [Byte] $firstbyte -band [Byte] 253  # Set second low-order bit to 0: vendor unique
		$mac = ("{0:X}" -f $firstbyte).padleft(2,"0") + $mac.substring(2) 
	}
	
		
    # Add delimiter, if any, and return the $mac.
    if ($Delimiter) 
    { 
		for ($i = 0 ; $i -le 10 ; $i += 2) 
		{ $newmac += $mac.substring($i,2) + $Delimiter }
		$newmac.substring(0,$($newmac.length - $Delimiter.length)) 
	} 
    else
    { $mac } 
}


# Get the NICs which are not tunnels, not for virtual machines, and not for bluetooth.
$nics = @(Get-WmiObject -Query "select * from win32_networkadapter where adaptertype != 'Tunnel' and adaptertype is not null" | `
where { $_.description -notmatch 'VMware|Virtual|WAN Miniport|ISATAP|RAS Async|Teredo|Windows Mobile Remote|6to4|Bluetooth' } )

# If more than one physical NIC, prompt the user to select one, if the index number was not given.
if ($nics.count -eq 0) { "`nCannot identify a valid network interface device, quitting...`n" ; exit }
elseif ($nics.count -eq 1 -and -not $InterfaceIndexNumber) { $index = $nics[0].index } 
else 
{
    if ($InterfaceIndexNumber) { $index = $InterfaceIndexNumber } 
    else
    {
        # Print a list of interfaces and prompt user to choose one.
        "`n"; $nics | format-table index,macaddress,netconnectionid,description -autosize
        $index = read-host -prompt "`nEnter the index number of the desired interface" 
    }
} 

# Check that a valid index number was actually entered.
$good = $false; switch ($nics | foreach {$_.index}) { $index { $good = $true } } 
if (-not $good) { "`n$index is not a valid index number, quitting...`n" ; exit } 

# Confirm that you can get the NIC by the index number, so that it can be disabled/enabled later too.
$thenic = Get-WmiObject -Query "select * from win32_networkadapter where deviceid = $index"
if (-not $?) { "`nThere was a problem getting the interface, quitting...`n" ; exit } 

# The registry key for the nic always has four digits, so padleft, then get the key.
$index = $index.tostring().padleft(4,"0")
$regkey = get-item "hklm:\system\CurrentControlSet\control\class\{4D36E972-E325-11CE-BFC1-08002BE10318}\$index" 
if (-not $?) { "`nThere was a problem getting the registry key, quitting...`n" ; exit } 

# Show how WMI sees the current MAC address.
("`nWMI reports the current MAC address for interface $index as " + $thenic.macaddress + ".").replace(":","")

# Show current registry value for MAC address, if any.
$macaddress = $regkey.getvalue("NetworkAddress")
if ($macaddress -eq $null) {"Custom MAC address registry value does not exist for interface index $index."} 
else {"Current registry MAC value for interface $index is $macaddress."}

# If requested, delete the registry value for a custom MAC, which resets to the default burnt-in 
# MAC; otherwise, set the registry value for a custom MAC address.
if ($resetdefault)
{
	if ($macaddress -ne $null)
	{
		"Deleting registry value for a custom MAC, which resets to the default MAC address."
		$regpath = "hklm:\system\CurrentControlSet\control\class\{4D36E972-E325-11CE-BFC1-08002BE10318}\$index"
		remove-itemproperty -path $regpath -name "NetworkAddress"
		if (-not $?) { "`nFAILED to delete the registry value for the MAC address!`n" ; exit } 
	}
}
else
{
	# Set new value for MAC address.
	$regpath = "hklm:\system\CurrentControlSet\control\class\{4D36E972-E325-11CE-BFC1-08002BE10318}\$index"
	if ($wireless)
	{
		set-itemproperty -path $regpath -name "NetworkAddress" -value $(random-mac -locallyadministered) 
	}
	else
	{
		set-itemproperty -path $regpath -name "NetworkAddress" -value $(random-mac) 
	}
	if (-not $?) { "`nFAILED to set the registry value for the MAC address!`n" ; exit } 

	# Show new registry value for MAC address.
	$macaddress = $regkey.getvalue("NetworkAddress")
	if ($macaddress -eq $null) { "`nFAILED to change the registry value for a custom MAC address`n" ; exit } 
	else {"The new registry MAC value for interface $index is $macaddress."}
}

# Release DHCP leases, disable the interface, re-enable, renew DHCP.
if ($DoNotResetInterface)
{   "Changes will not take effect until after the interface has been disabled and enabled.`n" } 
else
{
    "Refreshing the interface, this may take a few seconds..."
    ipconfig.exe /release """$($thenic.netconnectionid)"""   | out-null
    ipconfig.exe /release6 """$($thenic.netconnectionid)"""  | out-null
    $thenic.disable() | out-null
    if (-not $?) { "FAILED to disable the interface!" } 
    $thenic.enable() | out-null
    if (-not $?) { "FAILED to enable the interface!" } 
    ipconfig.exe /renew """$($thenic.netconnectionid)"""  | out-null
    ipconfig.exe /renew6 """$($thenic.netconnectionid)""" | out-null
    "...done refreshing the interface."

    # Confirm through WMI again that the change actually took effect.
    $thenic = Get-WmiObject -Query "select * from win32_networkadapter where deviceid = $index"
    ("WMI reports the current MAC address for interface $index as " + $thenic.macaddress + ".`n").replace(":","")
}

# END-O-SCRIPT
