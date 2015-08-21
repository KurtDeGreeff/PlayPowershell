function Get-Assembly
{
<#
.SYNOPSIS
    Get .net assemblies loaded in your session
.DESCRIPTION
    List assemblies loaded in the current session. Wildcards are supported. 
    Requires powershell version 2
.PARAMETER Name
    Name of the assembly to look for. Supports wildcards
.EXAMPLE
    Get-Assembly

    Returns all assemblies loaded in the current session
.EXAMPLE
    Get-Assembly -Name *ServiceBus*

    Returns loaded assemblies which contains ServiceBus
  
.NOTES 
     SMART
     AUTHOR: Tore Groneng tore@firstpoint.no @toregroneng tore.groneng@gmail.com
#>
[cmdletbinding()]
Param(
    [String] $Name
)
    $f = $MyInvocation.MyCommand.Name 
    Write-Verbose -Message "$f - Start"

    if($name)
    {
        $dlls = [System.AppDomain]::CurrentDomain.GetAssemblies() | where {$_.FullName -like "$name"}
    }
    else
    {
        $dlls = [System.AppDomain]::CurrentDomain.GetAssemblies()
    }

    if($dlls)
    {
        foreach ($dll in $dlls)
        {
            $Assembly = "" | Select-Object FullName, Version, Culture, PublicKeyToken
            $DllArray = $dll -split ","
            if($DllArray.Count -eq 4)
            {
                Write-Verbose -Message "$f -  Building custom object"
                $Assembly.Fullname = $DllArray[0]
                $Assembly.Version = $DllArray[1].Replace("Version=","")
                $Assembly.Culture = $DllArray[2].Replace("Culture=","")
                $Assembly.PublicKeyToken = $DllArray[3].Replace("PublicKeyToken=","")
                $Assembly
            }
            else
            {
                Write-Verbose -Message "$f-  Array length/count is NOT 4"
            }
        }
    }
    else
    {
        Write-Verbose -Message "$f -  nothing found"
    }
    Write-Verbose -Message "$f - End"
}