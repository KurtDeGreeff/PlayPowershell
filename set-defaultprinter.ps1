function set-defaultprinter {
[CmdletBinding()]
param (
[parameter(ValueFromPipeline=$true,
ValueFromPipelineByPropertyName=$true)]
[string]$computername="$env:COMPUTERNAME",
[string]$printer
)
PROCESS {
Get-WmiObject -Class Win32_Printer `
-ComputerName $computername -Filter "Name='$printer'" |
Invoke-WmiMethod -Name SetDefaultPrinter
}}