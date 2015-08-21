function Get-WirelessAdapter
{
  Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Network\*\*\Connection' -ErrorAction SilentlyContinue |
    Select-Object -Property MediaSubType, PNPInstanceID |
    Where-Object { $_.MediaSubType -eq 2 -and $_.PnpInstanceID } |
    Select-Object -ExpandProperty PnpInstanceID |
    ForEach-Object {
      $wmipnpID = $_.Replace('\', '\\')
      Get-WmiObject -Class Win32_NetworkAdapter -Filter "PNPDeviceID='$wmipnpID'"
    } 
} 
<#
Since the function returns a true WMI object, you can then determine whether the adapter is currently active, and enable or disable it.
This would identify the adapter, then disable it, then enable it again:
$adapter = Get-WirelessAdapter
$adapter.Disable().ReturnValue
$adapter.Enable().ReturnValue 
Note that a return code of 5 indicates that you do not have sufficient privileges. Run the script as an Administrator.
#>