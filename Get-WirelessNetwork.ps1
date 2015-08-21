function Get-WirelessNetwork
{
<#
.SYNOPSIS
    Displays wireless nettwork information
.DESCRIPTION
    This cmdlet will show you the authentication level of a wireless network. Use showpassword
    to display password in clear text
.PARAMETER SSID
    The SSID of the wireless network
.PARAMETER ShowPassword
    Switch to display the password for the network
.EXAMPLE
    Get-WirelessNetwork -SSID mywifi

    Show authlevel for the wireless networkk mywifi
.EXAMPLE
    Get-WirelessNetwork -SSID mywifi -ShowPassword

    Display the password
   
.NOTES 
     SMART
     AUTHOR: Tore Groneng tore@firstpoint.no @toregroneng tore.groneng@gmail.com
#>
[cmdletbinding()]
Param(
    [Parameter(Mandatory=$true)]
    [string] $SSID
    ,
    [switch] $ShowPassword
   
)
    $output = "" | Select SSID, Authentication, Password
    
    $lan = netsh wlan show profiles name="$SSID" key=clear

    $arr = $lan -split " : "

    $arr = $arr | foreach { $_.trim()}

    $output.SSID = $arr[($arr.indexof("Name") + 1)]
    $output.Authentication = $arr[($arr.indexof("Authentication") + 1)]
    $output.Password = $arr[($arr.indexof("Key Content") + 1)]

    if(-not $ShowPassword)
    {
        $output.Password = $null
    }

    $output
}