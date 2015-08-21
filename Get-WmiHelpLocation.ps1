function Get-WmiHelpLocation
{
param ($WmiClassName='Win32_printer')
$Connected = [Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]'{DCB00C01-570F-4A9B-8D69-199FDBA5723B}')).IsConnectedToInternet
if ($Connected)
{
$uri = 'http://www.bing.com/search?q={0}+site:msdn.microsoft.com' -f $WmiClassName
$url = (Invoke-WebRequest -Uri $uri -UseBasicParsing).Links |
Where-Object href -like 'http://msdn.microsoft.com*' |
Select-Object -ExpandProperty href -First 1
Start-Process $url
$url
}
else
{
Write-Warning 'No Internet Connection Available.'
}
}
