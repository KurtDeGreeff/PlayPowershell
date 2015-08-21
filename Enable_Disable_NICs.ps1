if (get-wmiobject win32_networkadapterconfiguration -filter "IPEnabled='True'")
{
Get-NetAdapter | Disable-NetAdapter -Confirm:$false
}
else
{
Get-NetAdapter | Enable-NetAdapter -Confirm:$false
}

