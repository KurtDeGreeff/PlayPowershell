# Basic Script Template for Runspace Jobs against an array of computers
# This is just an example to show the basic layout of a script using the Runspace functions
# If you are creating a script to be run in production, please add logging and error handling
# Also consider writing it to support parameters for input instead of hardcoding it like in this example

#region verify that runspace functions are present
$missingFunctions = $false
$functions = (
    'New-RunspacePool',
    'New-RunspaceJob',
    'Show-RunspaceJob',
    'Receive-RunspaceJob'
)
foreach ($function in $functions) {
    try {
        $thisFunction = Get-Item -LiteralPath "function:$function" -ErrorAction Stop
    }
    catch {
        $missingFunctions = $true
        Write-Warning "$function not found"
    }
}

if ($missingFunctions) {
    break
}
#endregion

# computers to run against
# re-write to read from script parameter, file, Active Directory etc as needed
$computers = (
    'computer01',
    'computer02',
    'computer03',
    'computer04'
)

# define timeout for Receive-RunspaceJob (in seconds)
$timeout = 30

# code to run in each runspace
$code = {
    Param([string]$ComputerName)
    # code goes here
}

# create new runspace pool
$thisRunspacePool = New-RunspacePool

# define results array
$results = @()

# iterate through each computer and create new runspace jobs
# also run Receive-RunspaceJob to collect any already finished jobs
foreach ($computer in $computers) {
    New-RunspaceJob -RunspacePool $thisRunspacePool -ScriptBlock $code -Parameters @{ComputerName = $computer}
    $results += Receive-RunspaceJob
}

# if any jobs left, wait until all jobs are finished, or timeout is reached
if ([bool](Show-RunspaceJob)) {
    $results += Receive-RunspaceJob -Wait -TimeOut $timeout
}

Write-Output $results