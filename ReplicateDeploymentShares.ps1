<#
.SYNOPSIS
This script will replicate all Linked Deployment Shares from this server to their destination servers.

.DESCRIPTION
The ReplicateDeploymentShares.ps1 script will replicate all Linked Deployment Shares from this server to their destination servers.

This script will write any errors to the Windows Application event log, as well as a summary status event. The following
error codes are used. The event source is MDT Deployment Share Replication.

Event Ids
---------
1    - Summary Event
100  - Failure to import the MDT Powershell Module
101  - Failed to enumerate the deployment shares
102  - Failure to replicate the local deployment share to the remote deployment share
1000 - The event log source is not found. Events will not be written.

.PARAMETER DeploymentShare
A string or array of the name, path or description of one or more deployment shares to replicate.
If this parameter is not used, then all deployment shares are replicated.

.PARAMETER ModulePath
The path to the MDT PowerShell module. If this parameter is not specified, the default location is used.

.NOTES
This script requires that MDT be installed on this server.
#>
#requires -version 3
param(
    [parameter(Position = 0)]
    $DeploymentShare,
    $ModulePath = "C:\Program Files\Microsoft Deployment Toolkit\bin\MicrosoftDeploymentToolkit.psd1"
)

$LogCheck = Get-EventLog -Source "MDT Deployment Share Replication" -LogName Application -ErrorAction SilentlyContinue
if ($LogCheck -eq $null)
{
    New-EventLog -Source "MDT Deployment Share Replication" -LogName Application -ErrorAction SilentlyContinue
    if (!$?)
    {
        $ErrorCode = 1000
    }
}

$ErrorCode = 0
Import-Module $ModulePath
if (!$?)
{
    Write-EventLog -LogName Application -Source "MDT Deployment Share Replication" -EventId 100 -Category 4 -EntryType Error -Message "The MDT Deployment Share Replication Script failed to load the MDT Powershell module located at $ModulePath. No replication will occur."
    exit(100)
}

Restore-MDTPersistentDrive | Out-Null
$mDrives = Get-MDTPersistentDrive
if (!$?)
{
    Write-EventLog -LogName Application -Source "MDT Deployment Share Replication" -EventId 101 -Category 4 -EntryType Error -Message "Failed to enumerate Deployment Shares on this server. No replication will occur."    
    exit(101)
}
if ($DeploymentShare -eq $null)
{
    $MDTDrives = $mDrives
} else {
    $MDTDrives = @()
    if ($DeploymentShare -is [array])
    {
        foreach($share in $DeploymentShare)
        {
            if ($share -match "DS[0-9]{3}")
            {
                $MDTDrives += $mDrives | ? { $_.Name -eq $share -and $MDTDrives.Name -notcontains $_.Name }
                continue
            }
            $MDTDrives += $mDrives | ? { ($_.Path -eq $share -or $_.Description -eq $share) -and $MDTDrives.Name -notcontains $_.Name }
        }
    } else {
        if ($DeploymentShare -match "DS[0-9]{3}")
        {
            $MDTDrives += $mDrives | ? { $_.Name -eq $DeploymentShare -and $MDTDrives.Name -notcontains $_.Name }   
        } else {
            $MDTDrives += $mDrives | ? { ($_.Path -eq $DeploymentShare -or $_.Description -eq $DeploymentShare) -and $MDTDrives.Name -notcontains $_.Name }
        }
    }
}

$Results = $null
$goodResults = $null
$badResults = $null
# Get all deployment shares
foreach($drive in $MDTDrives)
{
    # Get all linked deployment shares for this share
    foreach($linkedShare in Get-ChildItem "$($drive.Name):\Linked Deployment Shares")
    {
        if ($linkedShare.Enable -ne $true) { return }
        $server = "Unknown"
        if ($linkedShare.Root -match "\\\\(.*?)\\") 
        {
            $server = $matches[1]
        }

        Update-MDTLinkedDS -path "$($linkedShare.PSDrive):\Linked Deployment Shares\$($linkedShare.PSChildName)"
        if (!$?)
        {
            $success = $false
            if ($ErrorCode -ne 1000) { $ErrorCode = 102 }
            Write-EventLog -LogName Application -Source "MDT Deployment Share Replication" -EventId 102 -Category 4 -EntryType Error -Message "Replication of the deployment share ($($drive.Description)) to $server failed."    
        } else {
            $success = $true
        }
        $Results += New-Object PSObject -Property @{"DeploymentShare" = $drive.Description; "TargetServer" = $server; "Success" = $success}
    }
}

$message = "Replication of all Deployment Shares has completed. Please see below for a summary.`r`n`r`n"
if ($Results -eq $null) 
{
    $message += "There were no Deployment Shares set for replication."
}
$goodResults = $Results | ? { $_.Success -eq $true }
if ($goodResults -ne $null) 
{
    $message += "The following Deployment Shares were replicated successfully:`r`n"
    $goodResults | % { $message += "$($_.DeploymentShare) replicated to $($_.TargetServer)`r`n" }
}
$badResults = $Results | ? { $_.Success -eq $false }
if ($badResults -ne $null)
{
    $message += "`r`nThe following Deployment Shares failed to replicate:`r`n"
    $badResults | % { $message += "$($_.DeploymentShare) failed to replicate to $($_.TargetServer)`r`n" }
}
Write-EventLog -LogName Application -Source "MDT Deployment Share Replication" -EventId 1 -EntryType Information -Category 1 -Message $message

# --- Exit script ---
Exit($ErrorCode)