<#
.SYNOPSIS
    This script creates a rule in the Windows Host Firewall.
.DESCRIPTION
    This script creates a new firewall rule for
    port 80 over tcp (i.e. 80).
.NOTES
    File Name  : Enable-FirewallPort.ps1
	Author     : Thomas Lee - tfl@psp.co.uk
	Requires   : PowerShell Version 2.0
.LINK
    This script posted to:
	    http://www.pshscripts.blogspot.com
    MSDN Sample posted at:
	    http://msdn.microsoft.com/en-us/library/aa366423%28VS.85%29.aspx
.EXAMPLE
    PSH [C:\foo]: .\EnableFireWallPort2.ps1'
    Before Script Runs:

    Name   IpVersion Protocol Port Scope RemoteAddresses Enabled
    ----   --------- -------- ---- ----- --------------- -------
    HTTPS          2        6  443     0 *                  True
    driver         2        6 8085     0 *                  True
    driver         2        6 8085     0 *                  True
 

    After Script Runs:

    Name   IpVersion Protocol Port Scope RemoteAddresses Enabled
    ----   --------- -------- ---- ----- --------------- -------
    HTTP           2        6   80     0 *                  True
    HTTPS          2        6  443     0 *                  True
    driver         2        6 8085     0 *                  True
    driver         2        6 8085     0 *                  True

#>

##
# Start Script
##

# Set Strict Mode 
Set-Strictmode -Version 2.0
# Set Constants
$NET_FW_IP_PROTOCOL_UDP = 17
$NET_FW_IP_PROTOCOL_TCP = 6

# Create the firewall manager object.
$fwMgr = New-Object -COM HNetCfg.FwMgr

# Get the current profile for the local firewall policy.
$profile = $fwMgr.LocalPolicy.CurrentProfile

# Display it
"Before Script Runs:"
$profile.GloballyOpenPorts | `
ft name, ipversion, protocol, port, scope, remoteaddresses, enabled -auto

# Now add Port 80

$port = New-Object -COM HNetCfg.FWOpenPort
$port.Name = "HTTP"
$port.Protocol = $NET_FW_IP_PROTOCOL_TCP
$port.Port = 80

# If using RemoteAddresses, don't use Scope
# "*" means Scope of Any. Other entries are ignored if this is specified.
# "LocalSubnet" means Scope of Local Subnet. Can be used with other addresses as well. 
$port.RemoteAddresses = "*"

# Use this line to scope the port to Local Subnet only
#$port.RemoteAddresses = "LocalSubnet"

#Use this line to scope the port to the specific IP 10.1.1.1, the specific subnet 12.5.0.0, and Local Subnet. Don't put spaces.
#port.RemoteAddresses = "LocalSubnet,10.1.1.1/255.255.255.255,12.5.0.0/255.255.0.0"

$port.Enabled = $TRUE

#Use this line instead if you want to add the port, but disabled
#port.Enabled = FALSE

# Now add the port
$profile.GloballyOpenPorts.Add($port)

# Print Results
" After Script Runs:"
$profile = $fwMgr.LocalPolicy.CurrentProfile
$profile.GloballyOpenPorts | `
ft name, ipversion, protocol, port, scope, remoteaddresses, enabled -auto
# End of script