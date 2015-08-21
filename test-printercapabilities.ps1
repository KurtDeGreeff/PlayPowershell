function test-printercapabilities {
[CmdletBinding(DefaultParameterSetName="Pcap")]
param (
[parameter(ValueFromPipeline=$true,
ValueFromPipelineByPropertyName=$true)]
[string]$computername="$env:COMPUTERNAME",
[parameter(ParameterSetName="Pcap")]
[string]
[ValidateSet("Duplex", "Color", "Collate")]
$capability="Color",
[parameter(ParameterSetName="Paper")]
[string]
[ValidateSet("Letter", "Legal", "Executive", "A4", "A3")]
$paper
)
PROCESS {
$printers = Get-WmiObject -Class Win32_Printer `
-ComputerName $computername
switch ($psCmdlet.ParameterSetName) {
"Pcap" {
"$capability printers on $computername"
$printers |
Where {$_.CapabilityDescriptions -contains $capability} |
select Name
}
"Paper" {
"$paper printers on $computername"
$printers |
Where {$_.PrinterPaperNames -contains $paper} |
select Name
}
}
}
}