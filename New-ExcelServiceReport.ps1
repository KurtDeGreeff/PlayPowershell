$Excel = New-Object -ComObject Excel.Application
$Excel.visible = $True

# create a new Excel workbook, and add one worksheet.
$ExcelWB = $Excel.Workbooks.Add()
$ExcelWS = $ExcelWB.Worksheets.Item(1)

#create a title for the report in the first two cells in the first row.
$ExcelWS.Cells.Item(1,1) = "Services Status Report"
$ExcelWS.Range("A1","B1").Cells.Merge()

#create a header for the table with two columns: Service Name and Service Status in the second row of the worksheet
$ExcelWS.Cells.Item(2,1) = "Services Name"
$ExcelWS.Cells.Item(2,2) = "Service Status"

#list all Windows services using the  Get-Service cmdlet and iterate over this
#list using the  ForEach loop to create a new row for each service in the list
$row = 3
ForEach($Service in Get-Service)
{
$ExcelWS.Cells.Item($row,1) = $Service.DisplayName
$ExcelWS.Cells.Item($row,2) = $Service.Status.ToString()
if($Service.Status -eq "Running")
{
$ExcelWS.Cells.Item($row,1).Font.ColorIndex = 10
$ExcelWS.Cells.Item($row,2).Font.ColorIndex = 10
}
Elseif($Service.Status -eq "Stopped")
{
$ExcelWS.Cells.Item($row,1).Font.ColorIndex = 3
$ExcelWS.Cells.Item($row,2).Font.ColorIndex = 3
}
$row++
}

#save the report and quit the Excel instance
$ExcelWS.SaveAs("$home\documents\ServicesStatusReport.xlsx")
$Excel.Quit()

#more info about Excel COM interface http://msdn.microsoft.com/en-us/library/microsoft.office.interop.excel.application.aspx