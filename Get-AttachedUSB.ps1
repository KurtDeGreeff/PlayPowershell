#If you'd like to know whether there are currently USB storage devices attached to your computer, WMI can help:
Get-WmiObject -Class Win32_PnPEntity |  Where-Object { $_.DeviceID -like 'USBSTOR*' }
#This returns all plug and play devices with a device class of "USBSTOR".
#If you are willing to use the WMI query language (WQL), you could even do this in a cmdlet filter:
Get-WmiObject -Query 'Select * From Win32_PnPEntity where DeviceID Like "USBSTOR%"'