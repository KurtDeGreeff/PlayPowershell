# PowerShell script to map drives using New-PSDrive command. 
# Prompts once for credentials, then uses them. Or so we hope. 
# 
# Initial: 10 June, 2012 
#
# Start by checking for already mapped drives. We’ll use Get-WMIObject to query Win32_LogicalDisk.
# A drivetype of 4 means that the drive is a network drive.
$NetDrives = Get-WMIObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq 4 }
 
# Check which servers have drives mapped to them.
$Srv1Mapped = $NetDrives | Where-Object {$_.ProviderName -match "srv1" } 
$wssMapped = $NetDrives | Where-Object { $_.ProviderName -match "wss-100" }
 
# Prompt for credentials and store in a variable. 
$Contoso = Get-Credential -Cred "CONTOSO\Charlie"
# Now, map drives based on that credential 
# First, drives on SRV1. These are general Contoso resources 
if ($Srv1Mapped ) { 
   Echo "Skipping core maps on SRV1" 
} else { 
   New-PSDrive -Name I –root \\srv1\install    -scope Global -PSProv FileSystem -Cred $Contoso –Persist 
   New-PSDrive -Name J -root \\srv1\Download   -scope Global -PSProv FileSystem -Cred $Contoso -Persist 
}
# Now, shared drives for the home resources 
if ($wssMapped ) { 
   Echo "Skipping Home maps on Windows Storage Server WSS-100" 
} else { 
   New-PSDrive -Name M -root \\wss-100\Music    -scope Global -PSProv FileSystem -Cred $Contoso -Persist 
   New-PSDrive -Name P -root \\wss-100\Pictures -scope Global -PSProv FileSystem -Cred $Contoso -Persist 
   New-PSDrive -Name V -root \\wss-100\Videos   -scope Global -PSProv FileSystem -Cred $Contoso -Persist 
}
# Finally, some specialized resources 
   New-PSDrive -Name W -root \\srv1\Working     -scope Global -PSProv FileSystem -Cred $Contoso -Persist 
   New-PSDrive -Name U -root \\srv1\Charlie     -scope Global -PSProv FileSystem -Cred $Contoso -Persist 
   New-PSDrive -Name Y -root \\hp180-ts-17\RemoteApps -scope Global -PSProv FileSystem -Cred $Contoso -Persist 
}