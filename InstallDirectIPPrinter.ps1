#This script shows different methods to installing a printer via Direct IP
﻿#And can be used to follow along while watching the associated video http://www.youtube.com/watch?v=E2x6NG72tn4
﻿
﻿
﻿
switch ([system.environment]::OSVersion.Version.Major) {

    5 {$PrnVBSDir = "$env:windir\system32"}
    6 {$PrnVBSDir = "$env:windir\System32\Printing_Admin_Scripts\en-US\"}
}

######################################################################
###################### Deploy Driver #################################
######################################################################

&C:\Users\Fern\Desktop\lj4200pcl5winxp2003vista2008-64.exe /auto C:\Users\Fern\Desktop\driver

Write-Host "TOO FAST" -ForegroundColor Green


Start-Process "C:\Users\Fern\Desktop\lj4200pcl5winxp2003vista2008-64.exe" -ArgumentList '/auto "C:\Users\Fern\Desktop\driver"' -Wait

Write-Host "TOO FAST" -ForegroundColor Green

#\\server\share\driver\hpc4200c.inf

################################################################################
################# Installing the printer driver ################################
################################################################################

&rundll32 printui.dll PrintUIEntry

Start-Process "RunDll32" -ArgumentList 'printui.dll PrintUIEntry /ia /m "HP LaserJet 4200 PCL 5e" /h "x64" /v "Type 3 - User Mode" /f "C:\Users\Fern\Desktop\driver\hpc4200t.inf"' -Wait

start-process "printui.exe" -ArgumentList '/ia /m "HP LaserJet 4200 PCL 5e" /h "x64" /v "Type 3 - User Mode" /f "C:\Users\Fern\Desktop\driver\hpc4200t.inf"' -Wait

#---------------------------------------------------------------------------------
#----------------------- VBS METHOD ---------------------------------------------
#---------------------------------------------------------------------------------


&cscript "$PrnVBSDir\prndrvr.vbs" -a -m "HP LaserJet 4200 PCL 5e" -v 3 -e "Windows x64"


#---------------------------------------------------------------------------------
#----------------------Modify Printer Drivers ------------------------------------
#---------------------------------------------------------------------------------

$Driver = Get-WmiObject win32_printerdriver | where {$_.name -imatch "HP LaserJet 4200 PCL 5e"}

$Driver.delete()

######################################################################
################## Create the printer port ###########################
######################################################################

$Port = ([wmiclass]"win32_tcpipprinterport").createinstance()

$Port.Name = "MyPrinterPort"
$Port.HostAddress = "192.168.1.25"
$Port.Protocol = "1"
$Port.PortNumber = "9100"
$Port.SNMPEnabled = $false
$Port.Description = "Testing Create Port"

$Port.Put()

#---------------------------------------------------------------------------------
#--------------Modify Existing Ports----------------------------------------------
#---------------------------------------------------------------------------------

$Port = Get-WmiObject win32_tcpipprinterport | where {$_.name -ilike "MyPrinterPort"}

$Port.Delete()

$Port.Name = "MyPrinterPort2"
$Port.HostAddress = "192.168.1.30"

$Port.Put()

#---------------------------------------------------------------------------------
#---------------------Create Port VBS Method--------------------------------------
#---------------------------------------------------------------------------------

&cscript "$PrnVBSDir\prnport.vbs" -a -md -r "MyPrinterPort4" -h "192.168.1.25" -o "raw" -n "9100"

######################################################################
################# Installing The Printer #############################
######################################################################

#---------------------------------------------------------------------------------
#------------------VBS Method-----------------------------------------------------
#---------------------------------------------------------------------------------

&cscript "$PrnVBSDir\prnmngr.vbs" -a -p "PrinterName" -m "HP LaserJet 4200 PCL 5e" -r "MyPrinterPort2"

#---------------------------------------------------------------------------------
#--------------------WMI Method--------------------------------------------
#---------------------------------------------------------------------------------

$Printer = ([wmiclass]"win32_Printer").createinstance()

$Printer.Name = "MyWMIPrinter2"
$Printer.DriverName = "HP LaserJet 4200 PCL 5e"
$Printer.DeviceID = "MyWMIPrinter"
$Printer.Shared = $false
$Printer.PortName = "MyPrinterPort4"

$Printer.Put()

#---------------------------------------------------------------------------------
#-----------------Modify Existing Printer-----------------------------------------
#---------------------------------------------------------------------------------

$Printer = Get-WmiObject win32_printer | where {$_.name -ilike "myWMIPrinter"}

$Printer.PortName = "MyPrinterPort2"

$Printer.put()

$Printer.delete()