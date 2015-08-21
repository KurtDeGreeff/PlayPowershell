#Requires -Version 2.0 
function New-PrinterPort{
<# 
   .SYNOPSIS 
        Create a TCPIP printer port on a remote or local computer

   .DESCRIPTION
        Creates a new TCPIP printer port

   .EXAMPLE 
        New-PrinterPort -Name 1.2.3.4 -HostAddress 1.2.3.4

        Description
        -----------
        Creates a printer port on the local computer using the name and address 1.2.3.4
        This port will use the following default values:
        
        Protocol:    1 (RAW)
        PortNumber:  9100
        SNMP:        Disabled

   .EXAMPLE 
        New-PrinterPort -Name IP_1.2.3.4 -HostAddress 1.2.3.4 -Protocol 1 -PortName 9100 -SNMPEnabled $false -Computername SERVERNAME

        Description
        -----------
        Creates a printer port on the remote computer SERVERNAME using the name IP_1.2.3.4 and the IP address 1.2.3.4
        This port will be configured to use RAW port 9100 with SNMP disabled.
          
   .PARAMETER Name
     The name of the TCPIP printer port

   .PARAMETER HostAddress
     The IP address of the TCPIP printer port

   .PARAMETER Protocol
     The protocol used for the printer port (1 = RAW, 2 = LPR)
     Default is 1

   .PARAMETER PortNumber
     The port number for the printer port
     Default is 9100

   .PARAMETER SNMPEnabled
     Specifies whether SNMP is enabled (True) or disabled (False)
     Default is Disabled

   .PARAMETER ComputerName
     The host on which you would like to create the TCPIP printer port.

   .NOTES
        NAME: New-PrinterPort 
        AUTHOR: robertmcdonnell
        KEYWORDS: New-PrinterPort
    
   .LINK 
        http://www.verb-noun.com

#> 
[CmdletBinding()]
param (
 [string]$ComputerName = ".",

 [parameter(ValueFromPipeline = $true,
   ValueFromPipelineByPropertyName = $true,
   Mandatory = $true)]
 [string]$Name,
 
 [parameter(ValueFromPipeline=$true,
   ValueFromPipelineByPropertyName=$true)]
 [bool]$SNMPEnabled = $false,
 
 [parameter(ValueFromPipeline = $true,
   ValueFromPipelineByPropertyName = $true)]
 [int]$Protocol = 1,
 
 [parameter(ValueFromPipeline = $true,
   ValueFromPipelineByPropertyName = $true)]
 [int]$PortNumber = 9100,
 
 [parameter(ValueFromPipeline = $true,
   ValueFromPipelineByPropertyName = $true,
   Mandatory = $true)]
 [string]$HostAddress
)
PROCESS
    {
    $port = ([WMICLASS]"\\$ComputerName\ROOT\cimv2:Win32_TCPIPPrinterPort").createInstance()
    $port.Name = $Name
    $port.HostAddress = $HostAddress
    $port.Protocol = $Protocol
    $port.PortNumber = $PortNumber
    $port.SNMPEnabled = $SNMPEnabled
    $port.Put()
    $port
    }
}