# These are just examples to show how "dot sourcing"
# a script copies the functions from that script
# into the function:\ drive in PowerShell, e.g., run:
#
#     . .\dot-Functions.ps1
#


function hh ( $term ) { help $term -full }


function ping-host ( [string] $hostname ) {
    $p = new-object system.net.networkinformation.ping
    $p.send($hostName) 
}


function resolve-ip ( [string] $ipaddress ) {
    [System.Net.Dns]::GetHostByAddress($ipaddress)
}


function resolve-host ( [string] $hostname ) {
    [System.Net.Dns]::GetHostByName($hostname)
}

