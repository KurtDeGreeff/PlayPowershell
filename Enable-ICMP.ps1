<#
.SYNOPSIS
    This script Enables ICMP on the Standard Firewall profile.
.DESCRIPTION
    This script creates a Firewall object then configures it.
.NOTES
    File Name  : Enable-ICMP.ps1
	Author     : Thomas Lee - tfl@psp.co.uk
	Requires   : PowerShell Version 2.0
.LINK
    This script posted to:
	    http://www.pshscripts.blogspot.com
    MSDN Sample posted at:
	    http://
.EXAMPLE
    PSH [C:\foo]: . 'E:\PowerShellScriptLib\COM\HNetCfg.FwMgr\Enable-ICMP.ps1'

    AllowOutboundDestinationUnreachable : False
    AllowRedirect                       : False
    AllowInboundEchoRequest             : False
    AllowOutboundTimeExceeded           : False
    AllowOutboundParameterProblem       : False
    AllowOutboundSourceQuench           : False
    AllowInboundRouterRequest           : False
    AllowInboundTimestampRequest        : False
    AllowInboundMaskRequest             : False
    AllowOutboundPacketTooBig           : True

    After Script ran:
    AllowOutboundDestinationUnreachable : False
    AllowRedirect                       : False
    AllowInboundEchoRequest             : True
    AllowOutboundTimeExceeded           : False
    AllowOutboundParameterProblem       : False
    AllowOutboundSourceQuench           : False
    AllowInboundRouterRequest           : False
    AllowInboundTimestampRequest        : False
    AllowInboundMaskRequest             : False
    AllowOutboundPacketTooBig           : True
#>

##
# Start of script
##

# Set strict mode
Set-StrictMode -Version 2.0

# Set Constants
$NET_FW_PROFILE_DOMAIN   = 0
$NET_FW_PROFILE_STANDARD = 1

# Create the firewall manager object.
$fwMgr = New-Object -com HNetCfg.FwMgr

# Get the current profile for the local firewall policy.
$profile = $fwMgr.LocalPolicy.GetProfileByType($NET_FW_PROFILE_STANDARD)

# Display current ICMP settings
$Profile.IcmpSettings

# Now set it to True
$profile.IcmpSettings.AllowInboundEchoRequest = $True

# Use this line if you want to disable the setting.
#profile.IcmpSettings.AllowInboundEchoRequest = $FALSE

# Display it again
"After Script ran: "
$Profile.IcmpSettings

# End Script