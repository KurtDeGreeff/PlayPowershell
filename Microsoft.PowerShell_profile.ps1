# This is a sample profile script.  Not all the paths may be correct for your machine,
# especially if you have 64-bit Windows and you have Progra~2 instead of Progra~1 below.


$CurrentWindowsID = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$CurrentPrincipal = new-object System.Security.Principal.WindowsPrincipal($CurrentWindowsID)
if ($CurrentPrincipal.IsInRole("Administrators")) { $UacElevated = $True } else { $UacElevated = $False }

if ( $UacElevated ) 
{
    # Set your colors when running as an elevated user.
    [system.console]::set_foregroundcolor("white") 
    [system.console]::set_backgroundcolor("black")
    cd c:\temp
    clear-host
}
else
{
    # Set your colors when running as a standard user.
    [system.console]::set_foregroundcolor("white")
    [system.console]::set_backgroundcolor("darkblue")
    cd c:\temp
    clear-host
}



######## ALIASES ##########
new-alias -name find -value select-string
new-alias -name mo -value measure-object



######## FUNCTIONS ##########
function tt { cd c:\temp }
function rr { "-" * 70 ; foreach ($x in $error[0..7]) { $x ; "-" * 70 } }
function ee ( $path ) { C:\Progra~1\PowerGUI\Quest.PowerGUI.ScriptEditor.exe $path }
function hh ( $term ) { get-help $term -full | more.com }
function nn ( $path ) { C:\PROGRA~2\Notepad++\notepad++.exe $path } 
function ns ($name = "script.ps1") { new-item -name $name -itemtype file ; nn $name }
function py { ping.exe -n 2 www.yahoo.com }
function get-cpuspeed { get-wmiobject -query "SELECT CurrentClockSpeed FROM Win32_Processor" | fl CurrentClockSpeed }
function sync-time { w32tm.exe /resync }
function find-files ($pattern = "*", $searchroot = ".") { dir -r $searchroot | where {$_.fullname -like $pattern} | ft fullname }
function google { C:\'Program Files'\'Mozilla Firefox'\firefox.exe http://www.google.com/search?q=$args }
function utc { "{0:dd}-{0:MMM}-{0:yy} {0:HH}:{0:mm} UTC" -f $(get-date).ToUniversalTime() } 
function get-ip { ipconfig.exe | select-string 'IPv4|^[^\s].+\:$|Subnet|Gateway' | findstr.exe /v "Tunnel" }
function remove-flashcookies { Remove-Item $env:APPDATA\Macromedia\FlashP~1\* -recurse -force }


# The prompt function is run automatically, it changes the appearance of your command prompt.
function prompt 
{
    $errtxt = '($?=' + "$? : LastExitCode=$LASTEXITCODE)"
    if ($UacElevated) { $titletxt = "PowerShell-Admin   " } else { $titletxt = "PowerShell" }
    $host.UI.rawui.windowtitle = "$titletxt   $(get-location)   $errtxt   $(get-date -uFormat '%A   %d-%b-%Y')"
    Write-Host "$(get-location)>" -nonewline -fore Yellow
    Return " "  #Needed to remove the extra "PS"
}




function update-hostsfile 
{
    Param ($FilePathOrURL = "http://www.malwaredomainlist.com/hostslist/hosts.txt",
           [String] $BlackholeIP = "0.0.0.0", 
           [Switch] $ResetToDefaultHostsFile, 
           [Switch] $AddDuplicateWWW,           
           [Switch] $EditHostsFile, 
           [Switch] $ShowHostnameCount)
           
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
    
    #Show count of names in hosts file? Does not include localhost entries, but will include non-blackhole names.
    if ($ShowHostnameCount) 
    { "`nCount of names in hosts file = " + ($(get-content $HostsFilePath) -split " " | 
      where { $_ -notmatch '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}|\:|localhost|^\s*$|^\#' }).count ; "`n" ; return }
    
    
    #Check if we're just resetting the hosts file to the default localhosts. 
    if ($ResetToDefaultHostsFile) 
    { 
        #Sometimes a full CRLF newline (0x0D,0x0A) is not appended 
        #unless we do these two lines separately (weird). 
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
    #unless we do these two lines separately (weird). 
    "127.0.0.1 localhost"  | set-content $HostsFilePath -force
    "::1 localhost"  | add-content $HostsFilePath -force
    if (-not $?) { "Error writing to hosts file!" ; return } 
    $output | add-content $HostsFilePath -force
}



function get-externalip 
{
    $webclient = new-object System.Net.WebClient
    $webclient.DownloadString("http://www.whatismyip.com/automation/n09230945.asp")
} 




function Whois-IP ($IpAddress = "66.35.45.201")
{
    # Build an object to populate with data, then emit it at the end.
    $poc = $IpAddress | select-object IP,Name,City,Country,Handle,RegDate,Updated
    $poc.IP = $IpAddress.Trim() 

    # Do whois lookup with ARIN on the IP address, do crude error check.
    $webclient = new-object System.Net.WebClient
    [xml] $ipxml = $webclient.DownloadString("http://whois.arin.net/rest/ip/$IpAddress") 
    if (-not $?) { $poc ; return } 
    
    # Get the point of contact info for the owner organization.
    [xml] $orgxml = $webclient.DownloadString($($ipxml.net.orgRef.InnerText))
    if (-not $?) { $poc ; return } 
    
    $poc.Name = $orgxml.org.name
    $poc.City = $orgxml.org.city
    $poc.Country = $orgxml.org."iso3166-1".name
    $poc.Handle = $orgxml.org.handle

    if ($orgxml.org.registrationDate) 
    { $poc.RegDate = $($orgxml.org.registrationDate).Substring(0,$orgxml.org.registrationDate.IndexOf("T")) } 

    if ($orgxml.org.updateDate) 
    { $poc.Updated = $($orgxml.org.updateDate).Substring(0,$orgxml.org.updateDate.IndexOf("T")) } 

    $poc 
}


