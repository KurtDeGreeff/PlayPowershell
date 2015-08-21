<# 
.SYNOPSIS 
    Creates a new zip file from an existing folder 
.DESCRIPTION 
    This script uses the .NET 4.5 zipfile class  
    to create a zip file, getting contents from  
    a folder. 
.NOTES 
    File Name  : New-ZipfromDirectory 
    Author     : Thomas Lee - tfl@psp.co.uk 
    Requires   : PowerShell Version 3.0 and .NET 4.5 
.LINK 
    This script posted to: 
        http://www.pshscripts.blogspot.com 
.EXAMPLE 
    Psh> C:\foo\new-zip.ps1 
    Zip file created: 
     
    Directory: C:\foo 
         
    Mode                LastWriteTime     Length Name 
    ----                -------------     ------ ---- 
    -a---         2/24/2013   3:00 PM     291182 ScriptLib.ZIP 
 
#> 
 
# Load the compression namespace 
# and yes, I know this usage is obsolete - but it works. 
# Ignore the output 
[System.Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem') | Out-Null  
 
# Create a type accellerator for the zipfile class 
[System.Type] $TypeAcceleratorsType=[System.Management.Automation.PSObject].Assembly.GetType('System.Management.Automation.TypeAccelerators',$True,$True) 
$TypeAcceleratorsType::Add('Zipfile','System.IO.Compression.Zipfile') 
 
# Now create a zip file 
# Set target zip flie and source folder 
$Folder  = 'C:\amazon' 
$Zipfile = 'C:\amazon.ZIP' 
 
# Ensure file does NOT exist and fodler DOES exist 
If (Test-Path $zipfile -EA -0) { 
   Throw "$Zipfile exists - not safe to continue"} 
If (!(Test-Path $folder)) { 
   "Throw $folder does not seem to exist"} 
    
# Now create the Zip file 
Try { 
  [Zipfile]::CreateFromDirectory( $folder, $zipfile) 
  "Zip file created:";ls $zipfile} 
Catch { 
  "Zip File NOT created" 
  $Error[0]} 