Function Export-Xlsx {

<#
.SYNOPSIS
  Exports data to an Excel workbook
.DESCRIPTION
  Exports data to an Excel workbook and applies cosmetics.
  Optionally add a title, autofilter, autofit and a chart.
  Allows for export to .xls and .xlsx format. If .xlsx is
  specified but not available (Excel 2003) the data will
  be exported to .xls.
.NOTES
  Author:  Gilbert van Griensven
  Based on

http://www.lucd.info/2010/05/29/beyond-export-csv-export-xls/

.PARAMETER InputData
  The data to be exported to Excel
.PARAMETER Path
  The path of the Excel file.
  Defaults to %HomeDrive%\Export.xlsx.
.PARAMETER WorksheetName
  The name of the worksheet. Defaults to filename
  in $Path without extension.
.PARAMETER ChartType
  Name of an Excel chart to be added.
.PARAMETER Title
  Adds a title to the worksheet.
.PARAMETER SheetPosition
  Adds the worksheet either to the 'begin' or 'end' of
  the Excel file. This parameter is ignored when creating
  a new Excel file.
.PARAMETER ChartOnNewSheet
  Adds a chart to a new worksheet instead of to the
  worksheet containing data. The Chart will be placed after
  the sheet containing data. Only works when parameter
  ChartType is used.
.PARAMETER AppendWorksheet
  Appends a worksheet to an existing Excel file.
  This parameter is ignored when creating a new Excel file.
.PARAMETER Borders
  Adds borders to all cells. Defaults to True.
.PARAMETER HeaderColor
  Applies background color to the header row.
  Defaults to True.
.PARAMETER AutoFit
  Apply autofit to columns. Defaults to True.
.PARAMETER AutoFilter
  Apply autofilter. Defaults to True.
.PARAMETER PassThrough
  When enabled returns file object of the generated file.
.PARAMETER Force
  Overwrites existing Excel sheet. When this switch is
  not used but the Excel file already exists, a new file
  with datestamp will be generated. This switch is ignored
  when using the AppendWorksheet switch.
.EXAMPLE
  Get-Process | Export-Xlsx D:\Data\ProcessList.xlsx
.EXAMPLE
  Get-ADuser -Filter {enabled -ne $True} |
  Select-Object Name,Surname,GivenName,DistinguishedName |
  Export-Xlsx -Path 'D:\Data\Disabled Users.xlsx' -Title 'Disabled users of Contoso.com'
.EXAMPLE
  Get-Process | Sort-Object CPU -Descending |
  Export-Xlsx -Path D:\Data\Processes_by_CPU.xlsx
.EXAMPLE
  Export-Xlsx (Get-Process) -AutoFilter:$False -PassThrough |
  Invoke-Item
#>

  [CmdletBinding()]
  Param (
    [Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$True)]
    [ValidateNotNullOrEmpty()]
    $InputData,
    [Parameter(Position=1)]
    [ValidateScript({
        $ReqExt = [System.IO.Path]::GetExtension($_)
        (          $ReqExt -eq ".xls") -or
        (          $ReqExt -eq ".xlsx")
      })]
    $Path = (Join-Path $env:HomeDrive "Export.xlsx"),
    [Parameter(Position=2)] $WorksheetName = [System.IO.Path]::GetFileNameWithoutExtension($Path),
    [Parameter(Position=3)]
    [ValidateSet("xl3DArea","xl3DAreaStacked","xl3DAreaStacked100","xl3DBarClustered",
      "xl3DBarStacked","xl3DBarStacked100","xl3DColumn","xl3DColumnClustered",
      "xl3DColumnStacked","xl3DColumnStacked100","xl3DLine","xl3DPie",
      "xl3DPieExploded","xlArea","xlAreaStacked","xlAreaStacked100",
      "xlBarClustered","xlBarOfPie","xlBarStacked","xlBarStacked100",
      "xlBubble","xlBubble3DEffect","xlColumnClustered","xlColumnStacked",
      "xlColumnStacked100","xlConeBarClustered","xlConeBarStacked","xlConeBarStacked100",
      "xlConeCol","xlConeColClustered","xlConeColStacked","xlConeColStacked100",
      "xlCylinderBarClustered","xlCylinderBarStacked","xlCylinderBarStacked100","xlCylinderCol",
      "xlCylinderColClustered","xlCylinderColStacked","xlCylinderColStacked100","xlDoughnut",
      "xlDoughnutExploded","xlLine","xlLineMarkers","xlLineMarkersStacked",
      "xlLineMarkersStacked100","xlLineStacked","xlLineStacked100","xlPie",
      "xlPieExploded","xlPieOfPie","xlPyramidBarClustered","xlPyramidBarStacked",
      "xlPyramidBarStacked100","xlPyramidCol","xlPyramidColClustered","xlPyramidColStacked",
      "xlPyramidColStacked100","xlRadar","xlRadarFilled","xlRadarMarkers",
      "xlStockHLC","xlStockOHLC","xlStockVHLC","xlStockVOHLC",
      "xlSurface","xlSurfaceTopView","xlSurfaceTopViewWireframe","xlSurfaceWireframe",
      "xlXYScatter","xlXYScatterLines","xlXYScatterLinesNoMarkers","xlXYScatterSmooth",
      "xlXYScatterSmoothNoMarkers")]
    [PSObject] $ChartType,
    [Parameter(Position=4)] $Title,
    [Parameter(Position=5)] [ValidateSet("begin","end")] $SheetPosition = "begin",
    [Switch] $ChartOnNewSheet,
    [Switch] $AppendWorksheet,
    [Switch] $Borders = $True,
    [Switch] $HeaderColor = $True,
    [Switch] $AutoFit = $True,
    [Switch] $AutoFilter = $True,
    [Switch] $PassThrough,
    [Switch] $Force
  )
 
  Begin {
    Function Convert-NumberToA1 {
      Param([parameter(Mandatory=$true)] [int]$number)
      $a1Value = $null
      While ($number -gt 0) {
        $multiplier = [int][system.math]::Floor(($number / 26))
        $charNumber = $number - ($multiplier * 26)
        If ($charNumber -eq 0) { $multiplier-- ; $charNumber = 26 }
        $a1Value = [char]($charNumber + 96) + $a1Value
        $number = $multiplier
      }
      Return $a1Value
    }

    $Script:WorkingData = @()
  }
 
  Process {
    $Script:WorkingData += $InputData
  }
 
  End {
    $Props = $Script:WorkingData[0].PSObject.properties | % { $_.Name }
    $Rows = $Script:WorkingData.Count+1
    $Cols = $Props.Count
    $A1Cols = Convert-NumberToA1 $Cols
    $Array = New-Object 'object[,]' $Rows,$Cols

    $Col = 0
    $Props | % {
      $Array[0,$Col] = $_.ToString()
      $Col++
    }

    $Row = 1
    $Script:WorkingData | % {
      $Item = $_
      $Col = 0
      $Props | % {
        If ($Item.($_) -eq $Null) {
          $Array[$Row,$Col] = ""
        } Else {
          $Array[$Row,$Col] = $Item.($_).ToString()
        }
        $Col++
      }
      $Row++
    }

    $xl = New-Object -ComObject Excel.Application
    $xl.DisplayAlerts = $False
    $xlFixedFormat = [Microsoft.Office.Interop.Excel.XLFileFormat]::xlWorkbookNormal

    If ([System.IO.Path]::GetExtension($Path) -eq '.xlsx') {
      If ($xl.Version -lt 12) {
        $Path = $Path.Replace(".xlsx",".xls")
      } Else {
        $xlFixedFormat = [Microsoft.Office.Interop.Excel.XLFileFormat]::xlWorkbookDefault
      }
    }

    If (Test-Path -Path $Path -PathType "Leaf") {
      If ($AppendWorkSheet) {
        $wb = $xl.Workbooks.Open($Path)
        If ($SheetPosition -eq "end") {
          $wb.Worksheets.Add([System.Reflection.Missing]::Value,$wb.Sheets.Item($wb.Sheets.Count)) | Out-Null
        } Else {
          $wb.Worksheets.Add($wb.Worksheets.Item(1)) | Out-Null
        }
      } Else {
        If (!($Force)) {
          $Path = $Path.Insert($Path.LastIndexOf(".")," - $(Get-Date -Format "ddMMyyyy-HHmm")")
        }
        $wb = $xl.Workbooks.Add()
        While ($wb.Worksheets.Count -gt 1) { $wb.Worksheets.Item(1).Delete() }
      }
    } Else {
      $wb = $xl.Workbooks.Add()
      While ($wb.Worksheets.Count -gt 1) { $wb.Worksheets.Item(1).Delete() }
    }

    $ws = $wb.ActiveSheet
    Try { $ws.Name = $WorksheetName }
    Catch { }

    If ($Title) {
      $ws.Cells.Item(1,1) = $Title
      $TitleRange = $ws.Range("a1","$($A1Cols)2")
      $TitleRange.Font.Size = 18
      $TitleRange.Font.Bold=$True
      $TitleRange.Font.Name = "Cambria"
      $TitleRange.Font.ThemeFont = 1
      $TitleRange.Font.ThemeColor = 4
      $TitleRange.Font.ColorIndex = 55
      $TitleRange.Font.Color = 8210719
      $TitleRange.Merge()
      $TitleRange.VerticalAlignment = -4160
      $usedRange = $ws.Range("a3","$($A1Cols)$($Rows + 2)")
      If ($HeaderColor) {
        $ws.Range("a3","$($A1Cols)3").Interior.ColorIndex = 48
        $ws.Range("a3","$($A1Cols)3").Font.Bold = $True
      }
    } Else {
      $usedRange = $ws.Range("a1","$($A1Cols)$($Rows)")
      If ($HeaderColor) {
        $ws.Range("a1","$($A1Cols)1").Interior.ColorIndex = 48
        $ws.Range("a1","$($A1Cols)1").Font.Bold = $True
      }
    }

    $usedRange.Value2 = $Array

    If ($Borders) {
      $usedRange.Borders.LineStyle = 1
      $usedRange.Borders.Weight = 2
    }

    If ($AutoFilter) { $usedRange.AutoFilter() | Out-Null }

    If ($AutoFit) { $ws.UsedRange.EntireColumn.AutoFit() | Out-Null }

    If ($ChartType) {
      [Microsoft.Office.Interop.Excel.XlChartType]$ChartType = $ChartType
      If ($ChartOnNewSheet) {
        $wb.Charts.Add().ChartType = $ChartType
        $wb.ActiveChart.setSourceData($usedRange)
        Try { $wb.ActiveChart.Name = "$($WorksheetName) - Chart" }
        Catch { }
        $wb.ActiveChart.Move([System.Reflection.Missing]::Value,$wb.Sheets.Item($ws.Name))
      } Else {
        $ws.Shapes.AddChart($ChartType).Chart.setSourceData($usedRange) | Out-Null
      }
    }

    $wb.SaveAs($Path,$xlFixedFormat)
    $wb.Close()
    $xl.Quit()

    While ([System.Runtime.Interopservices.Marshal]::ReleaseComObject($usedRange)) {}
    While ([System.Runtime.Interopservices.Marshal]::ReleaseComObject($ws)) {}
    If ($Title) { While ([System.Runtime.Interopservices.Marshal]::ReleaseComObject($TitleRange)) {} }
    While ([System.Runtime.Interopservices.Marshal]::ReleaseComObject($wb)) {}
    While ([System.Runtime.Interopservices.Marshal]::ReleaseComObject($xl)) {}
    [GC]::Collect()

    If ($PassThrough) { Return Get-Item $Path }
  }
}