<# 
.SYNOPSIS 
    This function converts a PPTx file into a PDF file 
.DESCRIPTION 
    The Convert-PptxToPDF function first creates an  
    instance of PowerPoint, opens the $ifile and saves 
    this to $ofile as a PDF file. 
.NOTES 
    File Name  : Convert-PptxToPDF 
    Author     : Thomas Lee - tfl@psp.co.uk 
    Requires   : PowerShell Version 3.0, Office 2010 
.LINK 
    This script posted to: 
        http://www.pshscripts.blogspot.com 
     
.EXAMPLE 
    There is nothing to see, except a set of new PDF Files in the output folder         
 
#> 
 
Function Convert-PptxToPDF { 
 
[CmdletBinding()] 
Param( 
$IFile, 
$OFile 
) 
 
# add key assemblies 
Add-type -AssemblyName office -ErrorAction SilentlyContinue 
Add-Type -AssemblyName microsoft.office.interop.powerpoint -ErrorAction SilentlyContinue 
 
# Open PowerPoint 
$ppt = new-object -com powerpoint.application 
$ppt.visible = [Microsoft.Office.Core.MsoTriState]::msoFalse 
 
 
# Open the $Ifile presentation 
$pres = $ppt.Presentations.Open($ifile) 
 
# Now save it away as PDF 
$opt= [Microsoft.Office.Interop.PowerPoint.PpSaveAsFileType]::ppSaveAsPDF 
$pres.SaveAs($ofile,$opt) 
 
# and Tidy-up 
$pres.Close() 
$ppt.Quit() 
$ppt=$null 
 
} 
 
 
# Test it 
 
$ipath = "E:\SkyDrive\PowerShell V3 Geek Week\" 
 
Foreach ($ifile in $(ls $ipath -Filter "*.pptx")) { 
  # Build name of output file 
  $pathname = split-path $ifile 
  $filename = split-path $ifile -leaf  
  $file     = $filename.split(".")[0] 
  $ofile    = $pathname + $file + ".pdf" 
 
  # Convert _this_ file to PDF 
   Convert-PptxToPDF -ifile $ifile -OFile $ofile 
} 