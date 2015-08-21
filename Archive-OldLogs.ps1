<#The example script looks for log files with the extension *.log inside the Windows folder and all of its subfolders. 
Any log file older than 14 days (defined as not being modified within the past 14 days) is moved to c:\archive. 
This folder is created if it does not yet exist.
You would need Administrator privileges to actually move files out of the Windows folder.#>

#requires -Version 1 
# how old (in days) would obsolete files be 
$Days = 14 
 
# where to look for obsolete files 
$Path = $env:windir 
$Filter = '*.log' 
 
# where to move obsolete files 
$DestinationPath = 'c:\archive' 
 
# make sure destination folder exists 
$destinationExists = Test-Path -Path $DestinationPath 
if (!$destinationExists)
{
    $null = New-Item -Path $DestinationPath -ItemType Directory 
}
 
$cutoffDate = (Get-Date).AddDays(-$Days)
 
Get-ChildItem -Path $Path -Filter $Filter -Recurse -ErrorAction SilentlyContinue | 
Where-Object -FilterScript {
    $_.LastWriteTime -lt $cutoffDate 
} |
Move-Item -Destination c:\archive -WhatIf