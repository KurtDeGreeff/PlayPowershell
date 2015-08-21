function get-printerdriver {
[CmdletBinding()]
param (
[parameter(ValueFromPipeline=$true,
ValueFromPipelineByPropertyName=$true)]
[string]$computername="$env:COMPUTERNAME",
[string]$printer
)
PROCESS {
$query = "ASSOCIATORS OF {Win32_Printer.DeviceId='$printer'} WHERE ResultClass = Win32_PrinterDriver"
$driver = Get-WmiObject -ComputerName $computername -Query $query
"Driver for $printer"
$driver | select Version, SupportedPlatform, OEMUrl,DriverPath, ConfigFile, DataFile, HelpFile
" Dependent Files"
$driver | select -ExpandProperty DependentFiles
}}