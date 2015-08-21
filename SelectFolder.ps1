Import-Module ShowUI
# You don't have to do load the assembly, ShowUI did it already
# Add-Type -AssemblyName System.Windows.Forms

Window -Width 200 -Height 130 {
  Grid -Rows Auto, Auto, Auto -Margin 5 { 
    Label "Please specify a folder:"
    Grid -Row 1 -Columns *, Auto -Margin 5 { 
      TextBox -Name Path -MinWidth 100
      Button " ... " -Column 1 -On_Click {

        # Here is how you use FolderBrowserDialog:
        # You don't want to make a new one each time
        if(!$this.Tag) {
          $this.Tag = new-object Windows.Forms.FolderBrowserDialog
        }
        
        # You might want to pre-select a path, here's how:
        if($Path.Text) {
          $this.Tag.SelectedPath = $Path.Text
        }

        if($this.Tag.ShowDialog() -eq "OK") { 
          # They chose a folder, stick it in our UI
          $Path.Text = $this.Tag.SelectedPath
        }

      }
    }
    Button "OK" -Row 2 -Width 80 -IsDefault -HorizontalAlignment Right -Margin 0,0,10,0 -On_Click {
        Set-UIValue $window -passThru | Close-Control
    }
  }
} -Show