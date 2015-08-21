<#
.SYNOPSIS
HTML System Inventory Report
.DESCRIPTION
Create an HTML System Inventory Report for multiple computers
.PARAMETER ComputerName
Supply a name(s) of the computer(s) to create a report for
.PARAMETER ReportFile
Path to export the report file to
.PARAMETER ImagePath
Path to an image file to place at the top of the report
.EXAMPLE
Get-HTMLSystemsInventoryReport -ComputerName Server01 -ReportFile 
C:\Report\InventoryReport.html -ImagePath C:\Report\Image.jpg
#>
[CmdletBinding()]
Param
( 
[Parameter(Mandatory=$true, 
ValueFromPipeline=$true,
ValueFromPipelineByPropertyName=$true, 
Position=0)]
[ValidateNotNullOrEmpty()]
[Alias("CN","__SERVER","IPAddress","Server")]
[String[]]
$ComputerName,
[Parameter(Mandatory=$true,
Position=1)]
[ValidateNotNullOrEmpty()]
[String]
$ReportFile,
[Parameter(Position=2)] 
[String]
$ImagePath
) 
begin {
# --- Check whether the parameter is specified or from the pipeline
$UsedParameter = $False
if ($PSBoundParameters.ContainsKey('ComputerName')){
$UsedParameter = $True
$InputObject = $ComputerName
}
if (!(Test-Path (Split-Path $ReportFile))){
throw "$(Split-Path $ReportFile) is not a valid path to the report 
file"
} 
# Set the HTML header
$HTMLHeader = @" 
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" 
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
<head>
<title>Systems Inventory</title>
<style type="text/css">
<!--body {
background-color: #66CCFF;
} 
table {
background-color: white;
margin: 5px;
top: 10px;
display: inline-block;
padding: 5px;
border: 1px solid black
} 
h2 {
clear: both;
font-size: 150%;
margin-left: 10px;
margin-top: 15px;
} 
h3 {
clear: both;
color: #FF0000;
font-size: 115%;
margin-left: 10px;
margin-top: 15px;
} 
p {
color: #FF0000;
margin-left: 10px;
margin-top: 15px; 
} 
tr:nth-child(odd) {background-color: lightgray}
--> 
</style>
</head>
<body>
"@
# Function to encode image file to Base64
function Get-Base64Image ($Path) {
[Convert]::ToBase64String((Get-Content $Path -Encoding Byte))
} 
# Create the HTML code to embed the image into the webpage
if ($ImagePath) {
if (Test-Path -Path $ImagePath) {
$HeaderImage = Get-Base64Image -Path $ImagePath
$ImageHTML = @"
<img src="data:image/jpg;base64,$($HeaderImage)" style="left: 150px" 
alt="System Inventory">
"@
} 
else {
throw "$($ImagePath) is not a valid path to the image file"
} 
} 
function New-PieChart {
<#
.SYNOPSIS
Create a new Pie Chart using .Net Chart Controls
.DESCRIPTION
Create a new Pie Chart using .Net Chart Controls
.PARAMETER Title
Title of the chart
.PARAMETER Width
Width of the chart
.PARAMETER Height
Height of the chart
.PARAMETER Alignment
Alignment of the chart
.PARAMETER SeriesName
Name of the data series
.PARAMETER xSeries
Property to use for x series
.PARAMETER ySeries
Property to use for y series
.PARAMETER Data
Data for the chart
.PARAMETER ImagePath
Path to save a png of the chart to
.EXAMPLE
New-PieChart -Title "Service Status" -Series "Service" -xSeries 
"Name" -ySeries "Count" -Data $Services -ImagePath C:\Report\Image.jpg
#>
[CmdletBinding()]
Param
( 
[Parameter(Mandatory=$true)]
[ValidateNotNullOrEmpty()]
[String]$Title,
[Parameter(Mandatory=$false)]
[ValidateNotNullOrEmpty()]
[Int]$Width = 400,
[Parameter(Mandatory=$false)]
[ValidateNotNullOrEmpty()]
[Int]$Height = 400,
[Parameter(Mandatory=$false)]
[ValidateSet("TopLeft","TopCenter","TopRight",
"MiddleLeft","MiddleCenter","MiddleRight",
"BottomLeft","BottomCenter","BottomRight")]
[String]$Alignment = "TopCenter",
[Parameter(Mandatory=$true)]
[ValidateNotNullOrEmpty()]
[String]$SeriesName,
[Parameter(Mandatory=$true)]
[ValidateNotNullOrEmpty()]
[String]$xSeries,
[Parameter(Mandatory=$true)]
[ValidateNotNullOrEmpty()]
[String]$ySeries,
[Parameter(Mandatory=$true)]
[ValidateNotNullOrEmpty()]
[PSObject]$Data,
[Parameter(Mandatory=$true)]
[ValidateNotNullOrEmpty()] 
[String]$ImagePath
) 
[void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms.Data
Visualization")
# --- Create the chart object
$Chart = New-Object 
System.Windows.Forms.DataVisualization.Charting.Chart
$Chart.Width = $Width
$Chart.Height = $Height
# --- Set the title and its alignment
[void]$Chart.Titles.Add("$Title")
$Chart.Titles[0].Alignment = $Alignment
$Chart.Titles[0].Font = "Calibri,20pt"
# --- Create the chart area and set it to be 3D
$ChartArea = New-Object 
System.Windows.Forms.DataVisualization.Charting.ChartArea
$ChartArea.Area3DStyle.Enable3D = $true
$Chart.ChartAreas.Add($ChartArea) 
# --- Create the data series and pie chart style
[void]$Chart.Series.Add($SeriesName)
$Chart.Series[$SeriesName].ChartType = "Pie"
$Chart.Series[$SeriesName]["PieLabelStyle"] = "Outside"
$Data | ForEach-Object {$Chart.Series[$SeriesName].Points.Addxy( 
$_.$xSeries , $_.$ySeries) } | Out-Null
$Chart.Series[$SeriesName].Points.FindMaxByValue()["Exploded"] = 
$true
# --- Save the chart to a png file
$Chart.SaveImage("$ImagePath","png")
} 
} 
process {
if (!($UsedParameter)){
$InputObject = $_
} 
foreach ($Computer in $InputObject){
# --- Inventory Queries
$OperatingSystem = Get-WmiObject Win32_OperatingSystem -ComputerName $Computer
$ComputerSystem = Get-WmiObject Win32_ComputerSystem -ComputerName 
$Computer
$LogicalDisk = Get-WmiObject Win32_LogicalDisk -ComputerName 
$Computer
$NetworkAdapterConfiguration = Get-WmiObject -Query "Select * From 
Win32_NetworkAdapterConfiguration Where IPEnabled = 1" -ComputerName 
$Computer
$Services = Get-WmiObject Win32_Service -ComputerName $Computer
$Hotfixes = Get-HotFix -ComputerName $Computer
# --- Variable Build
$Hostname = $ComputerSystem.Name
$DNSName = $OperatingSystem.CSName +"." + 
$NetworkAdapterConfiguration.DNSDomain
$OSName = $OperatingSystem.Caption
$Manufacturer = $ComputerSystem.Manufacturer
$Model = $ComputerSystem.Model
$Resources = [pscustomobject] @{
NoOfCPUs = $ComputerSystem.NumberOfProcessors
RAMGB = $ComputerSystem.TotalPhysicalMemory /1GB -as [int]
NoOfDisks = ($LogicalDisk | Where-Object {$_.DriveType -eq 3} | 
Measure-Object).Count
} 
# --- Insert Pie Chart
$StartMode = $Services | Group-Object StartMode
$PieChartPath = Join-Path (Split-Path $script:MyInvocation.MyCommand.Path) -ChildPath ServicesChart.png
New-PieChart -Title "Service StartMode" -Series "Service StartMode 
by Type" -xSeries "Name" -ySeries "Count" -Data $StartMode -ImagePath 
$PieChartPath
$PieImage = Get-Base64Image -Path $PieChartPath
$ServiceImageHTML = @"
<img src="data:image/jpg;base64,$($PieImage)" style="right: 150px" 
alt="Services">
"@
# HTML Build
$ServicesHTML = $Services | Sort-Object 
@{Expression="State";Descending=$true},@{Expression="Name";Descending=$false} | 
Select-Object Name,State | ConvertTo-Html -Fragment
$ServicesFormattedHTML = $ServicesHTML | ForEach {
$_ -replace "<td>Running</td>","<td style='color: 
green'>Running</td>" -replace "<td>Stopped</td>","<td style='color: 
red'>Stopped</td>"
} 
$HotfixesHTML = $Hotfixes | Sort-Object Description | Select-Object HotfixID,Description,InstalledBy,Installedon | ConvertTo-Html -Fragment
$HotfixesFormattedHTML = $HotfixesHTML | ForEach {
$_ -replace "<td>Update</td>","<td style='color: 
blue'>Update</td>" -replace "<td>Security Update</td>","<td style='color: 
red'>Security Update</td>"
} 
$ResourcesHTML = $Resources | ConvertTo-Html -Fragment
# --- Set the HTML content
$ItemHTML = @"
<hr noshade size=5 width="100%">
<p><h2>$Hostname</p></h2>
<h3>System</h3>
<table>
<tr>
<td>DNS Name</td>
<td>$DNSName</td>
</tr>
<tr>
<td>Operating System</td>
<td>$OSName</td>
</tr>
<tr>
<td>Manufacturer</td>
<td>$Manufacturer</td>
</tr>
<tr>
<td>Model</td>
<td>$Model</td>
</tr>
</table>
<br></br>
<hr noshade size=1 width="100%">
<h3>Services</h3>
<p>Installed Services</p>
$ServicesFormattedHTML
$ServiceImageHTML
<hr noshade size=1 width="100%">
<h3>Hotfixes</h3>
<p>Installed Hotfixes</p>
$HotfixesFormattedHTML
<br></br>
<hr noshade size=1 width="100%">
<h3>Resources</h3>
<p>Installed Resources</p>
$ResourcesHTML
"@ 
$HTMLSystemReport += $ItemHTML
} 
} 
end {
$HTMLHeader +$ImageHTML + $HTMLSystemReport | Out-File $ReportFile
}
