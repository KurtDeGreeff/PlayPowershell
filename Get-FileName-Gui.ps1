Function Get-FileName($initialDirectory)
{
    [System.Reflection.Assembly]::LoadWithPartialName('System.windows.forms') | Out-Null
    
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.filter = 'CSV (*.csv)| *.csv'
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.filename
}
$inputfile = Get-FileName 'C:\temp'
$inputdata = get-content $inputfile