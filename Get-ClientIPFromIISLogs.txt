<#
.Synopsis
   Gets client IP collection from IIS logs
.DESCRIPTION
   Extracts the Client IP addresses from IIS logs, and returns the unique addresses 
   found.  Optionally, it will include counts of how many times each address appeared 
   in the logs, by enabling the -Count switch. If -Count is enabled you can return either 
   a collection of PS objects having ClientIP and Count properties, or a hash table of the
   ip addresses and counts by using the -AsHash switch.
.PARAMETER Path
   The path to the directory containing the log files to parse. All *.log files found in this
   directory will be parsed.
.PARAMETER Pattern
   Wildcard pattern to filter returned ClientIPs 
   Default is * (all addresses).
.PARAMETER ReadCount
   Specifies the number of records to read at a time. 
   See the General Notes for information on the effect of using this parameter 
   and finding an appropriate setting for the log files being parsed. 
   Default is 1200.  
.PARAMETER Count
   Eanbles instance counters for each ClientIP address encountered.
   If the -Count parameter is absent or $false, the function will return a list of ClientIPs.  
   If the -Count parameter is specified, the default return will be custom PS objects having 
   a ClientIP and Count property, from each entry in the hash table. If the -AsHash parameter 
   is also enabled, the hash table will be returned instead of objects.
.PARAMETER AsHash
   Returns client ips and instance counts as a hash table instead of objects.  
   Setting this switch has no effect if the -Count switch is not enabled.
.EXAMPLE
   'C:\Archive\IIS_logs' | Get-ClientIPFromIISLogs
 
   Returns a list of the Client IP addresses found in the log files in 'C:\Archive\IIS_logs'.
.EXAMPLE
   Get-ClientIPFromIISLogs -Path 'C:\Archive\IIS_logs' -Pattern 12.200.* -Count
 
   Gets the Client IPs from the logs in the specified directory that match the pattern, 
   and returns PS objects with the ClientIP addresses and a Count of how many times 
   each one appears in the logs.
.EXAMPLE
   Get-ClientIPFromIISLogs -Path 'C:\Archive\IIS_logs'  -Count -AsHash
 
   Returns a hash table with all the Client IPs found the logs in the specified directory 
   as keys, and the number of times each one appears in the logs as values.
.INPUTS
   Path of directory containing log files to parse.
.OUTPUTS
   String array of IP addresses, 
   or a PS object collection or hash table of IP addresses and counts.
.NOTES
   General notes
   IIS logs can get very large (hundreds of MB, up to GBs), and solutions that work well with 
   relatively small log samples can fail when confronted with actual production data.
      
   This is designed to parse files of any size with good performance, while keeping memory 
   consumption under control. Using ReadCount breaks the files up into managable arrays of lines, 
   controlling the amount of memory required. The -replace operator was chosen to extract 
   the IP addresses because it can do the entire array in one operation.
    
   The ClientIP addresses are de-duped instream with a hash table, so nothing 
   accumulates in memory except a hash table entry for each ClientIP found.
   This process will also accumulate some "garbage" entries from the header comments at the 
   beginning of each file.  These are ignored until all the data is gathered, and then they 
   are filtered out of the hash table keys.
 
   Applying the user-specified filter is also done to the hash table keys after all the 
   ip addresses are extracted.  This seems counter-intuitive to the conventional wisdom of 
   "filter left", but testing showed that filtering them inside the loop was false economy -
   the filter test was more expensive than the hash table operations it was trying to 
   control. It's faster to just let them go, and take a few ms to filter them out at the end.
 
   Notes on setting ReadCount:
   The ReadCount setting determines how many lines of the log file will be processed in each 
   cycle of the foreach loop.  Higher numbers means bigger chunks of data in the pipeline, 
   and fewer passes through the loop.  It also means more memory usage and additional system 
   overhead for memory management, and possibly disk contention between reading log files and 
   writing to the page file. At some point less is more in terms of performance.
 
   The best ReadCount setting will vary  according to the average size of the records in 
   the files being processed.  The optimum seems to be a number that just begins 
   to produce occasional page faults once the process gets running. 
 
   I tested this on a sample of IIS logs from one of my Exchange CAS servers, and found 
   1200 was a good setting for those logs, so I made that the default.
   Using that setting I was able to process logs at up to 700MB / minute in a single process, 
   (that's on my laptop with rotating storage), while holding the working set memory 
   under 75 MB for the process.
#>
#Requires -Version 3.0
function Get-ClientIPFromIISLogs
{
    [CmdletBinding()]
    Param
    (
        # Path to log file directory
        [Parameter(Mandatory, ValueFromPipeline,
                   ValueFromPipelineByPropertyName)]
        [ValidateScript({
                          if (-not ( Test-Path $_ -PathType Container ))
                             {Throw "Directory path $_ was not found." } 
                          if ( -not (Test-path $_\*.log -PathType Leaf ))
                             {Throw "No log files were found at $_" } 
                           else {$true} })]
        [Alias('FullName')] 
        [string]$Path,
 
        # ClientIP filter
        [ValidatePattern('^[0-9a-e.:]+\*$')]
        [String]$Pattern = '*',
 
        # Readcount - the number of records processed at a time. See General Notes. 
        [Parameter()]
        [ValidateRange(100,10000)]
        [Int]$ReadCount = 1200,
 
        # Count - Enables instance counters per ClientIP.
        [Parameter()]
        [switch] $Count, 
 
        # AsHash - Returns ClientIPs and counts as a hash table instead of objects.
        [Parameter()]
        [switch] $AsHash
    )
 
   End
    {
     # Hash table for Client IP addresses
     $IP_ht = @{}
 
     # Set replace pattern to extract IP address
     $RPattern = [regex]'^(?:\S+\s){8}(\S+).+'
 
     # IP regex for filtering out header garbage
     $IPPattern = [regex]'^(?:(?:\d{1,3}\.){3}\d{1,3})|(?:[0-9a-e]{4}:)'
      
     # Set hash table filter script 
       #Enable instance counters
       if ($Count)
         { Filter HashScript { $IP_ht[$_]++ } } 
 
       #No counters
       else
         { Filter HashScript { $IP_ht[$_]=$true } }  
 
     # Progress reporting  
       $timer = [diagnostics.stopwatch]::StartNew()
       $WPParams = @{
          Activity = "Get-ClientIPFromIISLogs: Processing log files at $Path"
          PercentComplete = -1 
         } 
                                           
    
     # Fetch!
      Get-Content $Path\*.log -ReadCount $ReadCount |
       foreach { $_ -replace $RPattern,'$1' | HashScript 
          $Progress += $_.count
          $Rate = $Progress,($Progress/$timer.Elapsed.TotalSeconds)
          Write-Progress @WPParams -Status $('Processed {0:n0}. Average rate {1:n0} recs/sec' -f $Rate)
         } 
             
     # Filter header lines and user specified pattern matches
     $HT_Out = @{}
     $IP_ht.keys -match $IPPattern -like $Pattern |
       foreach { $HT_Out.Add($_,$IP_ht[$_]) }
                      
     # Output Results
       #Counters enabled - output ClientIPs and instance counts as hash table or objects
       if ($Count)
         {
           #Hash Table 
           if ($AsHash)
             { $HT_Out }
 
           #Objects
            else { 
                  $HT_Out.GetEnumerator() |
                  foreach { [PSCustomObject]@{ClientIP=$_.Name;Count=$_.Value} }
                 }
         }
             
      #Counters not enabled - output a list of  ClientIPs only 
      else { $HT_Out.keys  }
   }
 }