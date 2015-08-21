function Copy-WithProgress {
    [CmdletBinding()]
    param (
          [Parameter(Mandatory = $true)]
            [string] $Source
        , [Parameter(Mandatory = $true)]
            [string] $Destination
        , [int] $Gap = 200
        , [int] $ReportGap = 2000
    )
    # Define regular expression that will gather number of bytes copied
    $RegexBytes = '(?<=\s+)\d+(?=\s+)';

    #region Robocopy params
    # MIR = Mirror mode
    # NP  = Don't show progress percentage in log
    # NC  = Don't log file classes (existing, new file, etc.)
    # BYTES = Show file sizes in bytes
    # NJH = Do not display robocopy job header (JH)
    # NJS = Do not display robocopy job summary (JS)
    # TEE = Display log in stdout AND in target log file
    $CommonRobocopyParams = '/MIR /NP /NDL /NC /BYTES /NJH /NJS';
    #endregion Robocopy params

    #region Robocopy Staging
    Write-Verbose -Message 'Analyzing robocopy job ...';
    $StagingLogPath = '{0}\temp\{1} robocopy staging.log' -f $env:windir, (Get-Date -Format 'yyyy-MM-dd hh-mm-ss');

    $StagingArgumentList = '"{0}" "{1}" /LOG:"{2}" /L {3}' -f $Source, $Destination, $StagingLogPath, $CommonRobocopyParams;
    Write-Verbose -Message ('Staging arguments: {0}' -f $StagingArgumentList);
    Start-Process -Wait -FilePath robocopy.exe -ArgumentList $StagingArgumentList -NoNewWindow;
    # Get the total number of files that will be copied
    $StagingContent = Get-Content -Path $StagingLogPath;
    $FileCount = $StagingContent.Count;

    # Get the total number of bytes to be copied
    [RegEx]::Matches(($StagingContent -join "`n"), $RegexBytes) | % { $BytesTotal = 0; } { $BytesTotal += $_.Value; };
    Write-Verbose -Message ('Total bytes to be copied: {0}' -f $BytesTotal);
    #endregion Robocopy Staging

    #region Start Robocopy
    # Begin the robocopy process
    $RobocopyLogPath = '{0}\temp\{1} robocopy.log' -f $env:windir, (Get-Date -Format 'yyyy-MM-dd hh-mm-ss');
    $ArgumentList = '"{0}" "{1}" /LOG:"{2}" /ipg:{3} {4}' -f $Source, $Destination, $RobocopyLogPath, $Gap, $CommonRobocopyParams;
    Write-Verbose -Message ('Beginning the robocopy process with arguments: {0}' -f $ArgumentList);
    $Robocopy = Start-Process -FilePath robocopy.exe -ArgumentList $ArgumentList -Verbose -PassThru -NoNewWindow;
    Start-Sleep -Milliseconds 100;
    #endregion Start Robocopy

    #region Progress bar loop
    while (!$Robocopy.HasExited) {
        Start-Sleep -Milliseconds $ReportGap;
        $BytesCopied = 0;
        $LogContent = Get-Content -Path $RobocopyLogPath;
        $BytesCopied = [Regex]::Matches($LogContent, $RegexBytes) | ForEach-Object -Process { $BytesCopied += $_.Value; } -End { $BytesCopied; };
        Write-Verbose -Message ('Bytes copied: {0}' -f $BytesCopied);
        Write-Verbose -Message ('Files copied: {0}' -f $LogContent.Count);
        Write-Progress -Activity Robocopy -Status ("Copied {0} files; Copied {1} of {2} bytes" -f $LogContent.Count, $BytesCopied, $BytesTotal) -PercentComplete (($BytesCopied/$BytesTotal)*100);
    }
    #endregion Progress loop

    #region Function output
    [PSCustomObject]@{
        BytesCopied = $BytesCopied;
        FilesCopied = $LogContent.Count;
    };
    #endregion Function output
}

# 1. TESTING: Generate a random, unique source directory, with some test files in it
$TestSource = '{0}\{1}' -f $env:temp, [Guid]::NewGuid().ToString();
$null = mkdir -Path $TestSource;
# 1a. TESTING: Create some test source files
1..20 | % -Process { Set-Content -Path $TestSource\$_.txt -Value ('A'*(Get-Random -Minimum 10 -Maximum 2100)); };

# 2. TESTING: Create a random, unique target directory
$TestTarget = '{0}\{1}' -f $env:temp, [Guid]::NewGuid().ToString();
$null = mkdir -Path $TestTarget;

# 3. Call the Copy-WithProgress function
Copy-WithProgress -Source $TestSource -Destination $TestTarget -Verbose;

# 4. Add some new files to the source directory
21..40 | % -Process { Set-Content -Path $TestSource\$_.txt -Value ('A'*(Get-Random -Minimum 950 -Maximum 1400)); };

# 5. Call the Copy-WithProgress function (again)
Copy-WithProgress -Source $TestSource -Destination $TestTarget -Verbose;


