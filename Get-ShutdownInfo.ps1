function Get-ShutdownInfo
{
Get-EventLog -LogName system -InstanceId 2147484722 -Source user32 |
ForEach-Object {
$result = 'dummy' | Select-Object -Property ComputerName, TimeWritten, User, Reason, Action, Executable
$result.TimeWritten = $_.TimeWritten
$result.User = $_.ReplacementStrings[6]
$result.Reason = $_.ReplacementStrings[2]
$result.Action = $_.ReplacementStrings[4]
$result.Executable = Split-Path -Path $_.ReplacementStrings[0] -Leaf
$result.ComputerName = $_.MachineName
$result }
} 