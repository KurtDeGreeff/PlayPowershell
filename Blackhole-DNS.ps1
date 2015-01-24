####################################################################################
#.Synopsis 
#    Creates and deletes blackhole domains in Windows DNS servers. 
#
#.Description 
#    Script takes fully-qualified domain names (FQDNs) and/or simple domain
#    names, then uses them to create primary zones (not Active Directory
#    integrated) in a Windows DNS server, setting all zones to resolve to a
#    single chosen IP address.  The IP address might be "0.0.0.0" or the IP  
#    of an internal server configured for logging.  The intention is to 
#    prevent clients from resolving the correct IP address of unwanted FQDNs
#    and domain names, such as for malware and phishing sites.  Such names
#    are said to be "blackholed" since they often resolve to 0.0.0.0.    
#
#.Parameter InputFile  
#    Path to a file which contains the FQDNs and domain names to blackhole.
#    File can have blank lines, comment lines (# or ;), multiple FQDNs or
#    domains per line (space- or comma-delimited), and can be a hosts file 
#    with IP addresses too (addresses and localhost entires will be ignored).  
#    You can also include wildcards to input multiple files, e.g., 
#    "*bad*.txt", or pass in an array of file objects instead of a string.  
#
#.Parameter Domain
#    One or more FQDNs or domains to blackhole, separated by spaces or commas.
#
#.Parameter BlackHoleIP
#    The IP address to which all blackholed names will resolve.  The
#    default is "0.0.0.0", but perhaps is better set to an internal server.
#    Remember, there is only one IP for ALL the blackholed domains.
#
#.Parameter DnsServerName
#    FQDN of the Windows DNS server.  Defaults to localhost.  If specified,
#    please always use a fully-qualified domain name (FQDN), especially if
#    the DNS server is a stand-alone or in a different domain.
#
#.Parameter IncludeWildCard
#    Will add a wildcard host record (*) to every blackhole domain, which 
#    will match all possible hostnames within that domain.  Keep in mind
#    that blackholing "www.sans.org" will treat the "www" as a domain
#    name, so a wildcard is not needed to match it; but blackholing just
#    "sans.org" will not match "www.sans.org" or "ftp.sans.org" without
#    the wildcard.  If you only want to blackhole the exact FQDN or domain
#    name supplied to the script, then don't include a wildcard record.  
#    If you are certain that you do not want to resolve anything whatsoever
#    under the blackholed domains, then include the wildcard DNS record.
#
#.Parameter ReloadBlackHoleDomains
#    Will cause every blackholed domain in your DNS server to re-read the
#    one shared zone file they all use.  This is the zone file for the
#    000-blackholed-domain.local domain.  Keep in mind that the DNS
#    graphical management tool shows you what is cached in memory, not
#    what is in the zone file.  Reload the blackhole domains if you,
#    for example, change the blackhole IP address.  Using this switch
#    causes any other parameters to be ignored.
#
#.Parameter DeleteBlackHoleDomains
#    Will delete all blackhole domains, but will not delete any regular 
#    non-blackhole domains.  Strictly speaking, this deletes any domain 
#    which uses a zone file named "000-blackholed-domain.local.dns".
#    The zone file itself is not deleted, but it only 1KB in size.  
#    Using this switch causes any other parameters to be ignored.
#
#.Parameter RemoveLeadingWWW
#    Some lists of blackhole names are simple domain names, while other
#    lists might prepend "www." to the beginning of many of the names.
#    Use this switch to remove the "www." from the beginning of any
#    name to be blackholed, then consider using -IncludeWildCard too.
#    Note that "www.", "www1.", "www2." ... "www9." will be cut too, 
#    but only for a single digit after the "www" part (1-9 only).
#
#.Parameter Credential
#    An "authority\username" string to explicitly authenticate to the
#    DNS server instead of using single sign-on with the current
#    identity.  The authority is either a server name or a domain name.
#    You will be prompted for the passphrase.  You can also pass in
#    a variable with a credential object from Get-Credential.
#    
#.Example 
#    .\Blackhole-DNS.ps1 -Domain "www.sans.org"
#    
#    This will create a primary DNS domain named "www.sans.org"
#    which will resolve to "0.0.0.0".  DNS server is local.  
#
#.Example 
#    .\Blackhole-DNS.ps1 -Domain "www.sans.org" -BlackHoleIP "10.1.1.1"
#
#    This will create a primary DNS domain named "www.sans.org"
#    which will resolve to "10.1.1.1".  DNS server is local.
#
#.Example 
#    .\Blackhole-DNS.ps1 -InputFile file.txt -IncludeWildCard
#
#    This will create DNS domains out of all the FQDNs and domain
#    names listed in file.txt, plus add a wildcard (*) record.
#
#.Example 
#    .\Blackhole-DNS.ps1 -ReloadBlackHoleDomains
#
#    Perhaps after changing the blackhole IP address, this will cause
#    all blackholed domains to re-read their shared zone file.
#
#.Example 
#    .\Blackhole-DNS.ps1 -DeleteBlackHoleDomains
#
#    This will delete all blackholed domains, but will not delete
#    any other domains.  This does not delete the blackhole zone file.
#
#.Example
#    .\Blackhole-DNS.ps1 -InputFile file.txt -DnsServerName `
#            "server7.sans.org" -Credential "server7\administrator"
#
#    This will create blackholed domains from file.txt on a remote
#    DNS server named "server7.sans.org" with explicit credentials.
#    You will be prompted for the passphrase.   
#
#.Example
#    $Cred = Get-Credential -Credential "server7\administrator"
#
#    .\Blackhole-DNS.ps1 -InputFile *evil*.txt `
#         -DnsServerName "server7.sans.org" -Credential $Cred
#
#    This will create blackholed domains from *evil*.txt on a remote
#    DNS server named "server7.sans.org" with explicit credentials 
#    supplied in a credential object ($Cred) which can be reused again.
#    Multiple input files may match "*evil*.txt".  
#
#Requires -Version 2.0 
#
#.Notes 
#  Author: Jason Fossen (http://www.sans.org/windows-security/)  
# Version: 1.0 
# Updated: 30.Aug.2010
#   LEGAL: PUBLIC DOMAIN.  SCRIPT PROVIDED "AS IS" WITH NO WARRANTIES OR 
#          GUARANTEES OF ANY KIND, INCLUDING BUT NOT LIMITED TO 
#          MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.  ALL 
#          RISKS OF DAMAGE REMAINS WITH THE USER, EVEN IF THE AUTHOR, 
#          SUPPLIER OR DISTRIBUTOR HAS BEEN ADVISED OF THE POSSIBILITY OF
#          ANY SUCH DAMAGE.  IF YOUR STATE DOES NOT PERMIT THE COMPLETE 
#          LIMITATION OF LIABILITY, THEN DELETE THIS FILE SINCE YOU ARE 
#          NOW PROHIBITED TO HAVE IT.  TEST ON NON-PRODUCTION SERVERS.
####################################################################################


Param ($InputFile, [String] $Domain, [String] $BlackHoleIP = "0.0.0.0", [String] $DnsServerName = ".", [Switch] $IncludeWildCard, 
       [Switch] $ReloadBlackHoleDomains, [Switch] $DeleteBlackHoleDomains, [Switch] $RemoveLeadingWWW, $Credential) 


# Check for common help switches.
if (($InputFile -ne $Null) -and ($InputFile.GetType().Name -eq "String") -and ($InputFile -match "/\?|-help|--h|--help"))
{ 
    If ($Host.Version.Major -ge 2) { get-help -full .\blackhole-dns.ps1 }
    Else {"`nPlease read this script's header in Notepad for the help information."}
    Exit 
}


# Confirm PowerShell 2.0 or later.
 If ($Host.Version.Major -lt 2) { "This script requires PowerShell 2.0 or later.`nDownload the latest version from http://www.microsoft.com/powershell`n" ; Exit }


# If necessary, prompt user for domain\username and a passphrase.
If ($Credential) { $Cred = Get-Credential -Credential $Credential } 
 
 
Function Main
{

# Test access to WMI at target server ($ZoneClass is used later too). 
$ZoneClass = GetWMI -Query "SELECT * FROM META_CLASS WHERE __CLASS = 'MicrosoftDNS_Zone'" 
If (-not $? -or $ZoneClass.Name -ne "MicrosoftDNS_Zone") { Throw("Failed to connect to WMI service or the WMI DNS_Zone namespace!") ; Exit } 


##### Parse input domains, but exclude the following: localhost, any IP addresses, blank lines.
#Process any -Domain args.
[Object[]] $Domains = @($Domain -Split "[\s\;\,]")    

#Process any -InputFile arguments and expand any wildcards.
If (($InputFile -ne $Null) -and ($InputFile.GetType().Name -eq "String")) { $InputFile = dir $InputFile }   
If ($InputFile -ne $Null) { $InputFile | ForEach { $Domains += Get-Content $_ | Where { $_ -notmatch "^[\#\;\<]" } | ForEach { $_ -Split "[\s\;\,]" } } }  

#If -RemoveLeadingWWW was used, edit out those "www." strings.
If ($RemoveLeadingWWW) { 0..$([Int] $Domains.Count - 1) | ForEach { $Domains[$_] = $Domains[$_] -Replace "^www[1-9]{0,1}\.","" } } 

#Convert to lowercase, remove redundants, exclude blank lines, exclude IPs, exclude anything with a colon in it, e.g., IPv6.
$Domains = $Domains | ForEach { $_.Trim().ToLower() } | Sort -Unique | Where { $_.Length -ne 0 -and $_ -notmatch "^localhost$|^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}|\:" } 
If ($Domains.Count -le 0) { "No domains specified!" ; exit } Else { "`n" + [String] $Domains.Count + " domain(s) to blackhole to $BlackHoleIP." }
#####  


##### Get or create the master blackhole zone: 000-blackholed-domain.local.
$WmiPath = "Root\MicrosoftDNS:MicrosoftDNS_Zone.ContainerName='000-blackholed-domain.local',DnsServerName='" + $DnsServerName + "',Name='000-blackholed-domain.local'"

If (InvokeWmiMethod -ObjectPath $WmiPath -MethodName GetDistinguishedName) #Zone exists.
{ 
    "`nThe 000-blackholed-domain.local zone already exists, deleting its existing DNS records." 
    $ExistingRecords = @(GetWMI -Query "SELECT * FROM MicrosoftDNS_AType WHERE ContainerName = '000-blackholed-domain.local'")
    If (-not $?) { Throw("Failed to query the A records of the 000-blackholed-domain.local domain!") ; exit }
    If ($ExistingRecords.Count -gt 0) { $ExistingRecords | ForEach { $_.Delete() } }  
}
Else #Zone does not exist.
{
    "`nCreating the 000-blackholed-domain.local zone and its zone file."
    $RR = $ZoneClass.CreateZone("000-blackholed-domain.local",0,$false,$null,$null,"only-edit.000-blackholed-domain.local.")
    If (-not $? -or $RR.__CLASS -ne "__PARAMETERS") 
    { 
        If ($Credential -And ($DnsServerName.Length -ne 0) -And ($DnsServerName -NotLike "*.*")) { "Did you forget to use a FQDN for the DNS server name?" }
        Throw("Failed to create the 000-blackholed-domain.local domain!")
        Exit 
    } 
}
#####  


##### Create DNS records in master blackhole zone.
# Create the default A record with the blackhole IP address.
$RecordClass = $Null  # Defaults to "IN" class of record.
$TTL = 120            # Seconds. Defaults to zone default if you set this to $null.
$ATypeRecords = GetWMI -Query "SELECT * FROM META_CLASS WHERE __CLASS = 'MicrosoftDNS_AType'" 
If (-not $? -or $ATypeRecords.Name -ne "MicrosoftDNS_AType") { "`nFailed to query A type records, but continuing..." }
$ARecord = $ATypeRecords.CreateInstanceFromPropertyData($DnsServerName,"000-blackholed-domain.local","000-blackholed-domain.local",$RecordClass,$TTL,$BlackHoleIP)
If ($?) { "Created default DNS record for the 000-blackholed-domain.local zone ($BlackHoleIP)." } 
Else { "Failed to create default A record for the 000-blackholed-domain.local zone, but continuing..." }

# Create the wildcard A record if the -IncludeWildCard switch was used.
If ($IncludeWildCard) 
{ 
    $ARecord = $ATypeRecords.CreateInstanceFromPropertyData($DnsServerName,"000-blackholed-domain.local","*.000-blackholed-domain.local",$RecordClass,$TTL,$BlackHoleIP) 
    If ($?) { "Created the wildcard (*) record for the 000-blackholed-domain.local zone ($BlackHoleIP)." } 
    Else { "Failed to create the wildcard (*) record for the 000-blackholed-domain.local zone, but continuing..." }  
}

# Update zone data file on disk after adding the A record(s).
If (InvokeWmiMethod -ObjectPath $WmiPath -MethodName WriteBackZone) 
{ "Updated the zone file for 000-blackholed-domain.local." }
Else 
{ 
    Start-Sleep -Seconds 2 #Just seems to help... 
    $ItWorked = InvokeWmiMethod -ObjectPath $WmiPath -MethodName WriteBackZone
    If ($ItWorked) { "Updated the zone file for 000-blackholed-domain.local." }
    Else {"`nFailed to update the server data file for the 000-blackholed-domain.local zone, but continuing..." }
} 
##### 


##### Create the blackholed domains using the 000-blackholed-domain.local.dns zone file.
$Created = $NotCreated = 0
$CurrentErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = "SilentlyContinue"
$Domains | ForEach `
{ 
    $ZoneClass.CreateZone($_,0,$false,"000-blackholed-domain.local.dns",$null,"only-edit.000-blackholed-domain.local.") | Out-Null 
    If ($?) { $Created++ } Else { $NotCreated++ }
} 
$ErrorActionPreference = $CurrentErrorActionPreference
"`nBlackhole domains created at the DNS server: $Created"
"`nDomains NOT created (maybe already existed): $NotCreated`n"

} #End of Main



Function GetWMI ([String] $Query)
{
# This is a helper function for the sake of -Credential.
If ($Credential) { Get-WmiObject -Query $Query -Namespace "Root/MicrosoftDNS" -ComputerName $DnsServerName -Credential $Cred }
Else { Get-WmiObject -Query $Query -Namespace "Root/MicrosoftDNS" -ComputerName $DnsServerName }
}



Function InvokeWmiMethod ([String] $ObjectPath, [String] $MethodName)
{
# This is a helper function for the sake of -Credential.
$ErrorActionPreference = "SilentlyContinue"
If ($Credential) { Invoke-WmiMethod -Path $ObjectPath -Name $MethodName -ComputerName $DnsServerName -Credential $Cred }
Else { Invoke-WmiMethod -Path $ObjectPath -Name $MethodName -ComputerName $DnsServerName }
$? #Returns
}



Function Reload-BlackHoledDomains
{
# Function causes blackholed domains to be reloaded from the shared master zone file, perhaps after a -BlackHoleIP change.
# You may get errors if zone is temporarily locked for updates, but the DNS server's default lock is only two minutes. 
"`nReloading blackholed domains from the 000-blackholed-domain.local.dns zone file, `nwhich may take a few minutes if you have 10K+ domains..."
$BHDomains = @(GetWMI -Query "SELECT * FROM MicrosoftDNS_Zone WHERE DataFile = '000-blackholed-domain.local.dns'")
If (-not $?) { Throw("Failed to connect to WMI service!") ; exit  }
"`nBlackholed domains to be reloaded from the zone file: " + [String] $BHDomains.Count 
$Locked = @() #Index numbers of zones which are temporarily locked and cannot be reloaded yet.
$i = 0
$ErrorActionPreference = "SilentlyContinue"
If ($BHDomains.Count -gt 0) { $BHDomains | ForEach { $_.ReloadZone() ; If (-not $?) { $Locked += $i } ; $i++ } } 
If ($Locked.Count -gt 0) 
{ 
    "`n" + [String] $Locked.Count + " zone(s) are still temporarily locked, will try those again in two minutes.`nPlease wait two minutes or hit Ctrl-C to cancel..."
    Start-Sleep -Seconds 60
    "Just one more minute... Thank you for holding, your function call is appreciated."
    Start-Sleep -Seconds 30
    "Just 30 more seconds... Your patience is admirable, and you're good looking too!"
    Start-Sleep -Seconds 35
    $Locked | ForEach { $BHDomains[$_].ReloadZone() ; if (-not $?) { "`n" + [String] $BHDomains[$_].ContainerName + " is still locked and has not reloaded yet." } } 
}

"`nThe other blackholed domains were successfully reloaded.`n" 
} #End



Function Delete-BlackHoledDomains
{
# Delete all blackholed zones, including 000-blackholed-domain.local, but
#  note that this does not delete the (tiny) zone file on the drive.
"`nDeleting all blackholed domains, which may take a few minutes if you have 10K+ domains..."
$BHDomains = @(GetWMI -Query "SELECT * FROM MicrosoftDNS_Zone WHERE DataFile = '000-blackholed-domain.local.dns'") 
If (-not $?) { Throw("Failed to connect to WMI service!") ; exit  }
"`nBlackhole domains to be deleted: " + [String] $BHDomains.Count 
$i = 0
If ($BHDomains.Count -gt 0) { $BHDomains | ForEach { $_.Delete() ; If ($?){$i++} } }
"Blackhole domains deleted count: $i`n"
} #End




########################
#        MAIN          #
########################
If ($ReloadBlackHoleDomains) { Reload-BlackHoledDomains ; Exit } 
If ($DeleteBlackHoleDomains) { Delete-BlackHoledDomains ; Exit } 
Main



