####################################################################################
#.Synopsis 
#    Colorize the output of windump.exe (http://www.winpcap.org/windump/),
#    a command-line packet sniffer and protocol analyzer for Windows.
#
#.Description 
#    Run the script instead of windump.exe directly, or extract the 
#    colorize-windump() filter and pipe windump.exe into it. The various
#    fields of the packet traces, such as IP addresses and timestamps, will
#    be color-coded for easier reading and analysis.  Pass in command-line
#    options like normal, except that they must be placed in double-quotes.
#    Use the -Ask switch to be prompted for the correct adapter number. 
#    Requires PowerShell 2.0 or later (and windump.exe of course).
#
#.Parameter Options
#    The command-line arguments for windump.exe (in double-quotes).
#
#.Parameter Spacing
#    Number of blank lines printed between each packet displayed.
#
#.Parameter AskWhichAdapter
#    Will display the list of network adapters and prompt to choose one.
#
#.Example 
#    sniff
#
#.Example 
#	 sniff -ask
#
#.Example 
#    sniff "-X -v" -spacing 1 -ask
#
#Requires -Version 2.0 
#
#.Notes 
#  Author: Jason Fossen (http://blogs.sans.org/windows-security/)  
# Version: 1.2
# Updated: 10.Sep.2011
#   LEGAL: PUBLIC DOMAIN.  SCRIPT PROVIDED "AS IS" WITH NO WARRANTIES OR GUARANTEES OF 
#          ANY KIND, INCLUDING BUT NOT LIMITED TO MERCHANTABILITY AND/OR FITNESS FOR
#          A PARTICULAR PURPOSE.  ALL RISKS OF DAMAGE REMAINS WITH THE USER, EVEN IF
#          THE AUTHOR, SUPPLIER OR DISTRIBUTOR HAS BEEN ADVISED OF THE POSSIBILITY OF
#          ANY SUCH DAMAGE.  IF YOUR STATE DOES NOT PERMIT THE COMPLETE LIMITATION OF
#          LIABILITY, THEN DELETE THIS FILE SINCE YOU ARE NOW PROHIBITED TO HAVE IT.
####################################################################################
    
param ([String] $Options = "-n", [Int32] $Spacing = 0, [Switch] $AskWhichAdapter) 
 

function sniff ([String] $Options = "-n", [Int32] $Spacing = 0, [Switch] $AskWhichAdapter)
{
    #If windump.exe is not in your PATH environment variable, you can hard code it here.
    $windumppath = "windump.exe"

    filter colorize-windump 
    { 
        # CHANGE THE COLOR SCHEME HERE.  The available color names are:
        # Black, DarkBlue, DarkGreen, DarkCyan, DarkRed, DarkMagenta, White,
        # DarkYellow, Gray, DarkGray, Blue, Green, Cyan, Red, Magenta, Yellow

        $DefaultColor   = "white"       #Used when a line cannot be colorized.
        $GroundColor    = "black"       #Background color.
        $TimeColor      = "blue"        #Timestamps.
        $DstIpColor     = "green"       #Destination IP address, network or host.
        $DstPortColor   = "cyan"        #Destination port number.
        $SrcIpColor     = "green"       #Source IP address, network or host.
        $SrcPortColor   = "cyan"        #Source port number.
        $ProtoColor     = "red"         #Protocol, comes after the timestamp, e.g., "IP".
        $ChevronColor   = "red"         #The ">" character, separating source > destination.  
        $VerboseColor   = "magenta"     #For the stuff displayed by -v, -vv and -vvv
        $DetailsColor   = "yellow"      #Usually comes after the ":" near the end.
        $MultiLineColor = "gray"        #Such as -X, or anything that begins with a blank space or tab.

        #Backup copy of the original input, to be spat out in a parsing panic.
        $originalline = $_
        $ErrorActionPreference = "SilentlyContinue"
        trap { write-host $originalline -foreground $DefaultColor -background $GroundColor  ; return } 
        
        #If the line begins with blanks or a tab, print and return ASAP (perf optimization for -X).
        if ($_.startswith("  ") -or $_.startswith("`t"))  
        {
            write-host $originalline -foreground $MultiLineColor -background $GroundColor 
            return
        }

        #Extra spaces should be added, but not on -v or -X lines.
        if ($spacing -ne 0) { $originalline = ("`n" * $spacing) + $originalline }        
        
        #If the -v option was used, carve out that section, it messes up the other parsing.
        $verboseoption = $false
        if ( $_.contains(", length: ") -and ($_.contains("(tos 0x") -or $_.contains("(hlim ")))
        {
            $lastindex = $_.lastindexof(" > ")
            if ($lastindex -lt 0) { $lastindex = 0 }   #Sometimes there isn't a >, so force a non-match.
            $choppedline = $_.substring(0,$lastindex)  #There are parens after the last >, so slice out.
            if ( -not $($choppedline -match "\s+\(.+\)") ) { write-host $originalline -foreground $DefaultColor -background $GroundColor ; return } 
            $verboseoption = $matches[0]               #Changes from $false to $true too.
            $_ = $_.replace("$verboseoption","")       #This data is reinjected later.
        }        
        
        #Verbose option adds ": " to the line, so it had to be carved out before this line.
        #Split input line into left ($line[0]) and right sides ($line[1])
        $line = $_ -split ": ",2,"SimpleMatch"           

        
        #Special Case: ARP 
        if ($line.count -ne 2 -and $_.startswith("arp "))    #No timestamp.
        {
            if ($spacing -ne 0) { write-host ("`n" * $spacing) -nonewline }
            write-host "arp " -foreground $ProtoColor -background $GroundColor -nonewline
            write-host $_.substring(4) -foreground $DetailsColor -background $GroundColor 
            return
        }
        elseif ($line.count -ne 2 -and $_.contains(" arp "))  #Has timestamp.
        {
            $parts = $line -split " arp ",0,"SimpleMatch"
            if ($spacing -ne 0) { write-host ("`n" * $spacing) -nonewline }
            write-host $parts[0] -foreground $TimeColor -background $GroundColor -nonewline
            write-host " arp " -foreground $ProtoColor -background $GroundColor -nonewline
            write-host $parts[1] -foreground $DetailsColor -background $GroundColor 
            return
        }
 
  
        #Special Case: MPLS 
        if ($_.startswith("MPLS "))     #No timestamp.
        {
            if ($spacing -ne 0) { write-host ("`n" * $spacing) -nonewline }
            write-host "MPLS " -foreground $ProtoColor -background $GroundColor -nonewline
            write-host $_.substring(5) -foreground $DetailsColor -background $GroundColor 
            return
        }
        elseif ($_.contains(" MPLS "))  #Has timestamp.
        {
            $parts = $line -split " MPLS ",0,"SimpleMatch"
            if ($spacing -ne 0) { write-host ("`n" * $spacing) -nonewline }
            write-host $parts[0] -foreground $TimeColor -background $GroundColor -nonewline
            write-host " MPLS " -foreground $ProtoColor -background $GroundColor -nonewline
            write-host $parts[1] -foreground $DetailsColor -background $GroundColor 
            return
        }
        
        
        #Special Cases: ICMP and ESP 
        $icmp = $esp = $false   # This must be here, it's repeatedly called below.
        if ($_.contains(" ICMP")) { $icmp = $true }
        if ($_.contains(": ESP(spi=0x")) { $esp = $true } 
        
        
        # Catch anything else that can't be split at ": " and return original line.
        if ($line.count -ne 2 -and $icmp -eq $false) { write-host $originalline -foreground $DefaultColor -background $GroundColor ; return }   
        
        
        # Now try to chop up the $line into pieces (or emit original line if problems).
        # Yuck, what a nice reminder of why carving up text is a pain...
        # Also, we can't do too many special cases, performance and spaghetti code already a problem.
        
        #Split lefthand side ($line[0]) into sender and receiver (left > right)
        $sides = $line[0] -split " > ",0,"SimpleMatch"  
        if ($sides.count -ne 2) { write-host $originalline -foreground $DefaultColor -background $GroundColor ; return }
                
        #Split sender, which includes proto and possibly a timestamp.
        #Data here might look like "09:49:05.677110 IP 192.168.1.104.3389"
        $leftside = $sides[0] -split " ",0,"SimpleMatch"  
        if ($leftside.count -lt 2) { write-host $originalline -foreground $DefaultColor -background $GroundColor ; return } 
        
        #Split sender ip.port or hostname.port, but ICMP/ESP has no port.
        $leftsidedots = $leftside[-1] -split ".",0,"SimpleMatch"
        if ($leftsidedots.count -lt 2 -and -not ($icmp -or $esp)) { write-host $originalline -foreground $DefaultColor -background $GroundColor ; return } 
        
        #Split receiver ip.port or hostname.port, but ICMP/ESP has no port.
        $rightsidedots = $sides[1] -split ".",0,"SimpleMatch"  
        if ($rightsidedots.count -lt 2 -and -not ($icmp -or $esp)) { write-host $originalline -foreground $DefaultColor -background $GroundColor ; return } 
        
        
        #Now reconstruct and start printing fields with color...
        
        #Print extra line spaces, if any.
        if ($spacing -ne 0) { write-host ("`n" * $spacing) -nonewline } 
        
        #Print timestamp, if any.
        if ($leftside.count -gt 2)  #If so, there's a timestamp, if not "-t" option probably used.
        { 
            write-host $($leftside[0..$($leftside.count - 3)] -join " ") -foreground $TimeColor -background $GroundColor -nonewline  
            write-host " " -background $GroundColor -nonewline
        }
        
        #Print protocol, such as "IP" or "IP6".
        write-host $leftside[-2] -foreground $ProtoColor -background $GroundColor -nonewline
        write-host " " -background $GroundColor -nonewline

        #Print verbose option data (-v, -vv, -vvv) if any.
        if ($verboseoption) {write-host ($verboseoption.Trim() + " ") -foreground $VerboseColor -background $GroundColor -nonewline } 
        
        #Print source IP and port, but ICMP/ESP uses no port numbers.
        if ($icmp -or $esp)
        {
            write-host $($leftsidedots -join ".") -foreground $SrcIpColor -background $GroundColor -nonewline
        }
        else
        {
            write-host $($leftsidedots[0..($leftsidedots.count - 2)] -join ".") -foreground $SrcIpColor -background $GroundColor -nonewline
            write-host $("." + $leftsidedots[-1]) -foreground $SrcPortColor -background $GroundColor -nonewline 
        }
        
        #Print greater-than chevron for source > destination.
        write-host " > " -foreground $ChevronColor -background $GroundColor -nonewline
        
        #Print destination IP and port, but ICMP/ESP uses no port numbers.
        if ($icmp -or $esp)
        {
            write-host $($rightsidedots -join ".") -foreground $DstIpColor -background $GroundColor -nonewline
        }
        else
        {
            write-host $($rightsidedots[0..($rightsidedots.count - 2)] -join ".") -foreground $DstIpColor -background $GroundColor -nonewline
            write-host $("." + $rightsidedots[-1]) -foreground $DstPortColor -background $GroundColor -nonewline  
        }
        
        #Print the righthand side details after the ": " originally used to split the line.
        write-host (": " + $line[1]) -foreground $DetailsColor -background $GroundColor 
        
    } #End of Filter


    #The rest is a wrapper for windump.exe command-line args...
    
 
    #If the interface number was passed in as an option, then use that.
    #The -l switch buffers windump's output, making the script MUCH more responsive.
    if ($Options.contains("-i ") -or $Options.contains("-r "))  
    {
         "`nRunning Command: $windumppath -l $Options "
          invoke-expression "$windumppath -l $Options | colorize-windump"
    }
    else
    {
        #Specify an adapter manually or try to guess which to use.
        if ($AskWhichAdapter)
        {
            " "
            windump.exe -D
            $ifnum = read-host "`nWhich adapter number? " 
        } 
        else 
        {
            #You may wish to edit the pattern used to exclude adapters.
            $ifnum = @(windump.exe -D | select-string -NotMatch 'Virtual|TAP|VMware|Tunnel|Sun|\(Microsoft\)') 
            if ($ifnum.count -gt 0)
            {
                $ifnum = $ifnum[0].tostring().chars(0)
            }
            else
            {
                $ifnum = 1
            }
        }
    
        "`nRunning Command: $windumppath -i $ifnum -l $Options "
         invoke-expression "$windumppath -i $ifnum -l $Options | colorize-windump"
    }

} #End of Function




if ($AskWhichAdapter) { sniff -Options $Options -Spacing $Spacing -ask } 
else { sniff -Options $Options -Spacing $Spacing }  




