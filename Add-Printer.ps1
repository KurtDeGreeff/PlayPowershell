####################################################
# Change these values to the appropriate values in your environment

$PrinterIP = '10.10.10.10'
$PrinterPort = '9100'
$PrinterPortName = 'IP_' + $PrinterIP
$DriverName = 'KONICA MINOLTA bizhub C35P PS'
$DriverPath = '\\UNC_Path\To\My\Drivers'
$DriverInf = '\\UNC_Path\To\My\Drivers\KOBJQA__.inf'
$PrinterCaption = 'Konica Minolta C35P'
####################################################

### ComputerList Option 1 ###
# $ComputerList = @("lana", "lisaburger")

### ComputerList Option 2 ###
# $ComputerList = @()
# Import-Csv "C:\Temp\ComputersThatNeedPrinters.csv" | `
# % {$ComputerList += $_.Computer}

Function CreatePrinterPort {
param ($PrinterIP, $PrinterPort, $PrinterPortName, $ComputerName)
$wmi = [wmiclass]"\\$ComputerName\root\cimv2:win32_tcpipPrinterPort"
$wmi.psbase.scope.options.enablePrivileges = $true
$Port = $wmi.createInstance()
$Port.name = $PrinterPortName
$Port.hostAddress = $PrinterIP
$Port.portNumber = $PrinterPort
$Port.SNMPEnabled = $false
$Port.Protocol = 1
$Port.put()
}

Function InstallPrinterDriver {
Param ($DriverName, $DriverPath, $DriverInf, $ComputerName)
$wmi = [wmiclass]"\\$ComputerName\Root\cimv2:Win32_PrinterDriver"
$wmi.psbase.scope.options.enablePrivileges = $true
$wmi.psbase.Scope.Options.Impersonation = [System.Management.ImpersonationLevel]::Impersonate
$Driver = $wmi.CreateInstance()
$Driver.Name = $DriverName
$Driver.DriverPath = $DriverPath
$Driver.InfName = $DriverInf
$wmi.AddPrinterDriver($Driver)
$wmi.Put()
}

Function CreatePrinter {
param ($PrinterCaption, $PrinterPortName, $DriverName, $ComputerName)
$Printer = ([WMIClass]"\\$ComputerName\Root\cimv2:Win32_Printer")
$Printer.CreateInstance()
$Printer.Caption = $PrinterCaption
$Printer.DriverName = $DriverName
$Printer.PortName = $PrinterPortName
$Printer.DeviceID = $PrinterCaption
$Printer.Put()
}

foreach ($computer in $ComputerList) {
CreatePrinterPort -PrinterIP $PrinterIP -PrinterPort $PrinterPort `
-PrinterPortName $PrinterPortName -ComputerName $computer
InstallPrinterDriver -DriverName $DriverName -DriverPath `
$DriverPath -DriverInf $DriverInf -ComputerName $computer
CreatePrinter -PrinterPortName $PrinterPortName -DriverName `
$DriverName -PrinterCaption $PrinterCaption -ComputerName $computer
}
####################################################