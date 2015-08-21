####################################################################################
#.Synopsis 
#    Adds domain names to the HOSTS file for blocking.  Find the HOSTS
#    file at $env:systemroot\system32\drivers\etc\hosts 
#
#.Description 
#    The HOSTS text file is typically used for name resolution before any
#    DNS queries are performed.  This script can import the names from one
#    or multiple text files into the local HOSTS file for blocking correct
#    resolution of those names.  The input file(s) can be on the local drive,
#    in shared folders, or on HTTP servers.  By default, names will resolve
#    to "0.0.0.0", but a different IP address can be specified.  You must be
#    a member of the local Administrators group to use the script (or at
#    least be granted NTFS write access to the HOSTS file itself).  
#
#.Parameter FilePathOrURL
#    Path to a file which contains the FQDNs and domain names to blackhole.
#    File can have blank lines, comment lines (# or ;), multiple FQDNs or
#    domains per line (space- or comma-delimited), and can be a HOSTS file 
#    with IP addresses too (addresses and localhost entires will be ignored).  
#    You can also include wildcards to input multiple files (e.g., "bad*.txt"), 
#    use a UNC path to an SMB shared folder (e.g., "\\server\share\file.txt")
#    or an HTTP path; in fact, you can mix all these path together into one
#    long space-delimited string for this parameter.  The parameter will
#    default to "http://www.malwaredomainlist.com/hostslist/hosts.txt" if
#    left unspecified. 
#
#.Parameter AddDuplicateWWW
#    When adding names to the HOSTS file, if any name does not begin with
#    "www.", then this switch will add that name twice to the HOSTS file:
#    the original unaltered name and a second copy with "www." prepended.
#    Many browsers will automatically prepend "www." to any name which
#    results in an error or cannot be resolved correctly.
#
#.Parameter ResetToDefaultHostsFile
#    Will erase the HOSTS file and add only two entries back to it:
#           127.0.0.1   localhost
#           ::1         localhost
#
#.Parameter EditHostsFile
#    Opens the HOSTS file in Notepad.exe.
#
#.Parameter ShowHostNameCount
#    Displays a count of the number of names in the HOSTS file, not
#    including the localhost entries.
#
#.Parameter ShowHostsFilePath
#    As specified in the registry, displays the path to the folder which
#    contains the hosts file.  Malware and hackers change this sometimes.
#    Prints a warning if it is not the default path.
#
#.Example 
#    Update-HostsFile.ps1
#
#    Adds all the names from www.MalwareDomainList.com to your HOSTS file 
#    and makes them all resolve to "0.0.0.0".
#
#.Example 
#    Update-HostsFile.ps1 -FilePathOrURL "c:\folder\file.txt \\server\ `
#    share\remotefile.txt http://www.malwaredomainlist.com/hostslist `
#    /hosts.txt" -BlackHoleIP "10.1.1.1"
#
#    Blackholes all the names listed in file.txt, remotefile.txt, and all the 
#    names from the URL shown, then makes them all resolve to "10.1.1.1".
#    Notice that each path is separated by a space character.  
#
#.Example 
#    Update-HostsFile.ps1 -ResetToDefaultHostsFile
#
#    Erase the HOSTS file and then add back only the following:
#           127.0.0.1   localhost
#           ::1         localhost
#
#.Notes 
#  Author: Jason Fossen (http://blogs.sans.org/windows-security/)  
# Version: 1.3
# Updated: 9.Sep.2011
#   LEGAL: PUBLIC DOMAIN.  SCRIPT PROVIDED "AS IS" WITH NO WARRANTIES OR 
#          GUARANTEES OF ANY KIND, INCLUDING BUT NOT LIMITED TO 
#          MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.  ALL 
#          RISKS OF DAMAGE REMAINS WITH THE USER, EVEN IF THE AUTHOR, 
#          SUPPLIER OR DISTRIBUTOR HAS BEEN ADVISED OF THE POSSIBILITY OF
#          ANY SUCH DAMAGE.  IF YOUR STATE DOES NOT PERMIT THE COMPLETE 
#          LIMITATION OF LIABILITY, THEN DELETE THIS FILE SINCE YOU ARE 
#          NOW PROHIBITED TO HAVE IT.  TEST ON NON-PRODUCTION SERVERS.
#Requires -Version 2.0 
####################################################################################


Param ($FilePathOrURL = "http://mirror1.malwaredomains.com/files/justdomains",
       [String] $BlackholeIP = "0.0.0.0", 
       [Switch] $ResetToDefaultHostsFile, 
       [Switch] $AddDuplicateWWW,
       [Switch] $EditHostsFile, 
       [Switch] $ShowHostNameCount,
       [Switch] $ShowHostsFilePath)

       
function update-hostsfile 
{
    Param ($FilePathOrURL = "http://mirror1.malwaredomains.com/files/justdomains",
           [String] $BlackholeIP = "0.0.0.0", 
           [Switch] $ResetToDefaultHostsFile, 
           [Switch] $AddDuplicateWWW,           
           [Switch] $EditHostsFile, 
           [Switch] $ShowHostNameCount,
           [Switch] $ShowHostsFilePath)           
           
    $HostsFilePath = "$env:systemroot\system32\drivers\etc\hosts"
    $webclient = new-object System.Net.WebClient
    $names = @() #Array of names to add to HOSTS file.
    
    # Check for common help switches and show help text.
    if (($FilePathOrURL -ne $null) -and ($FilePathOrURL.GetType().Name -eq "String") -and ($FilePathOrURL -match "/\?|/help|-help|--h|--help"))
    { 
        If ($Host.Version.Major -ge 2) { get-help -full .\update-hostsfile.ps1 }
        Else {"`nPlease read this script's header in Notepad for the help information."}
        return 
    }

    # Confirm PowerShell 2.0 or later.
    If ($Host.Version.Major -lt 2) { "This script requires PowerShell 2.0 or later.`nDownload the latest version from http://www.microsoft.com/powershell`n" ; return }

    #Edit hosts file in notepad?
    if ($EditHostsFile) { notepad.exe $HostsFilePath ; return }
    
    #Show path to hosts file? Sometimes modified by malware.
    if ($ShowHostsFilePath)
    {
        $folder = (Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\services\Tcpip\Parameters -Name DataBasePath).DataBasePath
        "`nAs defined in the registry, the hosts file folder is:`n`n `t $folder `n"
        if ($folder -eq "$env:SystemRoot\System32\drivers\etc")
        { "This is the default folder path.`n" }
        else
        { "CAUTION! THIS IS NOT THE DEFAULT LOCATION! POSSIBLE MALWARE INDICATOR! `n" } 
        return
    }
    
    #Show count of names in hosts file? Does not include localhost entries, but will include non-blackhole names.
    if ($ShowHostNameCount) 
    { "`nCount of names in hosts file = " + ($(get-content $HostsFilePath) -split " " | 
      where { $_ -notmatch '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}|\:|localhost|^\s*$|^\#' }).count ; "`n" ; return }
    
    
    #Check if we're just resetting the hosts file to the default localhosts. 
    if ($ResetToDefaultHostsFile) 
    { 
        #Sometimes a full CRLF newline (0x0D,0x0A) is not appended 
        #unless we do these lines separately (weird).  
        "127.0.0.1 localhost"  | set-content $HostsFilePath -force
        "::1 localhost"  | add-content $HostsFilePath -force
        if (-not $?) { "Error writing to hosts file!" } 
        return 
    } 
    
    #Get one or more space-delimited input files, split up into the $names array.
    #If the path contains spaces, use the 8.3 DOS short name, e.g., PROGRA~1.
    $FilePathOrURL = @(( $FilePathOrURL -split '\s+' ) | foreach { $_.trim() } | where { $_.length -gt 1 } )
    if ($FilePathOrURL.Count -eq 0) { "No valid paths to input files, quitting." ; return }
    
    $FilePathOrURL | foreach { `
        if ($_ -like "http*")
        {
            $string = $webclient.DownloadString("$_")
            #This check might be too crude...
            if ($string.contains("</") -or -not $?)
            {   
                "`nDownload failure: " + $_ + "`n" 
            }
            else
            {   
                "`nDownloaded: " + $_ + "`n"
                $names += $string -split '[\r\n]+' 
            }  
        }
        else
        {
            if (test-path $_)
            {
                $names += get-content -path $_ 
                if ($?) { "`nImported: " + $_ + "`n" }  
                else { "`nImport failure: " + $_ + "`n" } 
            }
            else
            {   "`nInvalid path: " + $_ + "`n" } 
        }
    }
    
    #Confirm that at least one line was imported.
    if ($names.count -lt 1) { "`nNothing to add to the hosts file, quitting." ; return } 

    #Remove anything after a comment char (# or ;) on each line, including the comment char. 
    $names = $names | foreach { if ($_.IndexOfAny("#;") -ne -1) { $_.Remove($_.IndexOfAny("#;")) } else { $_ } }
    
    #Split the IPs from the names; maybe this file has no IPs in it.
    $names = $names -split '[\,\s]+' 
    
    #Filter out blanks, IPv4/IPv6 addresses and localhost, then remove duplicates
    $names = $names | foreach {$_.Trim()} | where { $_.Length -gt 1 } | where { $_ -notmatch '\:|^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$|^localhost$' } | sort-object -unique   
    
    #If requested, add "www.*" entries for names which don't begin with "www" already.
    if ($AddDuplicateWWW){ $names = $names += ($names | where {$_ -notmatch '^www\.'} | foreach {"www." + $_ }) }
    
    #In the hosts file, each line should have a max of nine hostnames, ending with a CRLF.
    #Lookup performance is maximized by having nine hostnames per line and by 
    #resolving to 0.0.0.0 instead of 127.0.0.1, especially if you're listening on TCP/80.
    $size = $names.count - 1
    for ($i = 0 ; $i -lt $size ; $i = $i + 9)
    { $output += "$BlackholeIP " + ($names[$i..$($i + 8)] -join " ") + [char]13 + [char]10 }
    
    #Sometimes a full CRLF newline (0x0D,0x0A) is not appended 
    #unless we do these two lines separately (weird). The all-zeros
    #line is added for the sake of tools doing reverse lookups.
    "127.0.0.1 localhost"  | set-content $HostsFilePath -force
    "::1 localhost"  | add-content $HostsFilePath -force
    "0.0.0.0 zero.zero.zero.zero" | add-content $HostsFilePath -force
    if (-not $?) { "Error writing to hosts file!" ; return } 
    $output | add-content $HostsFilePath -force
}


       
# Main       
if ($ResetToDefaultHostsFile) { update-hostsfile -ResetToDefaultHostsFile } 
elseif ($EditHostsFile) { update-hostsfile -EditHostsFile } 
elseif ($ShowHostNameCount) { update-hostsfile -ShowHostnameCount }
elseif ($ShowHostsFilePath) { update-hostsfile -ShowHostsFilePath } 
else 
{ 
    if ($AddDuplicateWWW) { update-hostsfile -FilePathOrURL $FilePathOrURL -BlackholeIP $BlackholeIP -AddDuplicateWWW } 
    else {update-hostsfile -FilePathOrURL $FilePathOrURL -BlackholeIP $BlackholeIP }
} 



