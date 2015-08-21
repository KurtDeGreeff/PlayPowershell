<# 
.SYNOPSIS 
    This script gets all the exceptions you can trap by PowerShell 
.DESCRIPTION 
    This script looks at all the loaded assemblies to get all 
    the exceptions you can trap/catch using PowerShell. The 
    display only covers those parts of the .NET framework are loaded. 
.NOTES 
    File Name  : Show-Exceptions.ps1 
    Author     : Thomas Lee - tfl@psp.co.uk 
    Requires   : PowerShell Version 2.0 
.LINK 
    This script posted to: 
        http://www.pshscripts.blogspot.com 
.EXAMPLE 
    Psh> .\Show-Exceptions.ps1 -Summary 
    In 69 loaded assemblies, you have 418 exceptions: 
 
.EXAMPLE 
    Psh> .\Show-Exceptions.ps1 
    In 69 loaded assemblies, you have 418 exceptions: 
 
    Name                     FullName                                                 
    ----                     --------                                                 
    _Exception               System.Runtime.InteropServices._Exception                
    AbandonedMutexException  System.Threading.AbandonedMutexException                 
    AccessViolationException System.AccessViolationException                      
    ... 
     
#> 
 
[CMDLETBINDING()] 
Param ( 
[switch] $summary 
) 
#    Get all the exceptions 
$assemblies = [System.AppDomain]::CurrentDomain.GetAssemblies() 
$exceptions = $Assemblies | ForEach { 
     $_.GetTypes() | where { $_.FullName -Match "System$filter.*Exception$" } } 
 
# Now display the numbers checking for summary flag 
"In {0} loaded assemblies, you have {1} exceptions:" -f $assemblies.count, $exceptions.count 
If (-not $summary) { 
$Exceptions | sort name | format-table name, fullname 
}