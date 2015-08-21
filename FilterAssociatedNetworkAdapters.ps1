#FilterAssociatedNetworkAdapters.ps1
Param($computer = "localhost")
function funline ($strIN)
{
$num = $strIN.length
for($i=1 ; $i -le $num ; $i++)
{ $funline = $funline + "=" }
Write-Host -ForegroundColor yellow $strIN
Write-Host -ForegroundColor darkYellow $funline
} #end funline
Write-Host -ForegroundColor cyan "Network adapter settings on $computer"
Get-WmiObject -Class win32_NetworkAdapterSetting `
-computername $computer |
Foreach-object `
{
If( ([wmi]$_.element).netconnectionstatus -eq 2)
{
funline("Adapter: $($_.setting)")
[wmi]$_.setting
[wmi]$_.element
} #end if
} #end foreach