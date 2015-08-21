 # cancel old print jobs
 (Get-WmiObject win32_printer -computer client1,client2... -filter "Portname = 'IP_w.x.y.z'").cancelalljobs()

 #delete the print driver :
(Get-WmiObject win32_printer -computer client1,client2... -filter "Portname = 'IP_w.x.y.z'").delete()

Get-WmiObject -Class Win32_Printer | Select-Object -Property *

#To add a new local printer, just add a new instance of Win32_Printer. 
#The example adds a new local printer and shares it over the network (provided you have sufficient privileges and the appropriate printer drivers):
$printerclass = [wmiclass]'Win32_Printer'
$printer = $printerclass.CreateInstance()
$printer.Name = $printer.DeviceID = 'NewPrinter'
$printer.PortName = 'LPT1:'
$printer.Network = $false
$printer.Shared = $true
$printer.ShareName = 'NewPrintServer'
$printer.Location = 'Office 12'
$printer.DriverName = 'HP LaserJet 3050 PCL5'
$printer.Put() 