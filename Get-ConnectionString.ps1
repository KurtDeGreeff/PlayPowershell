#requires -Version 2 
<#When you run Get-ConnectionString, PowerShell opens a dialog, 
and you can submit and test the connection details. 
Once you close the dialog window, PowerShell returns 
the connection string you just created with the help of the UI dialog.#>
function Get-ConnectionString
{ 
    $Path = Join-Path -Path $env:TEMP -ChildPath 'dummy.udl'
  
    $null = New-Item -Path $Path -ItemType File -Force
  
    $CommandArg = """$env:CommonProgramFiles\System\OLE DB\oledb32.dll"",OpenDSLFile "  + $Path
 
    Start-Process -FilePath Rundll32.exe -ArgumentList $CommandArg -Wait
    $ConnectionString = Get-Content -Path $Path | Select-Object -Last 1
    $ConnectionString | clip.exe
    Write-Warning -Message 'Connection String is also available from clipboard'
    $ConnectionString
}