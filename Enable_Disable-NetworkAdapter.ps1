Function Disable-NetworkAdapter
{
param
(
$NetworkName
)
Get-WmiObject Win32_NetworkAdapter -Filter "NetConnectionID='$NetworkName'" |
ForEach-Object {
$rv = $_.Disable().ReturnValue
if ($rv -eq 0)
{
'{0} disabled' -f $_.Caption
}
else
{
'{0} could not be disabled. Error code {1}' -f $_.Caption, $rv
}
}
}

Function Enable-NetworkAdapter
{
param
(
$NetworkName
)
Get-WmiObject Win32_NetworkAdapter -Filter "NetConnectionID='$NetworkName'" |
ForEach-Object {
$rv = $_.Enable().ReturnValue
if ($rv -eq 0)
{
'{0} enabled' -f $_.Caption
}
else
{
'{0} could not be enabled. Error code {1}' -f $_.Caption, $rv
}
}
}

Function Restart-NetworkAdapter
{
param
(
$NetworkName
)
Disable-NetworkAdapter $NetworkName
Enable-NetworkAdapter $NetworkName
}

Restart-NetworkAdapter LAN-Connection