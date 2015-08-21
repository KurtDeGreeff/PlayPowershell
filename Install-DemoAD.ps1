<#Before running this script make sure your server has a static ip
$ipaddress = '192.168.0.1'
$defGateway = '192.168.0.254'
$ifIndex = (Get-NetIPInterface -InterfaceAlias 'ethernet 2' -AddressFamily IPv4).ifIndex
New-NetIPAddress -InterfaceIndex $ifIndex -IPAddress $ipaddress -PrefixLength 24 -DefaultGateway $defGateway
Set-DnsClientServerAddress -InterfaceIndex $ifIndex -ServerAddresses $ipaddress,127.0.0.1
#>

#This script will install a test Active Directory

Param(

[string]$DomainName='Fedpol.local',

[string]$DomainNETBIOSName='FEDPOL',

[string]$Password='ChangeMe12!'

)

# Add Domain Services to Server

INSTALL-WindowsFeature AD-Domain-Services –IncludeManagementTools -IncludeAllSubFeature

Import-module ADDSDeployment


# Reset local Administrator password to one defined above

NET USER Administrator $Password


# Install our new Forest. (Choose appropriate forest/domain functional level)

Install-ADDSForest –SkipPreChecks –CreateDnsDelegation:$False –DatabasePath 'C:\Windows\NTDS' `
–DomainMode 'Win2012' –DomainName $DomainName –DomainNetbiosname $DomainNETBIOSName `
–ForestMode 'Win2012' –InstallDns:$True –Logpath 'C:\Windows\NTDS' –NoRebootOnCompletion:$True `
–SysvolPath 'C:\Windows\SYSVOL' –SafeModeAdministratorPassword (CONVERTTO-SecureString $Password –asplaintext –force) –force

# Restart and  done

RESTART-COMPUTER –force