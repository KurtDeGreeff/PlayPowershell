@ECHO OFF
REM -------------------------------------------------------
REM This will associate .ps1 files in Windows Explorer
REM and in CMD shells with powershell.exe; however, it
REM doesn't work when there is a space char in the path.
REM -------------------------------------------------------
@ECHO ON

assoc .ps1=Microsoft.PowerShellScript.1

ftype Microsoft.PowerShellScript.1="%%SystemRoot%%\system32\WindowsPowerShell\v1.0\powershell.exe" -nologo -noexit -command "%%1" %%* ; exit


