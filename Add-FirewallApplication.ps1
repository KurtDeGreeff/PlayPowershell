   <#
.SYNOPSIS
    This script adds a program to the firewall.
.DESCRIPTION
    This script used the firewall com object to add
    a new application to the firewall. 	
.NOTES
    File Name  : Add-FirewallApplication.ps1
	Author     : Thomas Lee - tfl@psp.co.uk
	Requires   : PowerShell Version 2.0
.LINK
    This script posted to:
	    http://pshscripts.blogspot.com/2010/03/add-firewallapplicationps1.html
    MSDN Sample posted at:
	    http://msdn.microsoft.com/en-us/library/aa366421%28VS.85%29.aspx
.EXAMPLE
	At start of script, authorised applications are:

    Name                               ProcessImageFileName                                                         Enabled
    ----                               --------------------                                                         -------
    Delivery Manager Service           C:\Program Files (x86)\Kontiki\KService.exe                                     True
    BitTornado                         C:\Program Files (x86)\BitTornado\btdownloadgui.exe                             True
    driver                             C:\Windows\SysWOW64\svchost.exe                                                 True
    driver                             C:\Windows\SysWOW64\svchost.exe                                                 True
    Microsoft Office Live Meeting 2007 C:\Program Files (x86)\Microsoft Office\Live Meeting 8\Console\PWConsole.exe    True
    BitTorrent                         C:\Program Files (x86)\BitTorrent\bittorrent.exe                                True
    DNA                                C:\Program Files (x86)\DNA\btdna.exe                                            True
    Microsoft Office OneNote           C:\Program Files (x86)\Microsoft Office\Office12\ONENOTE.EXE                    True

    After adding Notepad - here are authorised applications

   Name                               ProcessImageFileName                                                         Enabled
   ----                               --------------------                                                         -------
    Notepad                            C:\Windows\notepad.exe                                                          True
    Delivery Manager Service           C:\Program Files (x86)\Kontiki\KService.exe                                     True
    BitTornado                         C:\Program Files (x86)\BitTornado\btdownloadgui.exe                             True
    driver                             C:\Windows\SysWOW64\svchost.exe                                                 True
    driver                             C:\Windows\SysWOW64\svchost.exe                                                 True
    Microsoft Office Live Meeting 2007 C:\Program Files (x86)\Microsoft Office\Live Meeting 8\Console\PWConsole.exe    True
    BitTorrent                         C:\Program Files (x86)\BitTorrent\bittorrent.exe                                True
    DNA                                C:\Program Files (x86)\DNA\btdna.exe                                            True
    Microsoft Office OneNote           C:\Program Files (x86)\Microsoft Office\Office12\ONENOTE.EXE                    True
#>

##
# Start of script
##

# Set constants
$NET_FW_PROFILE_DOMAIN = 0
$NET_FW_PROFILE_STANDARD = 1

# Scope
$NET_FW_SCOPE_ALL = 0

# IP Version - ANY is the only allowable setting for now
$NET_FW_IP_VERSION_ANY = 2

# Create the firewall manager object.
$fwMgr = new-object -com HNetCfg.FwMgr

# Get the current profile for the local firewall policy.
$profile = $fwMgr.LocalPolicy.CurrentProfile

# Display applications available
"At start of script, authorised applications are:"
$profile.AuthorizedApplications | ft name, processimagefilename, enabled -AutoSize

# Create application to add to firewall
$app = New-Object -com HNetCfg.FwAuthorizedApplication
$app.ProcessImageFileName = "C:\windows\notepad.exe"
$app.Name = "Notepad"
$app.Scope = $NET_FW_SCOPE_ALL

# Use either Scope or RemoteAddresses, but not both
# $app.RemoteAddresses = "*"
$app.IpVersion = $NET_FW_IP_VERSION_ANY
$app.Enabled = $TRUE

# Use this line if you want to add the app, but disabled.
# $app.Enabled = FALSE
$profile.AuthorizedApplications.Add($app)

# Show applications after addition
"After adding Notepad - here are authorised applications"
$profile.AuthorizedApplications | ft name, processimagefilename, enabled -AutoSize
# End of script