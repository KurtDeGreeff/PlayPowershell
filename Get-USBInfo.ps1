function Get-USBInfo {param ($FriendlyName = '*')
Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\USBSTOR\*\*\' |
Where-Object { $_.FriendlyName } |
Where-Object { $_.FriendlyName -like $FriendlyName } |
Select-Object -Property FriendlyName, Mfg |
Sort-Object -Property FriendlyName
}
