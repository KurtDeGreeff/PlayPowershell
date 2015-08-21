function Show-OpenFileDialog
{
  param
  (
    $StartFolder = [Environment]::GetFolderPath('MyDocuments'),

    $Title = 'Open what?',
    
    $Filter = 'All|*.*|Scripts|*.ps1|Texts|*.txt|Logs|*.log'
  )
  
  
  Add-Type -AssemblyName PresentationFramework
  
  $dialog = New-Object -TypeName Microsoft.Win32.OpenFileDialog
  
  
  $dialog.Title = $Title
  $dialog.InitialDirectory = $StartFolder
  $dialog.Filter = $Filter
  
  
  $resultat = $dialog.ShowDialog()
  if ($resultat -eq $true)
  {
    $dialog.FileName
  }
}