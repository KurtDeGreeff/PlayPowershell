$ErrorLog = "c:\log.txt"
# Powershell Toolmaking CBT Nugget with Don Jones
function Get-SystemInfo {
    <#
    .SYNOPSIS
    Queries computer information from a single machine.
    .DESCRIPTION
    Queries OS and Hardware information. This utilizes WMI, so the 
    WMI ports must be open on the remote machine.
    .PARAMETER Computername
    The name or IP of the computer
    .EXAMPLE
    .\Get-systemInfo -Computername <computername>
    #>
   [cmdletbinding()] #help about_advanced function
    param(
        [parameter(Mandatory=$true, HelpMessage="Computer to query")]
        [Alias('Hostname')]
        [ValidateLength(4,10)]
        [string[]]$computername,
    
        [parameter()]
        [string]$errorFileLogPath=$ErrorLog

    )
    $os = Get-WmiObject -Class win32_operatingsystem -ComputerName $computername
    $cs = Get-WmiObject -Class win32_computersystem -ComputerName $computername
    $props = @{'computername' = $computername;
               'OSVersion' = $os.version;
               'OSBuild' = $os.buildnumber;
               'SPVersion' = $os.servicepackmajorversion;
               'Model'= $cs.model;
               'Manufacturer'= $cs.manufacturer;
               'RAM'= $cs.totalphysicalmemory / 1GB -as [int];
               'Sockets'= $cs.numberofprocessors;
               'Cores'= $cs.numberoflogicalprocessors;
    }
    $obj = New-Object -TypeName psobject -Property $props
    Write-Output $obj
}



<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
   General notes
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>
function Verb-Noun
{
    [CmdletBinding(DefaultParameterSetName='Parameter Set 1', 
                  SupportsShouldProcess=$true, 
                  PositionalBinding=$false,
                  HelpUri = 'http://www.microsoft.com/',
                  ConfirmImpact='Medium')]
    [OutputType([String])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0,
                   ParameterSetName='Parameter Set 1')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidateCount(0,5)]
        [ValidateSet("sun", "moon", "earth")]
        [Alias("p1")] 
        $Param1,

        # Param2 help description
        [Parameter(ParameterSetName='Parameter Set 1')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [ValidateScript({$true})]
        [ValidateRange(0,5)]
        [int]
        $Param2,

        # Param3 help description
        [Parameter(ParameterSetName='Another Parameter Set')]
        [ValidatePattern("[a-z]*")]
        [ValidateLength(0,15)]
        [String]
        $Param3
    )

    Begin
    {
    }
    Process
    {
        if ($pscmdlet.ShouldProcess("Target", "Operation"))
        {
        }
    }
    End
    {
    }
}

