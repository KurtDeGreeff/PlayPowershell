function send-testpage {
[CmdletBinding()]
param (
[parameter(ValueFromPipeline=$true,
ValueFromPipelineByPropertyName=$true)]
[string]$computername="$env:COMPUTERNAME",
[parameter(ParameterSetName="NonDefPrint")]
[string]$printer,
[parameter(ParameterSetName="DefPrint")]
[switch]$default
)
PROCESS {
switch ($psCmdlet.ParameterSetName) {
NonDefPrint {$filt = "Name='$printer'"}
Defprint {$filt = "Default='$true'" }
}
$device = Get-WmiObject -Class Win32_printer `
-Filter $filt -ComputerName $computername
if ($device) {
$device | Invoke-WmiMethod -Name PrintTestPage
}
else {
"Printer not found"
}
}}