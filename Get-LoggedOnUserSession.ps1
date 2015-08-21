#requires -Version 1 

<#list the current logon sessions, reporting all users who are currently logged on to a system.
This includes users that are connected via RDP and other means.
When you run Get-LoggedOnUserSession, you get back all users that are currently connected to your machine. 
Specify the -ComputerName and optionally the -Credential (domain\username) parameters to access remote machines.#>

function Get-LoggedOnUserSession
{
    param
    (
        $ComputerName,
        $Credential
    )
 
    Get-WmiObject -Class Win32_LogonSession @PSBoundParameters |
    ForEach-Object {
        $_.GetRelated('Win32_UserAccount') |
        Select-Object -ExpandProperty Caption
    } |
    Sort-Object -Unique
}