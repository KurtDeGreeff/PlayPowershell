##############################################################################
#  Script: Get-ParentFolderOfThisScript.ps1
#    Date: 19.Jun.2007
# Version: 1.0
# Purpose: A function to be used in a script, to return the path of the folder
#          which contains the script.  Useful when dot-sourcing another file
#          from within the script.
#  Credit: Credit for this function goes to Jeff Snover from the PS blog:
#          http://blogs.msdn.com/powershell/archive/2007/06/19/get-scriptdirectory.aspx
#   Legal: Script provided "AS IS" without warranties or guarantees of any
#          kind.  USE AT YOUR OWN RISK.  Public domain, no rights reserved.
##############################################################################




function Get-ParentFolderOfThisScript
{
    # Get $MyInvocation variable of the parent scope (1) that launched this script.
    $ParentProcessInvocation = Get-Variable MyInvocation -Scope 1

    # This gets an System.Management.Automation.InvocationInfo object.
    $InvocationInfo = $ParentProcessInvocation.Value

    # This gets a System.Management.Automation.CommandInfo object.
    $CommandInfo = $InvocationInfo.MyCommand

    # Extract the full path to this script, including name of script.
    $FullPathToThisScript = $CommandInfo.Path

    # Extract just the parent folder path to this script, no script name.
    Split-Path -parent $FullPathToThisScript
}


Get-ParentFolderOfThisScript




########################################################################
# Same function, but much more compact and somewhat less understandable.
########################################################################

function Get-ParentFolderOfThisScript
{
    $InvocationInfo = (Get-Variable MyInvocation -Scope 1).Value
    Split-Path -parent $InvocationInfo.MyCommand.Path
}

Get-ParentFolderOfThisScript





########################################################################
# Here is the same function, but even less understandable.  Where is the
# happy middle ground?  It's a matter of stylistic choice, but just 
# don't leave yourself scratching your head when you look at your own
# code six months later...
########################################################################

function Get-ParentFolderOfThisScript { 
    Split-Path $((Get-Variable MyInvocation -Scope 1).Value).MyCommand.Path 
}


Get-ParentFolderOfThisScript




