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

    param(
    $computername = 'Localhost'
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