function New-Log {
    <#
        .SYNOPSIS
            Create a new log.
        .DESCRIPTION
            The New-Log function is used to create a new log file or Windows Event log. A log object is also created
            and either saved in the global PSLOG variable (default) or sent to the pipeline. The latter is useful if
            you need to write to different log files in the same script/function.
        .EXAMPLE
            New-Log '.\myScript.log'
            Create a new log file called 'myScript.log' in the current folder, and save the log object in $global:PSLOG
        .EXAMPLE
            New-Log '.\myScript.log' -Header 'MyHeader - MyScript' -Append -Format 'CMTrace'
            Create a new log file called 'myScript.log' if it doesn't exist already, and add a custom header to it. 
            The log format used for logging by Write-Log is the CMTrace format.
        .EXAMPLE
            $log1 = New-Log '.\myScript_log1.log'; $log2 = New-Log '.\myScript_log2.log'
            Create two different logs that can be written to depending on your own internal script logic. Remember to
            pass the correct log object to Write-Log!
        .EXAMPLE
            New-Log -EventLogName 'PowerShell Scripts' -EventLogSource 'MyScript'
            Create a new log called 'PowerShell Scripts' with a source of 'MyScript', for logging to the Windows Event Log.
        .NOTES
            Author: Øyvind Kallstad
            Date: 21.11.2014
            Version: 1.0
    #>
    [CmdletBinding(DefaultParameterSetName = 'LogFile')]
    param (
        # Path to log file.
        [Parameter(ParameterSetName = 'LogFile', Mandatory, Position = 0)]
        [ValidateNotNullorEmpty()]
        [string] $Path,
 
        # Optionally define a header to be added when a new empty log file is created.
        [Parameter(ParameterSetName = 'LogFile')]
        [string] $Header,
 
        # If log file already exist, append instead of creating a new empty log file.
        [Parameter(ParameterSetName = 'LogFile')]
        [switch] $Append,
 
        # Maximum size of log file.
        [Parameter(ParameterSetName = 'LogFile')]
        [int64] $MaxLogSize = 1048576, # in bytes, default is 1048576 = 1 MB

        # Maximum number of log files to keep. Default is 3. Setting MaxLogFiles to 0 will keep all log files.
        [Parameter(ParameterSetName = 'LogFile')]
        [ValidateRange(0,99)]
        [int32] $MaxLogFiles = 3,
 
        # The format of the log file. Valid choices are 'Minimal', 'PlainText' and 'CMTrace'. 
        # The 'Minimal' format will just pass the log entry to the log file, while the 'PlainText' includes meta-data.
        # CMTrace format are viewable using the CMTrace.exe tool.
        [Parameter(ParameterSetName = 'LogFile')]
        [ValidateSet('Minimal','PlainText','CMTrace')]
        [string] $Format = 'PlainText',
 
        # Specifies the name of the event log.
        [Parameter(ParameterSetName = 'EventLog', Mandatory)]
        [string] $EventLogName,
 
        # Specifies the name of the event log source.
        [Parameter(ParameterSetName = 'EventLog', Mandatory)]
        [string] $EventLogSource,
 
        # Define the default Event ID to use when writing to the Windows Event Log. 
        # This Event ID will be used when writing to the Windows log, but can be overrided by the Write-Log function.
        [Parameter(ParameterSetName = 'EventLog')]
        [string] $DefaultEventID = '0',
 
        # When UseGlobalVariable is True, the log object is saved in the global PSLOG variable, otherwise it's returned to the pipeline. Default value is True.
        [Parameter()]
        [switch] $UseGlobalVariable = $true
    )
 
    if ($PSCmdlet.ParameterSetName -eq 'EventLog') {
        $logType = 'EventLog'
        # when creating (and writing) to the event log, you need to run with elevated user rights
        $windowsIdentity=[System.Security.Principal.WindowsIdentity]::GetCurrent()
        $windowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($windowsIdentity)
        $adm=[System.Security.Principal.WindowsBuiltInRole]::Administrator
        if ($windowsPrincipal.IsInRole($adm)) {
            $elevated = $true
            Remove-Variable -Name Format,MaxLogSize,MaxLogFiles -ErrorAction SilentlyContinue
            # create new event log if needed
            try {
                if (-not([System.Diagnostics.EventLog]::SourceExists($EventLogName))) {
                    New-EventLog -Source $EventLogSource -LogName $EventLogName
                    Write-Verbose "Created new event log (Name: $($EventLogName), Source: $($EventLogSource))"
                }
                else {
                    Write-Verbose "$($EventLogName) exists, skip create new event log."
                }
            }
            catch {
                Write-Warning $_.Exception.Message
            }
        }

        else {
            Write-Warning 'When creating a Windows Event Log you need to run as a user with elevated rights!'
            $elevated = $false
        }
    }
 
    else {
        $logType = 'LogFile'
        # create new log file if needed
        if((-not $Append) -or (-not(Test-Path $Path))){
            try {
                if($Header){
                    Set-Content -Path $Path -Value $Header -Encoding 'UTF8' -Force
                }
                else{
                    Set-Content -Path $Path -Value $null -Encoding 'UTF8' -Force
                }
                Write-Verbose "Created new log file ($($Path))"
            }
            catch{
                Write-Warning $_.Exception.Message
            }
		}
    }
 
    # create log object
    $logObject = [PSCustomObject] [Ordered] @{
        LogType = $logType
        LogFormat = $Format
        Path = $Path
        MaxLogSize = $MaxLogSize
        MaxLogFiles = $MaxLogFiles
        LogHeader = $Header
        EventLogName = $EventLogName
        EventLogSource = $EventLogSource
        DefaultEventID = $DefaultEventID
        Elevated = $elevated
    }
         
    # save logObject to a global variable
    if($UseGlobalVariable){
        $global:PSLOG = $logObject
    }
    # unless UseGlobalValiable is false, then return it to the pipeline instead
    else{
        Write-Output $logObject
    }
}
 
function Write-Log {
    <#
        .SYNOPSIS
            Write to the log.
        .DESCRIPTION
            The Write-Log function is used to write to the log. It is using the log object created by New-Log
            to determine if it's going to write to a log file or to a Windows Event log.
        .EXAMPLE
            Write-Log 'Finished running WMI query'
            Get the log object from $global:PSLOG and write to the log.
        .EXAMPLE
            $myLog | Write-Log 'Finished running WMI query'
            Use the log object saved in $myLog and write to the log.
        .EXAMPLE
            Write-Log 'WMI query failed - Access denied!' -LogType Error -PassThru | Write-Warning
            Will write an error to the event log, and then pass the log entry to the Write-Warning cmdlet.
        .NOTES
            Author: Øyvind Kallstad
            Date: 21.11.2014
            Version: 1.0
    #>
    [CmdletBinding()]
    param (
        # The text you want to write to the log.
        [Parameter(Position = 0)]
        [string] $LogEntry,
 
        # The type of log entry. Valid choices are 'Error', 'FailureAudit','Information','SuccessAudit' and 'Warning'.
        # Note that the CMTrace format only supports 3 log types (1-3), so 'Error' and 'FailureAudit' are translated to CMTrace log type 3, 'Information' and 'SuccessAudit'
        # are translated to 1, while 'Warning' is translated to 2. 'FailureAudit' and 'SuccessAudit' are only really included since they are valid log types when
        # writing to the Windows Event Log.
        [Parameter()]
        [ValidateSet('Error','FailureAudit','Information','SuccessAudit','Warning')]
        [string] $LogType = 'Information',
 
        # Event ID. Only applicable when writing to the Windows Event Log.
        [Parameter()]
        [string] $EventID,
 
        # The log object created using the New-Log function. Defaults to reading the global PSLOG variable.
        [Parameter(ValueFromPipeline)]
        [ValidateNotNullorEmpty()]
        [object] $Log = $global:PSLOG,
 
        # PassThru passes the log entry to the pipeline for further processing.
        [Parameter()]
        [switch] $PassThru
    )

    try {
     
        # get information from log object
        $logObject = $Log
 
        # translate event types to CMTrace format
        if ($logObject.LogFormat -eq 'CMTrace') {
            switch ($LogType) {
                'Error' {$cmType = '3';break}
                'FailureAudit' {$cmType = '3';break}
                'Information' {$cmType = '1';break}
                'SuccessAudit' {$cmType = '1';break}
                'Warning' {$cmType = '2';break}
                DEFAULT {$cmType = '1'}
            }
        }
 
        # get invocation information
        $thisInvocation = (Get-Variable -Name 'MyInvocation' -Scope 1).Value
 
        # get calling script info
        if(-not ($thisInvocation.ScriptName)){
            $scriptName = $thisInvocation.MyCommand
            $file = "$($scriptName)"
	    }
	    else{
            $scriptName = Split-Path -Leaf ($thisInvocation.ScriptName)
            $file = "$($scriptName):$($thisInvocation.ScriptLineNumber)"
	    }
 
        # get calling command info
        $component = "$($thisInvocation.MyCommand)"
    
        if ($logObject.LogType -eq 'EventLog') {
            if($logObject.Elevated) {
        
                # if EventID is not specified use default event id from the log object
                if([system.string]::IsNullOrEmpty($EventID)) {
                    $EventID = $logObject.DefaultEventID
                }
 
                Write-EventLog -LogName $logObject.EventLogName -Source $logObject.EventLogSource -EntryType $LogType -EventId $EventID -Message $LogEntry
            }

            else {
                Write-Warning 'When writing to the Windows Event Log you need to run as a user with elevated rights!'
            }
        }
 
        else {
            # create a mutex, so we can lock the file while writing to it
            $mutex = New-Object System.Threading.Mutex($false, 'LogMutex')

            # handle the different log file formats
            switch ($logObject.LogFormat) {
 
                'Minimal' { $logEntryString = $LogEntry; break }
 
                'PlainText' {
                    # when component and file are equal
                    if($component -eq $file){
                        $logEntryString = "$((Get-Date).ToString()) $($LogType.ToUpper()) [$($file)] $($LogEntry)"
                        Write-Verbose $logEntryString ####
                    }
 
                    # log entry when component and file are not equal
                    else{
                        $logEntryString = "$((Get-Date).ToString()) $($LogType.ToUpper()) [$($component) - $($file)] $($LogEntry)"
                    }
                    break
                }
 
                'CMTrace' {
                    $date = Get-Date -Format 'MM-dd-yyyy'
                    $time = Get-Date -Format 'HH:mm:ss.ffffff'
                    $logEntryString = "<![LOG[$LogEntry]LOG]!><time=""$time"" date=""$date"" component=""$component"" context="""" type=""$cmType"" thread=""$pid"" file=""$file"">"
                    break
                }
            }

            # write to the log file
            [void]$mutex.WaitOne()
            Add-Content -Path $logObject.Path -Value $logEntryString
            $mutex.ReleaseMutex()

            # invoke log rotation if log is file
            if ($logObject.LogType -eq 'LogFile') {
                Invoke-LogRotation
            }

            # handle PassThru
            if ($PassThru) {
                Write-Output $LogEntry
            }
        }
    }

    catch {
        Write-Warning $_.Exception.Message
    }
}

function Invoke-LogRotation {
    <#
        .SYNOPSIS
            Handle log rotation.
        .DESCRIPTION
            Invoke-LogRotation handles log rotation, using the log parameters defined in the log object. 
            This function is called within the Write-Log function so that log rotation are invoked after 
            each write to the log file.
        .NOTES
            Author: Øyvind Kallstad
            Date: 21.11.2014
            Version: 1.0
    #>
    [CmdletBinding()]
    param (
        # The log object created using the New-Log function. Defaults to reading the global PSLOG variable.
        [Parameter(ValueFromPipeline)]
        [ValidateNotNullorEmpty()]
        [object] $Log = $global:PSLOG
    )

    try {
    
        # get current size of log file
        $currentSize = (Get-Item $Log.Path).Length

        # get log name
        $logFileName = Split-Path $Log.Path -Leaf
        $logFilePath = Split-Path $Log.Path
        $logFileNameWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($logFileName)
        $logFileNameExtension = [System.IO.Path]::GetExtension($logFileName) 

        # if MaxLogFiles is 1 just keep the original one and let it grow
        if (-not($Log.MaxLogFiles -eq 1)) {
            if ($currentSize -ge $Log.MaxLogSize) {

                # construct name of archived log file
                $newLogFileName = $logFileNameWithoutExtension + (Get-Date -Format 'yyyyMMddHHmmss').ToString() + $logFileNameExtension

                # copy old log file to new using the archived name constructed above
                Copy-Item -Path $Log.Path -Destination (Join-Path (Split-Path $Log.Path) $newLogFileName)

                # set new empty log file
                if ([string]::IsNullOrEmpty($Log.Header)) {
                    Set-Content -Path $Log.Path -Value $null -Encoding 'UTF8' -Force
                }

                else {
                    Set-Content -Path $Log.Path -Value $Log.Header -Encoding 'UTF8' -Force
                }

                # if MaxLogFiles is 0 don't delete any old archived log files
                if (-not($Log.MaxLogFiles -eq 0)) {

                    # set filter to search for archived log files
                    $archivedLogFileFilter = $logFileNameWithoutExtension + '??????????????' + $logFileNameExtension

                    # get archived log files
                    $oldLogFiles = Get-Item -Path "$(Join-Path -Path $logFilePath -ChildPath $archivedLogFileFilter)"

                    if ([bool]$oldLogFiles) {
                        # compare found log files to MaxLogFiles parameter of the log object, and delete oldest until we are
                        # back to the correct number
                        if (($oldLogFiles.Count + 1) -gt $Log.MaxLogFiles) {
                            [int]$numTooMany = (($oldLogFiles.Count) + 1) - $log.MaxLogFiles
                            $oldLogFiles | Sort-Object 'LastWriteTime' | Select-Object -First $numTooMany | Remove-Item
                        }
                    }
                }
            }
        }
    }

    catch {
        Write-Warning $_.Exception.Message
    }
}