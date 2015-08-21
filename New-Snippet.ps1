<#
.SYNOPSIS
    This script creates a new snippet for PowerShell V3 ISE
.DESCRIPTION
    This script used the New-ISESnippet command to create
    a new ISE Snippet 
.NOTES
    File Name  : New-Snippet.ps1
    Author     : Thomas Lee - tfl@psp.co.uk
    Requires   : PowerShell Version 2.0
.LINK
    This script posted to:
        http://www.pshscripts.blogspot.com
   
.EXAMPLE
    When you run this script, there is no output created. To
    see the snippet use Get-ISESnippet
#>

# define the snippet
$snippet = @"
<#g
.SYNOPSIS
    This script
.DESCRIPTION
    This script 
.NOTES
    File Name  : 
    Author     : Thomas Lee - tfl@psp.co.uk
    Requires   : PowerShell Version 2.0
.LINK
    This script posted to:
        http://www.pshscripts.blogspot.com
    MSDN sample posted to:
         http://   
.EXAMPLE
    
#>
"@

#    And set description
$desc = "Content Based Help block for script or function"

#    Now create new snippet
New-IseSnippet -Title CBH-Help-Block -Description $desc -Text $snippet
#