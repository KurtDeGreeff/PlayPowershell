####################################################################################
#.Synopsis 
#    Using the Windows Firewall, block all IP addresses listed in a text file.
#
#.Description 
#    Script will create inbound and outbound rules in the Windows Firewall to
#    block all the IPv4 and/or IPv6 addresses listed in an input text file.  IP
#    address ranges can be defined with CIDR notation (10.4.0.0/16) or with a
#    dash (10.4.0.0-10.4.255.255).  Comments and blank lines are ignored in the
#    input file.  The script deletes and recreates the rules each time the 
#    script is run, so don't edit the rules by hand.  Requires admin privileges.
#    Multiple rules will be created if the input list is large.  Requires
#    Windows Vista, Windows 7, Server 2008 or later operating system.  Blocking
#    thousands of ranges does not seem to impede performance, but will slow
#    the loading of the Windows Firewall snap-in and lengthen the time it takes
#    to disable/enable a network interface.
#
#.Parameter InputFile
#    File containing IP addresses and ranges to block; IPv4 and IPv6 supported.
#
#.Parameter RuleName
#    (Optional) Override default firewall rule name; default based on file name.
#    When used with -DeleteOnly, just give the rule basename without the "-#1".
#
#.Parameter ProfileType
#    (Optional) Comma-delimited list of network profile types for which the
#    blocking rules will apply: public, private, domain, any (default = any).
#
#.Parameter InterfaceType
#    (Optional) Comma-delimited list of interface types for which the
#    blocking rules will apply: wireless, ras, lan, any (default = any).
#
#.Parameter DeleteOnly
#    (Switch) Matching firewall rules will be deleted, none will be created.
#    When used with -RuleName, leave off the "-#1" at the end of the rulename.
#
#.Example 
#    import-firewall-blocklist.ps1 -inputfile IpToBlock.txt
#
#.Example 
#    import-firewall-blocklist.ps1 -inputfile IpToBlock.txt -deleteonly
#
#.Example 
#    import-firewall-blocklist.ps1 -rulename IpToBlock -deleteonly
#
#Requires -Version 1.0 
#
#.Notes 
#  Author: Jason Fossen (http://blogs.sans.org/windows-security/)  
# Version: 1.0
# Updated: 27.May.2011
#   LEGAL: PUBLIC DOMAIN.  SCRIPT PROVIDED "AS IS" WITH NO WARRANTIES OR GUARANTEES OF 
#          ANY KIND, INCLUDING BUT NOT LIMITED TO MERCHANTABILITY AND/OR FITNESS FOR
#          A PARTICULAR PURPOSE.  ALL RISKS OF DAMAGE REMAINS WITH THE USER, EVEN IF
#          THE AUTHOR, SUPPLIER OR DISTRIBUTOR HAS BEEN ADVISED OF THE POSSIBILITY OF
#          ANY SUCH DAMAGE.  IF YOUR STATE DOES NOT PERMIT THE COMPLETE LIMITATION OF
#          LIABILITY, THEN DELETE THIS FILE SINCE YOU ARE NOW PROHIBITED TO HAVE IT.
####################################################################################
    
param ($InputFile = "BlockList.txt", $RuleName, $ProfileType = "any", $InterfaceType = "any", [Switch] $DeleteOnly)

# Get input file and set the name of the firewall rule.
$file = get-item $InputFile -ErrorAction SilentlyContinue # Sometimes rules will be deleted by name and there is no file.
if (-not $? -and -not $DeleteOnly) { "`nCannot find $InputFile, quitting...`n" ; exit } 
if (-not $rulename) { $rulename = $file.basename }  # The '-#1' will be appended later.

# Description will be seen in the properties of the firewall rules.
$description = "Rule created by script. Do not edit rule by hand, it will be overwritten when the script is run again. By default, the name of the rule is named after the input file."

# Any existing firewall rules which match the name are deleted every time the script runs.
"`nDeleting any inbound or outbound firewall rules named like '$rulename-#*'`n"
$currentrules = netsh.exe advfirewall firewall show rule name=all | select-string '^Rule Name:\s+(.+$)' | foreach { $_.matches[0].groups[1].value } 
if ($currentrules.count -lt 3) {"`nProblem getting a list of current firewall rules, quitting...`n" ; exit } 
$currentrules | foreach { if ($_ -like "$rulename-#*"){ netsh.exe advfirewall firewall delete rule name="$_" | out-null } } 

# Don't create the firewall rules again if the -DeleteOnly switch was used.
if ($deleteonly -and $rulename) { "`nWhen deleting by name, leave off the '-#1' at the end of the rulename.`n" } 
if ($deleteonly) { exit } 

# Create array of IP ranges; any line that doesn't start like an IPv4/IPv6 address is ignored.
$ranges = get-content $file | where {($_.trim().length -ne 0) -and ($_ -match '^[0-9a-f]{1,4}[\.\:]')} 
if (-not $?) { "`nCould not parse $file, quitting...`n" ; exit } 
$linecount = $ranges.count
if ($linecount -eq 0) { "`nZero IP addresses to block, quitting...`n" ; exit } 

# Now start creating rules with hundreds of IP address ranges per rule.  Testing shows
# that netsh.exe errors begin to occur with more than 400 IPv4 ranges per rule, and you
# may find that this number is still too large when using IPv6 or IPstart-IPend formats (ymmv).
$i = 1      # Rule number counter, when more than one rule must be created, e.g., BlockList-#1.
$start = 1  # For array slicing out of IP $ranges.
$end = 400  # For array slicing out of IP $ranges; larger numbers cause random errors...
do {
    if ($end -gt $linecount) { $end = $linecount } 
    $textranges = [System.String]::Join(",", $($ranges[$($start - 1)..$($end - 1)]) ) 

    "`nCreating an inbound firewall rule named '$rulename-#$i' for IP ranges $start - $end" 
    netsh.exe advfirewall firewall add rule name="$rulename-#$i" dir=in action=block localip=any remoteip="$textranges" description="$description" profile="$profiletype" interfacetype="$interfacetype"
    if (-not $?) { "`nFailed to create '$rulename-#$i' inbound rule for some reason, continuing anyway..."}
    
    "`nCreating an outbound firewall rule named '$rulename-#$i' for IP ranges $start - $end" 
    netsh.exe advfirewall firewall add rule name="$rulename-#$i" dir=out action=block localip=any remoteip="$textranges" description="$description" profile="$profiletype" interfacetype="$interfacetype"
    if (-not $?) { "`nFailed to create '$rulename-#$i' outbound rule for some reason, continuing anyway..."}
    
    $i++
    $start += 400
    $end += 400
} while ($start -le $linecount)



# END-O-SCRIPT
