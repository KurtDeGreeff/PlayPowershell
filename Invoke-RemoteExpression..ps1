##############################################################################
##
## Invoke-RemoteExpression
##
## From Windows PowerShell Cookbook (O'Reilly)
## by Lee Holmes (http://www.leeholmes.com/guide)
##
##############################################################################

<#

.SYNOPSIS

Invoke a PowerShell expression on a remote machine. Requires PsExec from
http://live.sysinternals.com/tools/psexec.exe. If the remote machine
supports PowerShell version two, use PowerShell remoting instead.

.EXAMPLE

Invoke-RemoteExpression \\LEE-DESK { Get-Process }
Retrieves the output of a simple command from a remote machine

.EXAMPLE

(Invoke-RemoteExpression \\LEE-DESK { Get-Date }).AddDays(1)
Invokes a command on a remote machine. Since the command returns one of
PowerShell's primitive types (a DateTime object,) you can manipulate
its output as an object afterward.

.EXAMPLE

Invoke-RemoteExpression \\LEE-DESK { Get-Process } | Sort Handles
Invokes a command on a remote machine. The command does not return one of
PowerShell's primitive types, but you can still use PowerShell's filtering
cmdlets to work with its structured output.

#>

param(
    ## The computer on which to invoke the command.
    $ComputerName = "\\$ENV:ComputerName",

    ## The scriptblock to invoke on the remote machine.
    [Parameter(Mandatory = $true)]
    [ScriptBlock] $ScriptBlock,

    ## The username / password to use in the connection
    $Credential,

    ## Determines if PowerShell should load the user's PowerShell profile
    ## when invoking the command.
    [switch] $NoProfile
)

Set-StrictMode -Version Latest

## Prepare the command line for PsExec. We use the XML output encoding so
## that PowerShell can convert the output back into structured objects.
## PowerShell expects that you pass it some input when being run by PsExec
## this way, so the 'echo .' statement satisfies that appetite.
$commandLine = "echo . | powershell -Output XML "

if($noProfile)
{
    $commandLine += "-NoProfile "
}

## Convert the command into an encoded command for PowerShell
$commandBytes = [System.Text.Encoding]::Unicode.GetBytes($scriptblock)
$encodedCommand = [Convert]::ToBase64String($commandBytes)
$commandLine += "-EncodedCommand $encodedCommand"

## Collect the output and error output
$errorOutput = [IO.Path]::GetTempFileName()

if($Credential)
{
    ## This lets users pass either a username, or full credential to our
    ## credential parameter
    $credential = Get-Credential $credential
    $networkCredential = $credential.GetNetworkCredential()
    $username = $networkCredential.Username
    $password = $networkCredential.Password

    $output = psexec $computername /user $username /password $password `
        /accepteula cmd /c $commandLine 2>$errorOutput
}
else
{
    $output = psexec /acceptEula $computername `
        cmd /c $commandLine 2>$errorOutput
}

## Check for any errors
$errorContent = Get-Content $errorOutput
Remove-Item $errorOutput
if($errorContent -match "(Access is denied)|(failure)|(Couldn't)")
{
    $OFS = "`n"
    $errorMessage = "Could not execute remote expression. "
    $errorMessage += "Ensure that your account has administrative " +
        "privileges on the target machine.`n"
    $errorMessage += ($errorContent -match "psexec.exe :")

    Write-Error $errorMessage
}

## Return the output to the user
$output