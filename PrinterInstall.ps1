#Get WebMin XML Content
[xml]$printers = get-content "d:\Printers\Printer.xml"

#Find printers matching local computername
$printers.PRINTERLIST.PRINTER | ? {$_.PCACCESS.PCNAME  -eq "$env:computername"} | 

ForEach-Object { 

#Install print drivers
$DriverClass = [wmiclass]"Win32_PrinterDriver"
$Driver = $DriverClass.CreateInstance()
$Driver.Name = $_.PROPERTIES.DRIVERNAME
$Driver.DriverPath = $_.PROPERTIES.DRIVERPATH
$Driver.InfName = (join-path -path $_.PROPERTIES.DRIVERPATH -childpath $_.PROPERTIES.INFNAME)
$DriverClass.AddPrinterDriver($Driver)
$DriverClass.Put()

#Install printer ports
$PortClass = [wmiclass]"Win32_TCPIPPrinterPort"
$Port = $PortClass.CreateInstance()
$Port.Name = $_.PROPERTIES.IPADD
$Port.HostAddress = $_.PROPERTIES.IPADD
$Port.SNMPEnabled = $false
$Port.Protocol = 1  # 1=RAW 2=LPT1
$Port.PortNumber = 9100
$Port.Put()

#Install printers, see additional methods for PrintTestPage,SetDefaultPrinter,..
$PrinterClass = [wmiclass]"Win32_Printer"
$Printer = $PrinterClass.CreateInstance()
$Printer.DriverName = $_.PROPERTIES.DRIVERNAME
$Printer.Name = $_.PrinterName
$Printer.PortName = $_.PROPERTIES.IPADD
$Printer.Shared = $false
$Printer.Published = $false
$Printer.DeviceID = $_.PrinterName
$Printer.Put()
#$PrinterClass.AddPrinterConnection($Printer)
#$PrinterClass.Put()

}

