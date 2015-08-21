$pp = DATA {
ConvertFrom-StringData -StringData @'
1 = RAW Printing directly to a device or print server.
2 = LPR Legacy protocol, which is eventually replaced by RAW
'@
}
function get-tcpport {
[CmdletBinding()]
param (
[parameter(ValueFromPipeline=$true,
ValueFromPipelineByPropertyName=$true)]
[string]$computername="$env:COMPUTERNAME"
)
PROCESS {
Get-WmiObject -Class Win32_TCPIPPrinterPort `
-ComputerName $computername |
select Name, HostAddress, PortNumber,
@{N="Protocol"; E={$pp["$($_.Protocol)"]}},
SNMPCommunity, SNMPDevIndex, SNMPEnabled
}}