##############################################################################
##
## New-ZipFile
##
## From Windows PowerShell Cookbook (O'Reilly)
## by Lee Holmes (http://www.leeholmes.com/guide)
##
##############################################################################
<#
.SYNOPSIS
Create a zip file from any files piped in.
.EXAMPLE
PS > dir *.ps1 | New-ZipFile scripts.zip
Copies all PS1 files in the current directory to scripts.zip
20.25. Program: Create a ZIP Archive | 595
.EXAMPLE
PS > "readme.txt" | New-ZipFile docs.zip
Copies readme.txt to docs.zip
#>
param(
## The name of the zip archive to create
$Path = $(throw "Specify a zip file name"),
## Switch to delete the zip archive if it already exists.
[Switch] $Force
)
Set-StrictMode -Version 3
## Create the Zip File
$zipName = $executionContext.SessionState.`
Path.GetUnresolvedProviderPathFromPSPath($Path)
## Check if the file exists already. If it does, check
## for -Force - generate an error if not specified.
if(Test-Path $zipName)
{
if($Force)
{
Remove-Item $zipName -Force
}
else
{
throw "Item with specified name $zipName already exists."
}
}
## Add the DLL that helps with file compression
Add-Type -Assembly System.IO.Compression.FileSystem
try
{
## Open the Zip archive
$archive = [System.IO.Compression.ZipFile]::Open($zipName, "Create")
## Go through each file in the input, adding it to the Zip file
## specified
foreach($file in $input)
{
## Skip the current file if it is the zip file itself
if($file.FullName -eq $zipName)
{
continue
596 | Chapter 20: Files and Directories
}
## Skip directories
if($file.PSIsContainer)
{
continue
}
$item = $file | Get-Item
$null = [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
$archive, $item.FullName, $item.Name)
}
}
finally
{
## Close the file
$archive.Dispose()
$archive = $null
}
