#Get WebMin XML Content
[xml]$printer = get-content "D:\Printer.xml"

#Find printers matching local computername
$p = $printer.PRINTERLIST.PRINTER | ? {$_.PCACCESS.PCNAME  -eq "mvpe1029951"}

#For each matched printer, give drivername, driverpath, ipaddress
foreach ($item in $p.PROPERTIES)
{
$item.DRIVERNAME
$item.DRIVERPATH
$item.IPADD    
}


ymukvmgxl


$printer.PRINTERLIST.PRINTER.SelectSingleNode("//PCACCESS[contains(PCNAME, 'pe1029937')]")


#USE XPATH TO SEARCH FOR NODES
# this is where the XML sample file was saved
$Path = "D:\Printer.xml"
# load it into an XML object
$xml = New-Object -TypeName XML
$xml.Load($Path)
$i = Select-Xml -Xml $xml -XPath '//PRINTER/PCACCESS[PCNAME="mvpe1029951"]'
$i.Node


# Accessing Single Nodes and Modifying Data    
$employee.function = "vacation"
$xmldata.staff.employee
# Using SelectNodes() to Choose Nodes, which the XPath query language supports
$printer.PRINTERLIST.PRINTER.PCACCESS
$xmldata = [xml](Get-Content D:\Printer.xml)
$xmldata.SelectNodes("PRINTERLIST/PRINTER")
$xmldata.SelectNodes("PRINTERLIST/PRINTER/PCACCESS[PCNAME=mvpe1029951]")
