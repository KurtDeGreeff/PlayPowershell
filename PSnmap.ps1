[CmdletBinding()]
param(
    # CIDR, IP/subnet, IP, or DNS/NetBIOS name.
    [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][string[]] $ComputerName,
    # Port or ports to check.
    [int[]] $Port,
    # Perform a DNS lookup.
    [switch] $Dns,
    # Scan all hosts even if ping fails.
    [switch] $ScanOnPingFail,
    # Number of concurrent threads.
    [int] $ThrottleLimit = 32,
    # Do not display progress with Write-Progress.
    [switch] $HideProgress,
    # Timeout in seconds. Cause problems if too short. 30 as a default seems OK.
    [int] $Timeout = 30,
    # Port connect timeout in milliseconds. 5000 as a default seems sane.
    [int] $PortConnectTimeout = 5000,
    # Do not display the end summary with start and end time, using Write-Host.
    [switch] $NoSummary
)

# PowerShell nmap-ish clone for Windows.
# Copyright (c) 2015, Svendsen Tech, All rights reserved.
# Author: Joakim Borger Svendsen
# Runspace "framework" borrowed and adapted from Zachary Loeber's work.
# BSD 3-clause license - http://www.opensource.org/licenses/BSD-3-Clause

# July 20, 2015. beta1

Set-StrictMode -Version Latest
$MyEAP = 'Stop'
$ErrorActionPreference = $MyEAP
$StartTime = Get-Date
$MyScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
# Not quite best practices? Um. I'll fix it some day. Mash it all up into one, I guess... Updating the wiki will be a nightmare.
# The wiki updating process is the main reason for doing this. Sorry... UNC paths might be a problem. Go $Env:Temp for temporary files!
$PSipcalc = 'PSipcalc.ps1'
if (-not (Test-Path -LiteralPath (Join-Path $MyScriptRoot $PSipcalc) -PathType Leaf))
{
    Write-Error -Message "This script needs to have PSipcalc.ps1 from Svendsen Tech in the same folder as it is called from."
    return
}
Write-Verbose -Message "Creating script-scoped PSipcalc alias."
New-Alias -Name Invoke-PSipcalc -Scope Script -Value (Join-Path $MyScriptRoot $PSipcalc)
$IPv4Regex = '(?:(?:0?0?\d|0?[1-9]\d|1\d\d|2[0-5][0-5]|2[0-4]\d)\.){3}(?:0?0?\d|0?[1-9]\d|1\d\d|2[0-5][0-5]|2[0-4]\d)'
$RunspaceTimers = [HashTable]::Synchronized(@{})
$PortData = [HashTable]::Synchronized(@{})
$Runspaces = New-Object -TypeName System.Collections.ArrayList
$RunspaceCounter = 0
Write-Verbose -Message 'Creating initial session state.'
$ISS = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
$ISS.Variables.Add((New-Object -TypeName System.Management.Automation.Runspaces.SessionStateVariableEntry -ArgumentList 'RunspaceTimers', $RunspaceTimers, ''))
$ISS.Variables.Add((New-Object -TypeName System.Management.Automation.Runspaces.SessionStateVariableEntry -ArgumentList 'PortData', $PortData, ''))
Write-Verbose -Message 'Creating runspace pool.'
$RunspacePool = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspacePool(1, $ThrottleLimit, $ISS, $Host)
$RunspacePool.ApartmentState = 'STA'
$RunspacePool.Open()
$ScriptBlock =
{
    [CmdletBinding()]
    param(
        [int] $ID,
        [string] $Computer,
        [int[]] $Port,
        [switch] $Dns,
        [int] $PortConnectTimeout
    )
    # Get the start time.
    $RunspaceTimers.$ID = Get-Date
    # The objects returned here are passed to the host...
    if (-not $PortData.ContainsKey($Computer))
    {
        #'' | Select-Object -Property ComputerName, Error, Ping
        $PortData[$Computer] = New-Object -TypeName PSObject -Property @{ 
            ComputerName = $Computer
        }
    }
    # I'm lazy and just took this DNS stuff from the existing Get-PortState module...
    if ($Dns)
    {
        $ErrorActionPreference = 'SilentlyContinue'
        $HostEntry = [System.Net.Dns]::GetHostEntry($Computer)
        $Result = $?
        $ErrorActionPreference = 'Continue'
        # It looks like it's "successful" even when it isn't, for any practical purposes (pass in IP, get IP as .HostName)...
        if ($Result)
        {
            ## This is a best-effort attempt at handling things flexibly.
            ##
            # I think this should mostly work... If I pass in an IPv4 address that doesn't
            # resolve to a host name, the same IP seems to be used to populate the HostName property.
            # So this means that you'll get the IP address twice for IPs that don't resolve, but
            # it will still say it resolved. For IPs that do resolve to a host name, you will
            # correctly get the host name in the IP/DNS column. For host names or IPs that resolve to
            # one or more IP addresses, you will get the IPs joined together with semicolons.
            # Both IPv6 and IPv4 may be reported depending on your environment.
            if ($HostEntry.HostName.Split('.')[0] -ieq $Computer.Split('.')[0])
            {
                $IPDns = ($HostEntry | Select -Expand AddressList | Select -Expand IPAddressToString) -join ';'
            }
            else
            {
                $IPDns = $HostEntry.HostName, ($HostEntry.Aliases -join ';') -join ';' -replace ';\z'
            }
            $PortData[$Computer] | Add-Member -MemberType NoteProperty -Name 'IP/DNS' -Value $IPDns
        }
        else {
            $PortData[$Computer] | Add-Member -MemberType NoteProperty -Name 'IP/DNS' -Value $Null
        }
        continue
    } # end of if $Dns
    foreach ($p in $Port | Sort-Object) { # only one port per thread, legacy code...
        Write-Verbose -Message "Processing ${Computer}, port $p in thread."
        $MySock, $IASyncResult, $Result = $Null, $Null, $Null
        $MySock = New-Object Net.Sockets.TcpClient
        $IASyncResult = [IAsyncResult] $MySock.BeginConnect($Computer, $p, $null, $null)
        $Result = $IAsyncResult.AsyncWaitHandle.WaitOne($PortConnectTimeout, $true)
        if ($MySock.Connected)
        {
            $MySock.Close()
            $MySock.Dispose()
            $MySock = $Null
            Write-Verbose "${Computer}: Port $p is OPEN"
            $PortData[$Computer] | Add-Member -MemberType NoteProperty -Name "Port $p" -Value $True
        }
        else
        {
            $MySock.Close()
            $MySock.Dispose()
            $MySock = $Null
            Write-Verbose "${Computer}: Port $p is CLOSED"
            $PortData[$Computer] | Add-Member -MemberType NoteProperty -Name "Port $p" -Value $False
        }
        <#$MySocket = $Null
        $MySocket = New-Object Net.Sockets.TcpClient
        # Suppress error messages
        $ErrorActionPreference = 'SilentlyContinue'
        # Try to connect
        $MySocket.Connect($Computer, $p)
        # Make error messages visible again
        $ErrorActionPreference = 'Continue'
        if ($MySocket.Connected) {
            $MySocket.Close()
            $MySocket.Dispose()
            $MySocket = $Null
            Write-Verbose "${Computer}: Port $p is OPEN"
            $PortData[$Computer] | Add-Member -MemberType NoteProperty -Name "Port $p" -Value $True
        }
        else
        {
            $MySocket.Close()
            $MySocket.Dispose()
            $MySocket = $Null
            Write-Verbose "${Computer}: Port $p is CLOSED"
            $PortData[$Computer] | Add-Member -MemberType NoteProperty -Name "Port $p" -Value $False
        }#>
    }
    # Emit object to pipeline!
    #$o
} # end of script block that's run for each host/port/DNS
    
function Get-Result
{
    [CmdletBinding()]
    param(
        [switch] $Wait
    )
    do
    {
        $More = $false
        foreach ($Runspace in $Runspaces) {
            $StartTime = $RunspaceTimers[$Runspace.ID]
            if ($Runspace.Handle.IsCompleted)
            {
                #Write-Verbose -Message ('Thread done for {0}' -f $Runspace.IObject)
                $Runspace.PowerShell.EndInvoke($Runspace.Handle)
                $Runspace.PowerShell.Dispose()
                $Runspace.PowerShell = $null
                $Runspace.Handle = $null
            }
            elseif ($Runspace.Handle -ne $null)
            {
                $More = $true
            }
            if ($Timeout -and $StartTime)
            {
                if ((New-TimeSpan -Start $StartTime).TotalSeconds -ge $Timeout -and $Runspace.PowerShell) {
                    Write-Warning -Message ('Timeout {0}' -f $Runspace.IObject)
                    $Runspace.PowerShell.Dispose()
                    $Runspace.PowerShell = $null
                    $Runspace.Handle = $null
                }
            }
        }
        if ($More -and $PSBoundParameters['Wait'])
        {
            Start-Sleep -Milliseconds 100
        }
        foreach ($Thread in $Runspaces.Clone())
        {
            if (-not $Thread.Handle) {
                Write-Verbose -Message ('Removing {0} from runspaces' -f $Thread.IObject)
                $Runspaces.Remove($Thread)
            }
        }
        if (-not $HideProgress)
        {
            $ProgressSplatting = @{
                Activity = 'Processing'
                Status = 'Processing: {0} of {1} total threads done' -f ($RunspaceCounter - $Runspaces.Count), $RunspaceCounter
                PercentComplete = ($RunspaceCounter - $Runspaces.Count) / $RunspaceCounter * 100
            }
            Write-Progress @ProgressSplatting
        }
    }
    while ($More -and $PSBoundParameters['Wait'])
} # end of Get-Result
$PingScriptBlock =
{
    [CmdletBinding()]
    param(
        [int] $ID,
        [string] $ComputerName
    )
    $RunspaceTimers.$ID = Get-Date
    if (-not $PortData.ContainsKey($ComputerName))
    {
        $PortData[$ComputerName] = New-Object -TypeName PSObject -Property @{ Ping = $Null }
    }
    $PortData[$ComputerName] | Add-Member -MemberType NoteProperty -Name Ping -Value (Test-Connection -ComputerName $ComputerName -Quiet -Count 1) -Force
}

$AllComputerName = @()
foreach ($Computer in $ComputerName)
{
    if ($Computer -match "\A(?:${IPv4Regex}/\d{1,2}|${IPv4Regex}[\s/]+$IPv4Regex)\z")
    {
        Write-Verbose "Detected CIDR notation or IP/subnet: '$Computer'. Expanding ..."
        $AllComputerName += @((Invoke-PSipcalc -NetworkAddress $Computer -Enumerate).IPEnumerated)
    }
    else {
        $AllComputerName += $Computer
    }
}
# Do a ping scan using the same thread engine as later, but don't run Get-Result.
# We sort of need some type of feedback even without Write-Verbose at this step...
# Abandoned support for pipeline input (I'm guessing "who cares" about that 99 % of the time with this script).
Write-Verbose -Message "$(Get-Date): Doing a ping sweep. Please wait."
foreach ($Computer in $AllComputerName)
{
    ++$RunspaceCounter
    $psCMD = [System.Management.Automation.PowerShell]::Create().AddScript($PingScriptBlock)
    [void] $psCMD.AddParameter('ID', $RunspaceCounter)
    [void] $psCMD.AddParameter('Computer', $Computer) #
    [void] $psCMD.AddParameter('Verbose', $VerbosePreference)
    $psCMD.RunspacePool = $RunspacePool
    Write-Verbose -Message "Starting $Computer ping thread" #
    [void]$Runspaces.Add(@{
        Handle = $psCMD.BeginInvoke()
        PowerShell = $psCMD
        IObject = $Computer #
        ID = $RunspaceCounter
    })
    #Get-Result
}
[int] $Count = 1
# Wait for pings to finish, so we have objects for all computernames/IPs.
# This is pretty ugly, but works.
while (1)
{
    if ($Runspaces[($RunspaceCounter-1)].Handle.IsCompleted)
    {
        break
    }
    Start-Sleep -Milliseconds 500
    if ($Count % 4) {
        Write-Verbose -Message "Waiting for ping scan to finish... (iterations: $Count)."
    }
    ++$Count
}
# Ugh, wait for the last one. Damn off by one crap. :( Not even sure why.
Start-Sleep -Milliseconds 3500
# seems to work without now? # no, one missing result, damn it.
if ($PSBoundParameters['ScanOnPingFail'])
{
    $IterComputerName = $PortData.Keys
}
else {
    $IterComputerName = $PortData.GetEnumerator() | Where-Object { $_.Value.Ping -eq $True } | Select-Object -ExpandProperty Name
}
foreach ($Computer in $IterComputerName)
{
    # Starting DNS thread if switch was specified.
    if ($PSBoundParameters['Dns']) {
        ++$RunspaceCounter
        $psCMD = [System.Management.Automation.PowerShell]::Create().AddScript($ScriptBlock)
        [void] $psCMD.AddParameter('ID', $RunspaceCounter)
        [void] $psCMD.AddParameter('Computer', $Computer)
        [void] $PSCMD.AddParameter('Port', $Null)
        [void] $PSCMD.AddParameter('Dns', $Dns)
        [void] $psCMD.AddParameter('Verbose', $VerbosePreference)
        $psCMD.RunspacePool = $RunspacePool
        Write-Verbose -Message "Starting $Computer DNS thread"
        [void]$Runspaces.Add(@{
            Handle = $psCMD.BeginInvoke()
            PowerShell = $psCMD
            IObject = $Computer
            ID = $RunspaceCounter
        })
    }
    Get-Result
    # Starting one thread for each port.
    foreach ($p in $Port)
    {
        #Start-Sleep -Milliseconds 25
        $RunspaceCounter++
        $psCMD = [System.Management.Automation.PowerShell]::Create().AddScript($ScriptBlock)
        [void] $psCMD.AddParameter('ID', $RunspaceCounter)
            [void] $psCMD.AddParameter('Computer', $Computer)
            [void] $psCMD.AddParameter('Port', $p)
            [void] $psCMD.AddParameter('Dns', $Null)
            [void] $psCMD.AddParameter('PortConnectTimeout', $PortConnectTimeout)
            [void] $psCMD.AddParameter('Verbose', $VerbosePreference)
            $psCMD.RunspacePool = $RunspacePool
        Write-Verbose -Message "Starting $Computer, port $p"
        [void]$Runspaces.Add(@{
            Handle = $psCMD.BeginInvoke()
            PowerShell = $psCMD
            IObject = $Computer
            ID = $RunspaceCounter
        })
        Get-Result
    }
}
#Get-Result
Get-Result -Wait
if (-not $HideProgress)
{
    Write-Progress -Activity 'Processing' -Status 'Done' -Completed
}
Write-Verbose -Message "Closing runspace pool."
$RunspacePool.Close()
$RunspacePool.Dispose()
[hashtable[]] $Script:TestPortProperties = @{ Name = 'ComputerName'; Expression = { $_.Name } }
if ($Dns)
{
    $Script:TestPortProperties += @{ Name = 'IP/DNS'; Expression = { $_.Value.'IP/DNS' } }
}
$Script:TestPortProperties += @{ Name = 'Ping'; Expression = { $_.Value.Ping } }
#$Script:TestPortProperties += @($Port | ForEach-Object { @{ Name = "Port $_"; Expression = { $_."Port $_" } } })
foreach ($p in $Port | Sort-Object)
{
    $Script:TestPortProperties += @{ Name = "Port $p"; Expression = [ScriptBlock]::Create("`$_.Value.'Port $p'") }
}
$PortData.GetEnumerator() | Select-Object -Property $Script:TestPortProperties
Write-Verbose -Message '"Exporting" $Global:STTestPortData and $Global:STTestPortDataProperties'
$Global:STTestPortData = $PortData
$Global:STTestPortDataProperties = $Script:TestPortProperties
if (-not $NoSummary)
{
    Write-Host -ForegroundColor Green ('Start time: ' + $StartTime)
    Write-Host -ForegroundColor Green ('End time:   ' + (Get-Date))
}
