function Get-Os
{
    <#
    .SYNOPSIS 
    Turn os from pc or remote pc
    .DESCRIPTION
    .EXAMPLE
    .LINK
    #>
    param(
        [parameter(ValuefromPipeline=$true)]
        [string[]]$computername =$env:computername
        )
    
    PROCESS
    {
    foreach( $computer in $computername)
    {
    $os = Get-WmiObject Win32_operatingsystem -ComputerName $computername

    $obj = New-Object -TypeName PSObject
    $obj | Add-Member -MemberType NoteProperty -Name OS -Value $OS.caption
    $obj | Add-Member -MemberType NoteProperty -Name SP -Value $OS.csdversion
    $obj
    }
    }
}

#Save function with psm1 extension to save as module
# Name should have the same name as the folder you're storing it