
<#

.SYNOPSIS
RoboCopy with PowerShell progress.

.DESCRIPTION
Performs file copy with RoboCopy. Output from RoboCopy is captured,
parsed, and returned as Powershell native status and progress.

.PARAMETER RobocopyArgs
List of arguments passed directly to Robocopy.
Must not conflict with defaults: /ndl /TEE /Bytes /NC /nfl /Log

.OUTPUTS
Returns an object with the status of final copy.
REMINDER: Any error level below 8 can be considered a success by RoboCopy.

.EXAMPLE
C:\PS> .\Copy-ItemWithProgress c:\Src d:\Dest

Copy the contents of the c:\Src directory to a directory d:\Dest
Without the /e or /mir switch, only files from the root of c:\src are copied.

.EXAMPLE
C:\PS> .\Copy-ItemWithProgress '"c:\Src Files"' d:\Dest /mir /xf *.log -Verbose

Copy the contents of the 'c:\Name with Space' directory to a directory d:\Dest
/mir and /XF parameters are passed to robocopy, and script is run verbose

.LINK
http://keithga.wordpress.com/2014/06/23/copy-itemwithprogress

.NOTES
By Keith S. Garner (KeithGa@KeithGa.com) - 6/23/2014
With inspiration by Trevor Sullivan @pcgeek86

#>

[CmdletBinding()]
param(
	[Parameter(Mandatory = $true,ValueFromRemainingArguments=$true)] 
	[string[]] $RobocopyArgs
)

$ScanLog  = [IO.Path]::GetTempFileName()
$RoboLog  = [IO.Path]::GetTempFileName()
$ScanArgs = $RobocopyArgs + "/ndl /TEE /bytes /Log:$ScanLog /nfl /L".Split(" ")
$RoboArgs = $RobocopyArgs + "/ndl /TEE /bytes /Log:$RoboLog /NC".Split(" ")

# Launch Robocopy Processes
write-verbose ("Robocopy Scan:`n" + ($ScanArgs -join " "))
write-verbose ("Robocopy Full:`n" + ($RoboArgs -join " "))
$ScanRun = start-process robocopy -PassThru -WindowStyle Hidden -ArgumentList $ScanArgs
$RoboRun = start-process robocopy -PassThru -WindowStyle Hidden -ArgumentList $RoboArgs

# Parse Robocopy "Scan" pass
$ScanRun.WaitForExit()
$LogData = get-content $ScanLog
if ($ScanRun.ExitCode -ge 10)
{
	$LogData|out-string|Write-Error
	throw "Robocopy $($ScanRun.ExitCode)"
}
$FileSize = [regex]::Match($LogData[-4],".+:\s+(\d+)\s+(\d+)").Groups[2].Value
write-verbose ("Robocopy Bytes: $FileSize `n" +($LogData -join "`n"))

# Monitor Full RoboCopy
while (!$RoboRun.HasExited)
{
	$LogData = get-content $RoboLog
	$Files = $LogData -match "^\s*(\d+)\s+(\S+)"
    if ($Files -ne $Null )
    {
	    $copied = ($Files[0..($Files.Length-2)] | %{$_.Split("`t")[-2]} | Measure -sum).Sum
	    if ($LogData[-1] -match "(100|\d?\d\.\d)\%")
	    {
		    write-progress Copy -ParentID $RoboRun.ID -percentComplete $LogData[-1].Trim("% `t") $LogData[-1]
		    $Copied += $Files[-1].Split("`t")[-2] /100 * ($LogData[-1].Trim("% `t"))
	    }
	    else
	    {
		    write-progress Copy -ParentID $RoboRun.ID -Completed
	    }
		$PercentComplete = [math]::min(100,(100*$Copied/[math]::max($Copied,$FileSize)))
		write-progress ROBOCOPY -ID $RoboRun.ID -PercentComplete $PercentComplete $Files[-1].Split("`t")[-1] 
    }
}

write-progress Copy -ParentID $RoboRun.ID -Completed
write-progress Copy -ID $RoboRun.ID -Completed

# Parse full RoboCopy pass results, and cleanup
(get-content $RoboLog)[-11..-2] | out-string | Write-Verbose
[PSCustomObject]@{ ExitCode = $RoboRun.ExitCode }
remove-item $RoboLog, $ScanLog
