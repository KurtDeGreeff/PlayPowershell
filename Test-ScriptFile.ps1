#requires -version 3.0
 
Function Test-ScriptFile {
<#
.Synopsis
Test a PowerShell script for cmdlets
.Description
This command will analyze a PowerShell script file and display a list of detected commands such as PowerShell cmdlets and functions. Commands will be compared to what is installed locally. It is recommended you run this on a Windows 8.1 client with the latest version of RSAT installed. Unknown commands could also be internally defined functions. If in doubt view the contents of the script file in the PowerShell ISE or a script editor.
 
You can test any .ps1, .psm1 or .txt file.
.Parameter Path
The path to the PowerShell script file. You can test any .ps1, .psm1 or .txt file.
.Parameter UnknownOnly
Only display commands that could not be resolved based on locally installed modules.
.Example
PS C:\> test-scriptfile C:\scripts\Remove-MyVM2.ps1
 
CommandType Name                                   ModuleName
----------- ----                                   ----------
    Cmdlet Disable-VMEventing                      Hyper-V
    Cmdlet ForEach-Object                          Microsoft.PowerShell.Core
    Cmdlet Get-VHD                                 Hyper-V
    Cmdlet Get-VMSnapshot                          Hyper-V
    Cmdlet Invoke-Command                          Microsoft.PowerShell.Core
    Cmdlet New-PSSession                           Microsoft.PowerShell.Core
    Cmdlet Out-Null                                Microsoft.PowerShell.Core
    Cmdlet Out-String                              Microsoft.PowerShell.Utility
    Cmdlet Remove-Item                             Microsoft.PowerShell.Management
    Cmdlet Remove-PSSession                        Microsoft.PowerShell.Core
    Cmdlet Remove-VM                               Hyper-V
    Cmdlet Remove-VMSnapshot                       Hyper-V
    Cmdlet Write-Debug                             Microsoft.PowerShell.Utility
    Cmdlet Write-Verbose                           Microsoft.PowerShell.Utility
    Cmdlet Write-Warning                           Microsoft.PowerShell.Utility
 
 
.Example
PS C:\> get-dscresource xJeaToolkit | Test-ScriptFile | Sort CommandType | format-table
 
CommandType Name                 ModuleName
----------- ----                 ----------
     Cmdlet Join-Path            Microsoft.PowerShell.Management
     Cmdlet Import-Module        Microsoft.PowerShell.Core
     Cmdlet Write-Verbose        Microsoft.PowerShell.Utility
     Cmdlet Out-String           Microsoft.PowerShell.Utility
     Cmdlet Write-Debug          Microsoft.PowerShell.Utility
     Cmdlet Test-Path            Microsoft.PowerShell.Management
     Cmdlet Remove-Module        Microsoft.PowerShell.Core
     Cmdlet Get-Module           Microsoft.PowerShell.Core
     Cmdlet Export-ModuleMember  Microsoft.PowerShell.Core
     Cmdlet Get-Content          Microsoft.PowerShell.Management
     Cmdlet Format-List          Microsoft.PowerShell.Utility
    Unknown Assert-JeaDirectory  Unknown
    Unknown Export-JEAProxy      Unknown
    Unknown Get-JeaDir           Unknown
    Unknown New-TerminatingError Unknown
    Unknown Get-JeaToolKitDir    Unknown
.Example
PS C:\> get-dscresource cvhdfile | test-scriptfile -UnknownOnly
 
CommandType                             Name                                    ModuleName
-----------                             ----                                    ----------
Unknown                                 EnsureVHDState                          Unknown
Unknown                                 GetItemToCopy                           Unknown
Unknown                                 SetVHDFile                              Unknown
.Notes
Last Updated: November 2, 2014
Version     : 1.0
 
Learn more about PowerShell:
http://jdhitsolutions.com/blog/essential-powershell-resources/
 
  ****************************************************************
  * DO NOT USE IN A PRODUCTION ENVIRONMENT UNTIL YOU HAVE TESTED *
  * THOROUGHLY IN A LAB ENVIRONMENT. USE AT YOUR OWN RISK.  IF   *
  * YOU DO NOT UNDERSTAND WHAT THIS SCRIPT DOES OR HOW IT WORKS, *
  * DO NOT USE IT OUTSIDE OF A SECURE, TEST SETTING.             *
  ****************************************************************
 
.Link
Get-Command
Get-Alias
 
#>
 
[cmdletbinding()]
Param(
[Parameter(Position = 0,Mandatory = $True,HelpMessage = "Enter the path to a PowerShell script file,",
ValueFromPipeline = $True,ValueFromPipelineByPropertyName = $True)]
[ValidatePattern( "\.(ps1|psm1|txt)$")]
[ValidateScript({Test-Path $_ })]
[string]$Path,
[switch]$UnknownOnly
)
 
Begin {
    Write-Verbose "Starting $($MyInvocation.Mycommand)"  
    Write-Verbose "Defining AST variables"
    New-Variable astTokens -force
    New-Variable astErr -force
} #begin
 
Process {
    Write-Verbose "Parsing $path"
 
    $AST = [System.Management.Automation.Language.Parser]::ParseFile($Path,[ref]$astTokens,[ref]$astErr)
 
    #group tokens and turn into a hashtable
    $h = $astTokens | Group-Object tokenflags -AsHashTable -AsString
 
    $commandData = $h.CommandName | where {$_.text -notmatch "-TargetResource$"} |
    foreach {
     Write-Verbose "Processing $($_.text)"
     Try {
        $cmd = $_.Text
        $resolved = $cmd | get-command -ErrorAction Stop
         if ($resolved.CommandType -eq 'Alias') {
            Write-Verbose "Resolving an alias"
            #manually handle "?" because Get-Command and Get-Alias won't.
            Write-Verbose "Detected the Where-Object alias '?'"
            if ($cmd -eq '?'){
              Get-Command Where-Object
            }
            else {
                $resolved.ResolvedCommandName | Get-Command
           }
         }
         else {
            $resolved
         }
     } #Try
     Catch {
        Write-Verbose "Command is not recognized"
        #create a custom object for unknown commands
        [PSCustomobject]@{
         CommandType = "Unknown"
         Name = $cmd
         ModuleName = "Unknown"
      } #custom object
     } #catch
    } #foreach
    
    if ($UnknownOnly) {
        Write-Verbose "Filtering for unknown commands only"
        $commandData = $commandData | where {$_.Commandtype -eq 'Unknown'}
    }
    else {
        Write-Verbose "Displaying all commands"    
    }
    #display results
    $commandData | Sort-Object -property Name | Select-Object -property CommandType,Name,ModuleName -Unique
} #process
 
End {
    Write-Verbose -Message "Ending $($MyInvocation.Mycommand)"
} #end
 
} #end function
