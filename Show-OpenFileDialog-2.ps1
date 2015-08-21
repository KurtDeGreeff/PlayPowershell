function Show-OpenFileDialog 
{
  param 
  ($Title = 'Pick a File', $Filter = 'All|*.*|PowerShell|*.ps1')

  $type = 'Microsoft.Win32.OpenFileDialog' 

  
  $dialog = New-Object -TypeName $type 
  $dialog.Title = $Title
  $dialog.Filter = $Filter
  if ($dialog.ShowDialog() -eq $true)
  {
    $dialog.FileName
  }
  else 
  {
    Write-Warning 'Cancelled' 
  }
}