function Get-Something
{
      param
      (
            $Path = $(
              Add-Type -AssemblyName System.Windows.Forms
              $dlg = New-Object -TypeName  System.Windows.Forms.OpenFileDialog
              if ($dlg.ShowDialog() -eq 'OK') { $dlg.FileName } else { throw 'No Path submitted'}
            )
      )
 
      "You entered $Path"
}
