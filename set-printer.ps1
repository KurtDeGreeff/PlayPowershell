function set-printer {
[CmdletBinding()]
param (
[parameter(ValueFromPipeline=$true,
ValueFromPipelineByPropertyName=$true)]
[string]$computername="$env:COMPUTERNAME",
[string]$printer,
[parameter(ParameterSetName="Pause")]
[switch]$pause,
[parameter(ParameterSetName="Resume")]
[switch]$resume,
[parameter(ParameterSetName="Cancel")]
[switch]$cancelall
)
PROCESS {
$device = Get-WmiObject -Class Win32_Printer `
-ComputerName $computername -Filter "Name='$printer'"
switch ($psCmdlet.ParameterSetName) {
Pause {$device | Invoke-WmiMethod -Name Pause}
Resume {$device | Invoke-WmiMethod -Name Resume }
Cancel {$device | Invoke-WmiMethod -Name CancelAllJobs }
}
}
}