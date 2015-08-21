
# ----------------------------------------------------- 
function Release-Ref ($ref) { 
([System.Runtime.InteropServices.Marshal]::ReleaseComObject( 
[System.__ComObject]$ref) -gt 0) 
[System.GC]::Collect() 
[System.GC]::WaitForPendingFinalizers() 
} 
# ----------------------------------------------------- 
 
$objExcel = new-object -comobject excel.application  
$objExcel.Visible = $True  
$objWorkbook = $objExcel.Workbooks.Open("C:\Users\administrator\Desktop\scripts\groupmaps.xlsx") 

# write into cell B2 (column 2, line 2):
#$objWorkbook.ActiveSheet.Cells.Item(2,2)= "Test a Write"

# read cell content
#$content = $objWorkbook.ActiveSheet.Cells.Item(3,1).Text
#"Cell B2 content: $content"
$RowNum = 2

While ($objWorkbook.ActiveSheet.Cells.Item($RowNum, 1).Text -ne "") {
 
    
    
    $lusername = $objWorkbook.ActiveSheet.Cells.Item($RowNum,2).Text
    Import-Csv C:\Users\administrator\Desktop\scripts\usermaps.csv | foreach {
		if ($lusername -eq $_.ousername){
			#Write-Host Match $lusername $_.ousername $_.nusername
			$objWorkbook.ActiveSheet.Cells.Item($RowNum,4)= $_.nusername
			$objWorkbook.ActiveSheet.Cells.Item($RowNum,5)= $_.DisplayName
		}
	}
	           
    $RowNum++
}
 
 
#close 
$a = Release-Ref($objWorkbook) 
$a = Release-Ref($objExcel)