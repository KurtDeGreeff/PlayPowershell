<#This presents the user with a popup "select file" window that defaults to their desktop folder and filters for *.ps1 files, then presents the user with a popup credentials window, and finally executes the specified script using the supplied credentials. #>
Add-Type -AssemblyName System.Windows.Forms
$OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
$OpenFileDialog.Title = "Run Powershell Script"
$OpenFileDialog.InitialDirectory = $([Environment]::GetFolderPath("Desktop"))
$OpenFileDialog.Filter = "Windows PowerShell Scripts (*.ps1)| *.ps1"
$OpenFileDialog.ShowHelp = $True
[void] $OpenFileDialog.ShowDialog()
Start-Process powershell.exe -Credential $(Get-Credential) -NoNewWindow -ArgumentList "Start-Process powershell.exe -Verb runAs $($OpenFileDialog.Filename)"

