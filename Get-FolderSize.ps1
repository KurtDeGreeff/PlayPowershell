#requires -version 2
[CmdletBinding()]
param(
    # Paths to report size, file count, dir count, etc. for.
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)] [string[]] $Path
)

# Copyright (c) 2015, Svendsen Tech
# All rights reserved.
# Author: Joakim Svendsen

begin {
   if (-not (Get-Command -Name robocopy -ErrorAction SilentlyContinue)) {
        throw "I need robocopy. Exiting."
    }
}
# PS C:\temp> [datetime]::ParseExact("Mon Jan 26 00:05:19 2015", 'ddd MMM dd HH:mm:ss yyyy', [Globalization.CultureInfo]::InvariantCulture)

# Attempt to change language to en-US for robocopy's output to be in english...
#$OldCulture = [System.Threading.Thread]::CurrentThread.CurrentCulture

process {
    foreach ($p in $Path) {
        Write-Verbose -Message "Processing path: $p. $(Get-Date)"
        if (-not (Test-Path -Path $p -PathType Container)) {
            Write-Warning -Message "$p does not exist or is a file and not a directory. Skipping."
            continue
        }
        $RoboCopyArgs = @("/L","/S","/NJH","/BYTES","/FP","/NC","/NDL","/TS","/XJ","/R:0","/W:0")
        [datetime] $StartedTime = Get-Date
        #[System.Threading.Thread]::CurrentThread.CurrentCulture = 'en-US'
        [string] $Summary = robocopy $p NULL $RoboCopyArgs | Select-Object -Last 8
        #[System.Threading.Thread]::CurrentThread.CurrentCulture = $OldCulture
        [regex] $HeaderRegex    = '\s+Total\s+Copied\s+Skipped\s+Mismatch\s+FAILED\s+Extras'
        [regex] $DirLineRegex   = 'Dirs\s:\s+(?<DirCount>\d+)(?:\s+\d+){3}\s+(?<DirFailed>\d+)\s+\d+'
        [regex] $FileLineRegex  = 'Files\s:\s+(?<FileCount>\d+)(?:\s+\d+){3}\s+(?<FileFailed>\d+)\s+\d+'
        [regex] $BytesLineRegex = 'Bytes\s:\s+(?<ByteCount>\d+)(?:\s+\d+){3}\s+(?<ByteFailed>\d+)\s+\d+'
        [regex] $TimeLineRegex  = 'Times\s:\s+(?<TimeElapsed>\d+).*'
        [regex] $EndedLineRegex = 'Ended\s:\s+(?<EndedTime>.+)'
        if ($Summary -match "$HeaderRegex\s+$DirLineRegex\s+$FileLineRegex\s+$BytesLineRegex\s+$TimeLineRegex\s+$EndedLineRegex") {
            $ErrorActionPreference = 'Stop'
            try {
                $EndedTime = [datetime]::ParseExact($Matches['EndedTime'], 'ddd MMM dd HH:mm:ss yyyy', [Globalization.CultureInfo]::InvariantCulture)
            }
            catch {
                try {
                    $EndedTime = [datetime] $Matches['EndedTime']
                }
                catch {
                    $EndedTime = $Matches['EndedTime'] + ' (string)'
                }
            }
            $ErrorActionPreference = 'Continue'
            New-Object PSObject -Property @{
                Path        = $p
                TotalBytes  = [int64] $Matches['ByteCount']
                TotalMBytes = [math]::Round(([int64] $Matches['ByteCount'] / 1MB), 4)
                TotalGBytes = [math]::Round(([int64] $Matches['ByteCount'] / 1GB), 4)
                BytesFailed = [int64] $Matches['ByteFailed']
                DirCount    = [int64] $Matches['DirCount']
                FileCount   = [int64] $Matches['FileCount']
                DirFailed   = [int64] $Matches['DirFailed']
                FileFailed  = [int64] $Matches['FileFailed']
                StartedTime = $StartedTime
                EndedTime   = $EndedTime

            } | Select Path, TotalBytes, TotalMBytes, TotalGBytes, DirCount, FileCount, DirFailed, FileFailed, StartedTime, EndedTime
        }
        else {
            Write-Warning -Message "$p's output from robocopy was not in an expected format."
        }
    }
}

#[System.Threading.Thread]::CurrentThread.CurrentCulture = $OldCulture
