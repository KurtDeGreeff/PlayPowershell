<#
.SYNOPSIS
    This script displays each Firewall Authorised Application
.DESCRIPTION
    This script gets the list of authorised applications, then
    displays them. This is a re-write of a MSDN Script written in
    VBScript.
.NOTES
    File Name  : Get-FWAuthorisedApplications.ps1
	Author     : Thomas Lee - tfl@psp.co.uk
	Requires   : PowerShell Version 2.0
.LINK
    This script posted to:
	    http://www.pshscripts.blogspot.com
    MSDN Sample posted at:
	    http://msdn.microsoft.com/en-us/library/aa366181%28VS.85%29.aspx
.EXAMPLE
    PSH [C:\foo]: . 'C:\Users\tfl\AppData\Local\Temp\Untitled6.ps1'
    2 Authorised Applications:
      Name:          : Delivery Manager Service
      Image Filename : C:\Program Files (x86)\Kontiki\KService.exe
      IP Version     : ANY
      Scope          : All subnets
      RemoteAddresses: *
      Enabled        : True
    
      Name:          : BitTorrent
      Image Filename : C:\Program Files (x86)\BitTorrent\bittorrent.ex
      IP Version     : ANY
      Scope          : All subnets
      RemoteAddresses: *
      Enabled        : True
#>

##
# Start of script
##

# IP Version Constants
$NET_FW_IP_VERSION_V4 = 0
$NET_FW_IP_VERSION_V4_NAME = "IPv4"
$NET_FW_IP_VERSION_V6 = 1
$NET_FW_IP_VERSION_V6_NAME = "IPv6"
$NET_FW_IP_VERSION_ANY = 2
$NET_FW_IP_VERSION_ANY_NAME = "ANY"

# Scope constants
$NET_FW_SCOPE_ALL = 0
$NET_FW_SCOPE_ALL_NAME = "All subnets"
$NET_FW_SCOPE_LOCAL_SUBNET = 1
$NET_FW_SCOPE_LOCAL_SUBNET_NAME = "Local subnet only"
$NET_FW_SCOPE_CUSTOM = 2
$NET_FW_SCOPE_CUSTOM_NAME = "Custom Scope (see RemoteAddresses)"

# Create the firewall manager object
$fwMgr = new-object -com HNetCfg.FwMgr

# Get the current profile for the local firewall policy
$profile = $fwMgr.LocalPolicy.CurrentProfile

#Display authorised applications

"{0} Authorised Applications:" -f $profile.AuthorizedApplications.Count
foreach ($app in $profile.AuthorizedApplications) {

	"  Name:          : {0}" -f $app.Name
	"  Image Filename : {0}" -f $app.ProcessImageFileName

	switch ($app.IpVersion) {
		$NET_FW_IP_VERSION_V4  {"  IP Version     : {0}" -f $NET_FW_IP_VERSION_V4_NAME}
		$NET_FW_IP_VERSION_V6  {"  IP Version     : {0}" -f $NET_FW_IP_VERSION_V6_NAME}
		$NET_FW_IP_VERSION_ANY {"  IP Version     : {0}" -f $NET_FW_IP_VERSION_ANY_NAME}
	}
	switch ($app.Scope) {
		$NET_FW_SCOPE_ALL          {"  Scope          : {0}" -f $NET_FW_SCOPE_ALL_NAME}
		$NET_FW_SCOPE_LOCAL_SUBNET {"  Scope          : {0}" -f $NET_FW_SCOPE_LOCAL_SUBNET_NAME}
		$NET_FW_SCOPE_CUSTOM       {"  Scope          : {0}" -f $NET_FW_SCOPE_CUSTOM_NAME}
	}
	"  RemoteAddresses: {0}" -f $app.RemoteAddresses
	"  Enabled        : {0}" -f $app.Enabled
	""
} 
