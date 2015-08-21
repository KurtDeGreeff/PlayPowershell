Function Get-SystemReport
{
param
(
$ComputerName = $env:ComputerName
)
$htmlStart = “
<HTML><HEAD><TITLE>Server Report</TITLE>
<style>
body { background-color:#EEEEEE; }
body,table,td,th { font-family:Tahoma; color:Black; Font-Size:10pt }
th { font-weight:bold; background-color:#AAAAAA; }
td { background-color:white; }
</style></HEAD><BODY>
<h2>Report listing for System $Computername</h2>
<p>Generated $(Get-Date -Format ‘yyyy-MM-dd hh:mm’) </p>
“
$htmlEnd = ‘</body></html>’
$htmlStart
Get-WmiObject -Class CIM_PhysicalElement |
Group-Object -Property __Class |
ForEach-Object {
$_.Group |
Select-Object -Property * |
ConvertTo-Html -Fragment -PreContent (‘<h3>{0}</h3>’ -f $_.Name )
}
$htmlEnd
}
#And this is how you would call the function and create a report:
$path = “$env:temp\report.hta”
Get-SystemReport | Out-File -Filepath $path
Invoke-Item $path