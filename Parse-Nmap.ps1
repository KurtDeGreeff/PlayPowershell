Param ($Path, [String] $OutputDelimiter = "`n", [Switch] $RunStatsOnly, [Switch] $ShowProgress)

function parse-nmap 
{
	####################################################################################
	#.Synopsis 
	#    Parse XML output files of the nmap port scanner (www.nmap.org). 
	#
	#.Description 
	#    Parse XML output files of the nmap port scanner (www.nmap.org) and  
	#    emit custom objects with properties containing the scan data. The 
	#    script can accept either piped or parameter input.  The script can be
	#    safely dot-sourced without error as is. 
	#
	#.Parameter Path  
	#    Either 1) a string with or without wildcards to one or more XML output
	#    files, or 2) one or more FileInfo objects representing XML output files.
	#
	#.Parameter OutputDelimiter
	#    The delimiter for the strings in the OS, Ports and Services properties. 
	#    Default is a newline.  Change it when you want single-line output. 
	#
	#.Parameter RunStatsOnly
	#    Only displays general scan information from each XML output file, such
	#    as scan start/stop time, elapsed time, command-line arguments, etc.
	#
	#.Parameter ShowProgress
	#    Prints progress information to StdErr while processing host entries.    
	#
	#.Example 
	#    dir *.xml | .\parse-nmap.ps1
	#
	#.Example 
	#	 .\parse-nmap.ps1 -path onefile.xml
	#    .\parse-nmap.ps1 -path *files.xml 
	#
	#.Example 
	#    $files = dir *some.xml,others*.xml 
	#    .\parse-nmap.ps1 -path $files    
	#
	#.Example 
	#    .\parse-nmap.ps1 -path scanfile.xml -runstatsonly
	#
	#.Example 
	#    .\parse-nmap.ps1 scanfile.xml -OutputDelimiter " "
	#
	#Requires -Version 1.0 
	#
	#.Notes 
	#  Author: Jason Fossen (http://blogs.sans.org/windows-security/)  
	# Version: 3.5 
	# Updated: 23.May.2010
	#   LEGAL: PUBLIC DOMAIN.  SCRIPT PROVIDED "AS IS" WITH NO WARRANTIES OR GUARANTEES OF 
	#          ANY KIND, INCLUDING BUT NOT LIMITED TO MERCHANTABILITY AND/OR FITNESS FOR
	#          A PARTICULAR PURPOSE.  ALL RISKS OF DAMAGE REMAINS WITH THE USER, EVEN IF
	#          THE AUTHOR, SUPPLIER OR DISTRIBUTOR HAS BEEN ADVISED OF THE POSSIBILITY OF
	#          ANY SUCH DAMAGE.  IF YOUR STATE DOES NOT PERMIT THE COMPLETE LIMITATION OF
	#          LIABILITY, THEN DELETE THIS FILE SINCE YOU ARE NOW PROHIBITED TO HAVE IT.
	####################################################################################

	param ($Path, [String] $OutputDelimiter = "`n", [Switch] $RunStatsOnly, [Switch] $ShowProgress)
	
	if ($Path -match "/\?|/help|-h|-help|--h|--help") 
	{ 
		"`nPurpose: Process nmap XML output files (www.nmap.org).`n"
		"Example: .\parse-nmap.ps1 scanfile.xml"
        "Example: .\parse-nmap.ps1 *.xml -runstatsonly `n"
		exit 
	}

	if ($Path -eq $null) {$Path = @(); $input | foreach { $Path += $_ } } 
	if (($Path -ne $null) -and ($Path.gettype().name -eq "String")) {$Path = dir $path} #To support wildcards in $path.  
	$1970 = [DateTime] "01 Jan 1970 01:00:00 GMT"

	if ($RunStatsOnly)
	{
		ForEach ($file in $Path) 
		{
			$xmldoc = new-object System.XML.XMLdocument
			$xmldoc.Load($file)
			$stat = ($stat = " " | select-object FilePath,FileName,Scanner,Profile,ProfileName,Hint,ScanName,Arguments,Options,NmapVersion,XmlOutputVersion,StartTime,FinishedTime,ElapsedSeconds,ScanTypes,TcpPorts,UdpPorts,IpProtocols,SctpPorts,VerboseLevel,DebuggingLevel,HostsUp,HostsDown,HostsTotal)
			$stat.FilePath = $file.fullname
			$stat.FileName = $file.name
			$stat.Scanner = $xmldoc.nmaprun.scanner
			$stat.Profile = $xmldoc.nmaprun.profile
			$stat.ProfileName = $xmldoc.nmaprun.profile_name
			$stat.Hint = $xmldoc.nmaprun.hint
			$stat.ScanName = $xmldoc.nmaprun.scan_name
			$stat.Arguments = $xmldoc.nmaprun.args
			$stat.Options = $xmldoc.nmaprun.options
			$stat.NmapVersion = $xmldoc.nmaprun.version
			$stat.XmlOutputVersion = $xmldoc.nmaprun.xmloutputversion
			$stat.StartTime = $1970.AddSeconds($xmldoc.nmaprun.start) 	
			$stat.FinishedTime = $1970.AddSeconds($xmldoc.nmaprun.runstats.finished.time)
			$stat.ElapsedSeconds = $xmldoc.nmaprun.runstats.finished.elapsed
            
            $xmldoc.nmaprun.scaninfo | foreach {
                $stat.ScanTypes += $_.type + " "
                $services = $_.services  #Seems unnecessary, but solves a problem. 

                if ($services.contains("-"))
                {
                    #In the original XML, ranges of ports are summarized, e.g., "500-522", 
                    #but the script will list each port separately for easier searching.
                    $array = $($services.replace("-","..")).Split(",")
                    $temp  = @($array | where { $_ -notlike "*..*" })  
                    $array | where { $_ -like "*..*" } | foreach { invoke-expression "$_" } | foreach { $temp += $_ } 
                    $temp = [Int32[]] $temp | sort 
                    $services = [String]::Join(",",$temp) 
                } 
                    
                switch ($_.protocol)
                {
                    "tcp"  { $stat.TcpPorts  = $services ; break }
                    "udp"  { $stat.UdpPorts  = $services ; break }
                    "ip"   { $stat.IpProtocols = $services ; break }
                    "sctp" { $stat.SctpPorts = $services ; break }
                }
            } 
            
            $stat.ScanTypes = $($stat.ScanTypes).Trim()
            
			$stat.VerboseLevel = $xmldoc.nmaprun.verbose.level
			$stat.DebuggingLevel = $xmldoc.nmaprun.debugging.level		
			$stat.HostsUp = $xmldoc.nmaprun.runstats.hosts.up
			$stat.HostsDown = $xmldoc.nmaprun.runstats.hosts.down		
			$stat.HostsTotal = $xmldoc.nmaprun.runstats.hosts.total
			$stat 			
		}
		return #Don't process hosts.  
	}
	
	ForEach ($file in $Path) {
		If ($ShowProgress) { [Console]::Error.WriteLine("[" + (get-date).ToLongTimeString() + "] Starting $file" ) }

		$xmldoc = new-object System.XML.XMLdocument
		$xmldoc.Load($file)
		
		# Process each of the <host> nodes from the nmap report.
		$i = 0  #Counter for <host> nodes processed.
		$xmldoc.nmaprun.host | foreach-object { 
			$hostnode = $_   # $hostnode is a <host> node in the XML.
		
			# Init variables, with $entry being the custom object for each <host>. 
			$service = " " #service needs to be a single space.
			$entry = ($entry = " " | select-object FQDN, HostName, Status, IPv4, IPv6, MAC, Ports, Services, OS, Script) 

			# Extract state element of status:
			$entry.Status = $hostnode.status.state.Trim() 
			if ($entry.Status.length -lt 2) { $entry.Status = "<no-status>" }

			# Extract fully-qualified domain name(s).
			$hostnode.hostnames | foreach-object { $entry.FQDN += $_.hostname.name + " " } 
			$entry.FQDN = $entry.FQDN.Trim()
			if ($entry.FQDN.Length -eq 0) { $entry.FQDN = "<no-fullname>" }

			# Note that this code cheats, it only gets the hostname of the first FQDN if there are multiple FQDNs.
			if ($entry.FQDN.Contains(".")) { $entry.HostName = $entry.FQDN.Substring(0,$entry.FQDN.IndexOf(".")) }
			elseif ($entry.FQDN -eq "<no-fullname>") { $entry.HostName = "<no-hostname>" }
			else { $entry.HostName = $entry.FQDN }

			# Process each of the <address> nodes, extracting by type.
			$hostnode.address | foreach-object {
				if ($_.addrtype -eq "ipv4") { $entry.IPv4 += $_.addr + " "}
				if ($_.addrtype -eq "ipv6") { $entry.IPv6 += $_.addr + " "}
				if ($_.addrtype -eq "mac")  { $entry.MAC  += $_.addr + " "}
			}        
			if ($entry.IPv4 -eq $null) { $entry.IPv4 = "<no-ipv4>" } else { $entry.IPv4 = $entry.IPv4.Trim()}
			if ($entry.IPv6 -eq $null) { $entry.IPv6 = "<no-ipv6>" } else { $entry.IPv6 = $entry.IPv6.Trim()}
			if ($entry.MAC  -eq $null) { $entry.MAC  = "<no-mac>" }  else { $entry.MAC  = $entry.MAC.Trim() }


			# Process all ports from <ports><port>, and note that <port> does not contain an array if it only has one item in it.
			if ($hostnode.ports.port -eq $null) { $entry.Ports = "<no-ports>" ; $entry.Services = "<no-services>" } 
			else 
			{
				$hostnode.ports.port | foreach-object {
					if ($_.service.name -eq $null) { $service = "unknown" } else { $service = $_.service.name } 
					$entry.Ports += $_.state.state + ":" + $_.protocol + ":" + $_.portid + ":" + $service + $OutputDelimiter 
                    # Build Services property. What a mess...but exclude non-open/non-open|filtered ports and blank service info, and exclude servicefp too for the sake of tidiness.
                    if ($_.state.state -like "open*" -and ($_.service.tunnel.length -gt 2 -or $_.service.product.length -gt 2 -or $_.service.proto.length -gt 2)) { $entry.Services += $_.protocol + ":" + $_.portid + ":" + $service + ":" + ($_.service.product + " " + $_.service.version + " " + $_.service.tunnel + " " + $_.service.proto + " " + $_.service.rpcnum).Trim() + " <" + ([Int] $_.service.conf * 10) + "%-confidence>$OutputDelimiter" }
				}
				$entry.Ports = $entry.Ports.Trim()
                if ($entry.Services -eq $null) { $entry.Services = "<no-services>" } else { $entry.Services = $entry.Services.Trim() }
			}


			# Extract fingerprinted OS type and percent of accuracy.
			$hostnode.os.osmatch | foreach-object {$entry.OS += $_.name + " <" + ([String] $_.accuracy) + "%-accuracy>$OutputDelimiter"} 
            $hostnode.os.osclass | foreach-object {$entry.OS += $_.type + " " + $_.vendor + " " + $_.osfamily + " " + $_.osgen + " <" + ([String] $_.accuracy) + "%-accuracy>$OutputDelimiter"}  
            $entry.OS = $entry.OS.Replace("  "," ")
            $entry.OS = $entry.OS.Replace("<%-accuracy>","") #Sometimes no osmatch.
			$entry.OS = $entry.OS.Trim()
			if ($entry.OS.length -lt 16) { $entry.OS = "<no-os>" }

            
            # Extract script output, first for port scripts, then for host scripts.
            $hostnode.ports.port | foreach-object {
                if ($_.script -ne $null) { 
                    $entry.Script += "<PortScript id=""" + $_.script.id + """>$OutputDelimiter" + ($_.script.output -replace "`n","$OutputDelimiter") + "$OutputDelimiter</PortScript> $OutputDelimiter $OutputDelimiter" 
                }
            } 
            
            if ($hostnode.hostscript -ne $null) {
                $hostnode.hostscript.script | foreach-object {
                    $entry.Script += '<HostScript id="' + $_.id + '">' + $OutputDelimiter + ($_.output.replace("`n","$OutputDelimiter")) + "$OutputDelimiter</HostScript> $OutputDelimiter $OutputDelimiter" 
                }
            }
            
            if ($entry.Script -eq $null) { $entry.Script = "<no-script>" } 
    
    
			# Emit custom object from script.
			$i++  #Progress counter...
			$entry
		}

		If ($ShowProgress) { [Console]::Error.WriteLine("[" + (get-date).ToLongTimeString() + "] Finished $file, processed $i entries." ) }
	}
}



if ($path -eq $null) { $path = @(); $input | foreach { $Path += $_ } } #Piping issues...

if ($showprogress) {parse-nmap -path $Path -showprogress -OutputDelimiter $OutputDelimiter}
elseif ($runstatsonly) {parse-nmap -path $Path -runstatsonly -OutputDelimiter $OutputDelimiter}
else { parse-nmap -path $Path -OutputDelimiter $OutputDelimiter} 



