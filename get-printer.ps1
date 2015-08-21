function get-printer {
[CmdletBinding()]
param (
[parameter(ValueFromPipeline=$true,
ValueFromPipelineByPropertyName=$true)]
[string]$computername="$env:COMPUTERNAME"
)
PROCESS {
Get-WmiObject -Class Win32_printer `
-ComputerName $computername |
select Name, Default, Direct, DoCompleteFirst,
HorizontalResolution, VerticalResolution,
KeepPrintedJobs, Local, Network, PortName, PrintJobDataType,
PrintProcessor, Priority, Published, Queued, RawOnly, Shared,
WorkOffline
}}