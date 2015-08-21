#Copy DHCP module under new directory Microsoft.DHCP.PowerShell.Admin in $PSHome\modules
import-module -Name Microsoft.DHCP.PowerShell.Admin

#Use DHCP-Command to see all cmdlets

#Get local DHCP server
$DhcpServer = Get-DHCPServer -Server "$env:computername"
# $DhcpServer | Set-DHCPOption -OptionID 60 -DataType String -Value "PXEClient"

# Create Scope
$Scope =  $Dhcpserver | New-DhcpScope -Address 10.5.21.0 -SubnetMask 255.255.255.0 -Name LocalScope
$Scope = $Scope | Add-DHCPIPRange -StartAddress 10.5.21.1 -EndAddress 10.5.21.254
$Scope = $Scope | Add-DHCPExclusionRange -StartAddress 10.5.21.143 -EndAddress 10.5.21.143
$Scope = $SCope | Set-DHCPScopeLease -Seconds 691200

# Set Default Gateway for Scope
$Scope = $Scope | Set-DHCPOption -OptionID 3 -DataType IPADDRESS -Value 10.5.21.200

# Set DNS server
$Scope = $Scope | Set-DHCPOption -OptionID 6 -DataType IPADDRESS -Value 10.5.7.119

# Set DNS Domain Name
$Scope = $Scope | Set-DHCPOption -OptionID 15 -DataType String -Value "pol.be"

# Set PXEClient
$Scope = $Scope | Set-DHCPOption -OptionID 60 -DataType String -Value "PXEClient"


# $Scope = $DhcpServer.scopes[0]
# New-DHCPReservation -scope $Scope -IPAddress 10.5.21.142 -MACAddress 0015C5B18C6C
# $Scope

# Add reservations from file
$a = Get-Content C:\ipmac.txt
$10521 = $a | Select-String "10.5.21"
$10521 | ForEach-Object {$s = -split $_ ; New-DHCPReservation -Scope $Scope -IPAddress $s[0] -MACAddress $s[1]}

# Enable/Disable DHCP Scope
# $scope | Disable-DHCPScope
# $scope | Enable-DHCPScope
# $scope = $scope.State


