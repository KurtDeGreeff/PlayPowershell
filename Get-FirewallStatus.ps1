<#
.SYNOPSIS
    This script gets the status of the host firewall
    and ensures the firewall IS running!
.DESCRIPTION
    This script gets the status and displays it to the
    console. The script also turns on the firewall if it's
    currently off. It's a simpler script than in MSDN for VBScript!
.NOTES
    File Name  : Get-FirewallStatus.ps1
	Author     : Thomas Lee - tfl@psp.co.uk
	Requires   : PowerShell Version 2.0
.LINK
    This script posted to:
	    http://www.pshscripts.blogspot.com
    MSDN Sample posted at:
	    http://msdn.microsoft.com/en-us/library/aa366442%28VS.85%29.aspx
.EXAMPLE
    PSH [C:\foo]: .\Get-FirewallStatus.ps1
    Firewall Enabled               : True
    Firewall Exceptions Not Allowed: False
#>

##
# Start Script
##
 
# Create the firewall manager object.
$fwMgr = New-Object -com HNetCfg.FwMgr
 
# Get the current profile for the local firewall policy.
$profile = $fwMgr.LocalPolicy.CurrentProfile
 
# Verify that the Firewall is enabled. If it isn't, then enable it.
if (!$profile.FirewallEnabled) 
    {profile.FirewallEnabled = $TRUE}

# Display details
"Firewall Enabled               : {0}" -f $profile.FirewallEnabled
"Firewall Exceptions Not Allowed: {0}" -f $profile.ExceptionsNotAllowed
# End Script