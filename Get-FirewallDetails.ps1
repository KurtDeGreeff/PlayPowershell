<#
.SYNOPSIS
    Gets details of Windows Firewall (on Vista and Server 2008 or later)  
.DESCRIPTION
    Uses HNetCfg.FwMgr com object to get and display firewall details for local machine.      
.NOTES
    File Name  : Get-FirewallDetails.ps1
	Author     : Thomas Lee - tfl@psp.co.uk
	Requires   : PowerShell V2 CTP3
.HISTORY
    First published : 20.12.2008
    Updated         : 8.8.2009 - validated for Verstion 2, added links
.LINK
    This script posted to: 
        http://pshscripts.blogspot.com/2008/12/get-firewalldetailsps1.html
.EXAMPLE
    PS c:\foo .\get-firewalldetails.ps1
	(output varies depending on your setup)
.PARAMETER bar
#>


##
#  Start of script
##
 
# First create COM object for policy profile and get host name
$profile = (new-object -com HNetCfg.FwMgr).LocalPolicy.CurrentProfile
$Hostname=hostname

# Is firewall enabled?
if ($profile.FirewallEnabled) {
"Firewall is enabled on system {0}" -f $Hostname
}
else {
"Firewall is NOT enabled on system {0}" -f $Hostname
}

# Exceptions allowed?
if ($profile.ExceptionsNotAllowed) {"Exceptions NOT allowed"} 
else {"Exceptions are allowed"}

# Notifications?
if ($profile.NotificationsDisabled) {"Notifications are disabled"}
else {"Notifications are not disabled"}

# Display determine global open ports 
$ports = $profile.GloballyOpenPorts 
if (!$ports -or $ports.count -eq 0) {
"There are no global open ports"
}
else {
"There are {0} open ports as follows:" -f $ports.count
$ports
}
""

# Display ICMP settings
"ICMP Settings:"
$profile.IcmpSettings

# Display authorised applications
$apps = $profile.AuthorizedApplications 
#
if (!$apps) {
 "There are no authorised applications"
}
else {
 "There are {0} global applications as follows:" -f $apps.count
 $apps 
}

# Display authorised services
$services = $profile.services
#
if (!$services) {
 "There are no authorised services"
}
else {
 "There are {0} authorised services as follows:" -f $services.count
 $services
}
# End of script