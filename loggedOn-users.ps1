<#
.SYNOPSIS 
Retrieve current listing of logged on users. Integrate on target machine as a scheduled task/job that periodically runs this script.
This script functions the same on Windows XP as well as Windows 7 workstations AND Windows Server 2008 R2 machines.
.NOTES 
Name: SystemStatusTracker
Author: Joe McCormack
DateCreated: 1/1/2011 
.LINK 
http://www.virtualsecrets.com
.EXAMPLE
Call from Command-Line: powershell.exe -command "& 'c:\Program Files\Common Files\Services\psmontsk.ps1' -noninteractive -windowstyle hidden Set-ExecutionPolicy RemoteSigned"
#>

# Start Customization
$nameAction = "flagname"
$wcTarget = "https://www.yoursite.com/Receiver.asp" # Target URL to pass data to for processing
$requestUserAgent = "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.2;)+SystemStatusTracker" # Agent signature
# End Customization
$results = ""

# Get Current Date
$nameDate = Get-Date -format g

# Get Computer Name
$nameComputer = $env:computername

# Get Current User
$nameUser = $env:username

# Get IP of Computer
$rawData = gwmi Win32_NetworkAdapterConfiguration -computer $nameComputer
$ipStep = 0
$nameIP = ""
ForEach ($segData in $rawData) {
If ($segData.IPAddress) { 
$tmpIP = $segData.IPAddress
$tmpIPBlocks = $tmpIP -split " "
ForEach ($segment in $tmpIPBlocks) {
if ($ipStep -eq 0) {
$nameIP = $segment
$ipStep = 1
}
}
}
}

# Get All Currently Logged-on Users
# While "query session /server:$nameComputer" works on Windows 7 and Windows XP workstations it does not work on Windows Server 2008 R2
# by default beyond listing the current user's session. To keep things simple, use win32_process.
ForEach($c in $nameComputer) {
$userEntry = gwmi win32_process -computer $c -Filter "Name = 'explorer.exe'"
ForEach ($user in $userEntry) {
if($results -ne '') { $results += "::" }
$tmpComputer = $c
$tmpUser = ($user.GetOwner()).User
$tmpDomain = ($user.GetOwner()).Domain
$results += "$tmpDomain|$tmpComputer|$tmpUser" 
} 
}

# Prepend Current User Information
$results = "$nameAction|$nameDate|$nameComputer|$nameUser|$nameIP||$results"

# Assemble
$sndData = new-object System.Collections.Specialized.NameValueCollection 
$sndData.Add("cd", $results) 

# Run Transaction
$wc = New-Object System.Net.WebClient
$wc.Headers.Add("user-agent", $requestUserAgent)
$wc.QueryString = $sndData
$wcTargetSnd = $wc.DownloadData($wcTarget)
$wcTargetRec = [System.Text.Encoding]::ASCII.GetString($wcTargetSnd)

# Print out $wcTarget Response for Testing
# "Web Transaction Response = $wcTargetRec"