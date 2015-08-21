#Find local applications blocked by a remote firewall
#Source: http://goo.gl/l2Iyd5
#Tested but didn't work, to check

function Get-NetstatByState
{
    [CmdletBinding(DefaultParameterSetName="Any")]
    param(
        [Parameter(ParameterSetName="Any")]
        [Switch]$Any,
         
        [Parameter(ParameterSetName="Specific")]
        [Switch]$CloseWait,
         
        [Parameter(ParameterSetName="Specific")]
        [Switch]$Established,
         
        [Parameter(ParameterSetName="Specific")]
        [Switch]$FinWaitEither,
         
        [Parameter(ParameterSetName="Specific")]
        [Switch]$FinWait1,
         
        [Parameter(ParameterSetName="Specific")]
        [Switch]$FinWait2,
         
        [Parameter(ParameterSetName="Specific")]
        [Switch]$LastAck,
         
        [Parameter(ParameterSetName="Specific")]
        [Switch]$Listening,
         
        [Parameter(ParameterSetName="Specific")]
        [Switch]$SynSent,
         
        [Parameter(ParameterSetName="Specific")]
        [Switch]$TimeWait
    )
    BEGIN {
        switch ($PSCmdlet.ParameterSetName)
        {
            "Any" {
                $Any = $true
            }
            default {
                $Any = $false
            }
        }
    }
     
    PROCESS {
        $InterestingStates = @()
        if($Any -or $CloseWait)            { $InterestingStates += @(,"CLOSE_WAIT") }
        if($Any -or $Established)        { $InterestingStates += @(,"ESTABLISHED") }
        if($Any -or $FinWaitEither)    { $InterestingStates += @(,"FIN_WAIT") }
        if($Any -or $FinWait1)            { $InterestingStates += @(,"FIN_WAIT_1") }
        if($Any -or $FinWait2)            { $InterestingStates += @(,"FIN_WAIT_2") }
        if($Any -or $LastAck)            { $InterestingStates += @(,"LAST_ACK") }
        if($Any -or $Listening)         { $InterestingStates += @(,"LISTENING") }
        if($Any -or $SynSent)            { $InterestingStates += @(,"SYN_SENT") }
        if($Any -or $TimeWait)            { $InterestingStates += @(,"TIME_WAIT") }
         
        $CurrentConnectionsRaw = netstat -aon | Select-String $InterestingStates
        $CurrentConnectionsRaw
    }
}
 
function Get-ParsedInfoFromNetstat
{
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [String[]]$FilteredNetstatAONOutput
    )
     
    PROCESS {
        $ParsedInfo = @()    # array to hold all the output
        [String]$CurrentProcessName = ""
         
        foreach ($NetstatEntry in $FilteredNetstatAONOutput)
        {
            $ParsedLine = @{} # hash table that will essentially be a new, unnamed custom data type to hold the "parsed" information
             
            $NetstatEntry = ($NetstatEntry -replace ('\s{2,}', ' ')).Trim()
            $NetstatEntry = $NetstatEntry.Split(' ')
            $CurrentProcess = Get-Process -Id ($NetstatEntry[($NetstatEntry.Count - 1)])    # more efficient to pull it once; safer to do it inline
            $ParsedLine.Add('Protocol', $NetstatEntry[0])
            $ParsedLine.Add('LocalAddress', $NetstatEntry[1].Substring(0, $NetstatEntry[1].LastIndexOf(":")))
            $ParsedLine.Add('LocalPort', $NetstatEntry[1].Substring($NetstatEntry[1].LastIndexOf(":") + 1))
            $ParsedLine.Add('RemoteAddress', $NetstatEntry[2].SubString(0, $NetstatEntry[2].LastIndexOf(":")))
            $ParsedLine.Add('RemotePort', $NetstatEntry[2].SubString($NetstatEntry[2].LastIndexOf(":") + 1))
            $ParsedLine.Add('State', $NetstatEntry[3])
            $ParsedLine.Add('PID', $NetstatEntry[4])
            $ParsedLine.Add('ProcessName', $CurrentProcess.ProcessName)
            $ParsedLine.Add('ProcessPath', $CurrentProcess.Path)
            $ParsedInfo += $ParsedLine
        }
        $ParsedInfo
    }    
}
 
function Get-BlockedConnections
{
    Get-NetstatByState -SynSent | Get-ParsedInfoFromNetstat
}
 
function Start-BlockConnectionWatch
{
    [CmdletBinding()]
    param(
        [Parameter(Position=1)]
        [Alias("Delay", "Interval")]
        [UInt32]$CheckIntervalInSeconds = 1
    )
     
    BEGIN {
        $PendingConnectionsAtLastCheck = @()
        $CurrentPendingConnections = @()
    }
     
    PROCESS {
        while($true)
        {
            $CurrentPendingConnections = @()
            $BlockList = Get-BlockedConnections
            foreach ($BlockedItem in $BlockList)
            {
                [Boolean]$Found = $false
                foreach ($ItemInLastCheck in $PendingConnectionsAtLastCheck)
                {
                    if(!$Found)
                    {
                        if($ItemInLastCheck['RemoteAddress'] -eq $BlockedItem['RemoteAddress'] -and $ItemInLastCheck['RemotePort'] -eq $BlockedItem['RemotePort'] -and $ItemInLastCheck['PID'] -eq $BlockedItem['PID'])
                        {
                            $Found = $true
                            Write-Host ("Blocking address: {0}. Blocked port: {1}. Blocked process name: {2}" -f $BlockedItem['RemoteAddress'], $BlockedItem['RemotePort'], $BlockedItem['ProcessName'])
                        }
                    }
                }
                $CurrentPendingConnections += $BlockedItem
                Write-Verbose ("Adding {0} to the watch list" -f $BlockedItem['ProcessName'])
            }
            $PendingConnectionsAtLastCheck = $CurrentPendingConnections
            Write-Verbose "Waiting for the next check interval..."
            Start-Sleep -Seconds $CheckIntervalInSeconds
        }
    }
}