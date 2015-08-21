function Trace-Route {
	<#
        .SYNOPSIS
            Trace the route between source computer and a target machine.
        .DESCRIPTION
            Trace the route between source computer and a target machine.
        .EXAMPLE
            Trace-Route Computer01
            Perform trace route to Computer01
        .EXAMPLE
            Trace-Route -Target www.microsoft.com -ResolveHostname
            Perform trace route to www.microsoft.com and try to resolve hostname for each hop.
            Note! This will slow down the function somewhat.
        .NOTES
            Author: Øyvind Kallstad
            Date: 28.10.2014
            Version: 1.1
	#>
	[CmdletBinding()]
	param(
        # Hostname or IP to trace to.
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        [string] $Target = $env:COMPUTERNAME,

        # Set starting hop.
        [Parameter()]
        [int] $BeginHop = 1,
 
        # Set maximum number of hops.
        [Parameter()]
        [int] $MaxHops = 30,
 
        # Define timeout in milliseconds.
        [Parameter()]
        [int] $Timeout = 1000,
 
        # Try to resolve hostname for IP in each hop.
        [Parameter()]
        [switch] $ResolveHostname = $false
	)
 
	# verify that we can reach target system
    try{
        $ping = New-Object System.Net.NetworkInformation.Ping
        $pingResult = $ping.Send($Target)
 
        if(-not($pingResult.Status -eq 'Success')){
            Write-Warning "Unable to resolve target system $Target"
            exit
        }
    }
    catch{
        Write-Warning "Unable to resolve target system $Target"
        exit
    }
 
    # define some data to send
    $sendBytes = @([byte][char]'a'..[byte][char]'z')
 
    for($i = $BeginHop; $i -lt $MaxHops; $i++) {
        # define ping options; set start hop and fragmentation to true
        $pingOptions = new-object System.Net.NetworkInformation.PingOptions $i, $true
 
        # perform ping
        $pingReply = $ping.Send($Target, $Timeout, $sendBytes, $pingOptions)
 
        # get ip for current hop if possible
        if($pingReply.Address -ne $null){
            $ip = $pingReply.Address
        }
        else{
            $ip = '*'
        }
 
        # get roundtrip time
        $roundtripTime = $pingReply.RoundtripTime
 
        # get status
        $hopStatus = $pingReply.Status
 
        # resolve hostname
        if ($ResolveHostname) {
            try{
                $resolvedHostname = "[$(([System.Net.Dns]::GetHostEntry($ip)).HostName)]"
            }
            catch{
                $resolvedHostname = ''
            }
        }
 
        # create custom object and send to pipeline
        Write-Output ([PSCustomObject] [Ordered] @{
            Hop           = $i.ToString()
            IP            = "$($ip) $($resolvedHostname)"
            Status        = $hopStatus
            RoundtripTime = $roundtripTime
        })
 
        # clean up
        Remove-Variable ip, roundtripTime, hopStatus, resolvedHostname -ErrorAction 'SilentlyContinue'
 
        # stop loop if current ip matches the target ip
        if($pingReply.Address -eq $pingResult.Address){break}
    }
}