Add-Type -AssemblyName Microsoft.PowerShell.GraphicalHost
$text = Get-Content $env:windir\system32\winrm\*\winrm.ini -ReadCount 0 | Out-String
$HelpWindow = New-Object Microsoft.Management.UI.HelpWindow $text -Property @{
    Title="My Text Viewer"
    Background='#011f51'
    Foreground='#FFFFFFFF'
}
$HelpWindow.ShowDialog()
