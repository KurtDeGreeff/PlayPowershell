function Add-PST {
<#

.SYNOPSIS
Add PST file to outlook.  Does not require elevated credentials

.DESCRIPTION
Uses the Outlook.Application COM object to interface with outlook and programatically add PST files.  Able to accept pipeline infor, either as a string of a file object.

.EXAMPLE
Add-PST c:\archive\archive.pst

Adds archive.pst

.EXAMPLE
get-childitem -recurse c:\ -erroraction SilentlyContinue -include *.pst | out-Gridview -OutputMode Multiple | add-pst

Searches through the c drive for all PST files, presents them to the user for selection, and then add the selected files to the local outlook client.

.EXAMPLE
get-content c:\pstlist.txt | add-pst

Adds each pst file listed in Pstlist.txt to the local outlook client.

.NOTES
Written by Jason Morgan
Created on: 1/28/2014
Last Modified: 1/29/2014
Last Modified by Jason Morgan
Version 1.1

#Added help

#>
Param 
    (
        # Enter the path to the PST file, must be an absolute path
        [parameter(Mandatory=$true,
        ValueFromPipeline=$true,
        valuefrompipelinebypropertyname=$true)]
        [Alias('fullname')]
        [ValidateScript({([System.IO.Path]::IsPathRooted($_)) -and ($_.endswith('.pst'))})]
        [string]$path
    ) 
Begin 
    {
        Try {$email = New-Object -ComObject outlook.application}
        Catch {Throw "Unable to connect to the local outlook client"}
    } 
Process 
    {
        Try {$email.Session.AddStore($path)} Catch {Write-Warning "Unable to add $path to outlook"}
    }
}
