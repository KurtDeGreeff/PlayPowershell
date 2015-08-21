#@=============================================
#@ FileName: _Printer_Inventory.ps1
#@=============================================
#@ Script Name: Printer_Inventory
#@ Created: [DATE_DMY]- 07/04/2013 
#@ Author: Amol Patil
#@ Email: amolsptech@gmail.com
#@ Web: 
#@ Requirements: Printers
#@ OS: Windows 2003 / 2008 / R2
#@ Keywords:
#@ Version History:
#@=============================================
#@ Purpose: To collect printers details using printer server name.
#@
#@
#@=============================================

#@================Code Start===================
$SCRIPT_PARENT   = Split-Path -Parent $MyInvocation.MyCommand.Definition 

#=========================================================================
Function HostList {$Printservers =  Get-Content ($SCRIPT_PARENT + "\Servers.txt")}
# ========================================================================
Function Host { $Printservers = Read-Host "Enter Computer Name or IP"}
# ========================================================================
Function LocalHost { $Printservers = $env:computername }
#@========================================================================
#Gather info from user input.

Write-Host "********************************"               -ForegroundColor Green
Write-Host "Printers Inventory"                   -ForegroundColor Green
Write-Host "by: Amol Patil "                                -ForegroundColor Green
Write-Host "********************************"               -ForegroundColor Green
Write-Host " "

$strResponse = Read-Host "
[1] Computer Names from a File (Servers.txt).
[2] Enter a Computer Name manually.
------OR------
[3] Local Computer.

"

            If($strResponse -eq "1"){. HostList}
                elseif($strResponse -eq "2"){. Host}
                elseif($strResponse -eq "3"){. LocalHost}
                else{Write-Host "You did not supply a correct response, `

                Please run script again." -foregroundColor Red}                                                                

Write-Progress -Activity "Getting Inventory" -status "Running..." -id 1
#@========================================================================





# Create new Excel workbook
$Excel = New-Object -ComObject Excel.Application
$Excel.Visible = $True
$Excel = $Excel.Workbooks.Add()
$Sheet = $Excel.Worksheets.Item(1)
$Sheet.Name = "Printer Inventory"
#======================================================
$Sheet.Cells.Item(1,1) = "Print Server"
$Sheet.Cells.Item(1,2) = "Printer Name"
$Sheet.Cells.Item(1,3) = "Port Name"
$Sheet.Cells.Item(1,4) = "Share Name"
$Sheet.Cells.Item(1,5) = "Driver Name"
$Sheet.Cells.Item(1,6) = "Driver Version"
$Sheet.Cells.Item(1,7) = "Driver"
$Sheet.Cells.Item(1,8) = "Location"
$Sheet.Cells.Item(1,9) = "Comment"
$Sheet.Cells.Item(1,10) = "Shared"
#=======================================================
$intRow = 2
$WorkBook = $Sheet.UsedRange
$WorkBook.Interior.ColorIndex = 40
$WorkBook.Font.ColorIndex = 11
$WorkBook.Font.Bold = $True
#=======================================================
# Get printer information
#$SCRIPT_PARENT   = Split-Path -Parent $MyInvocation.MyCommand.Definition 
#$Printservers =  Get-Content ($SCRIPT_PARENT + "\Servers.txt") 

ForEach ($Printserver in $Printservers)
{   $Printers = Get-WmiObject Win32_Printer -ComputerName $Printserver
    ForEach ($Printer in $Printers)
    {
        if ($Printer.Name -notlike "Microsoft XPS*")
        {
            $Sheet.Cells.Item($intRow, 1) = $Printserver
            $Sheet.Cells.Item($intRow, 2) = $Printer.Name
            
        If ($Printer.PortName -notlike "*\*")
            {   $Ports = Get-WmiObject Win32_TcpIpPrinterPort -Filter "name = '$($Printer.Portname)'" -ComputerName $Printserver
                ForEach ($Port in $Ports)
                {
                    $Sheet.Cells.Item($intRow, 3) = $Port.HostAddress
                }
            }
            
            $Sheet.Cells.Item($intRow, 4) = $Printer.ShareName   
            $Sheet.Cells.Item($intRow, 5) = $Printer.DriverName
            
            ####################       
            $Drivers = Get-WmiObject Win32_PrinterDriver -Filter "__path like '%$($Printer.DriverName)%'" -ComputerName $Printserver
            ForEach ($Driver in $Drivers)
            {
                $Drive = $Driver.DriverPath.Substring(0,1)
                $Sheet.Cells.Item($intRow,6) = (Get-ItemProperty ($Driver.DriverPath.Replace("$Drive`:","\\$PrintServer\$Drive`$"))).VersionInfo.ProductVersion
                $Sheet.Cells.Item($intRow,7) = Split-Path $Driver.DriverPath -Leaf
            }
            ####################
            
            $Sheet.Cells.Item($intRow, 8) = $Printer.Location
            $Sheet.Cells.Item($intRow, 9) = $Printer.Comment
            $Sheet.Cells.Item($intRow, 10) = $Printer.Shared
            $intRow ++
        }
    }
    $WorkBook.EntireColumn.AutoFit() | Out-Null
}
 

$intRow ++ 
$Sheet.Cells.Item($intRow,1) = "Printer inventory completed - @AMOL PATIL@"
$Sheet.Cells.Item($intRow,1).Font.Bold = $True
$Sheet.Cells.Item($intRow,1).Interior.ColorIndex = 40
$Sheet.Cells.Item($intRow,2).Interior.ColorIndex = 40


$output = ($SCRIPT_PARENT + "\service_{0:yyyyMMdd-HHmm}.xlsx" -f (Get-Date))
$Excel.SaveAs($output)

#@================Code End=====================


