ipmo showui
DockPanel -ControlName Editor {
  Menu -Dock Top -Height 20 {
     MenuItem -Header "_File" {
        ## Hook up the "New" menuitem to the New command ...
        MenuItem -Command 'New'
        MenuItem -Command 'Save'
        Separator
        ## There's still no "Exit" command (since Alt+F4 is handled by the OS)
        MenuItem -Header "E_xit" -On_Click { Close-Control $Editor }
     }
  }

  TextBox -Name "Content" -FontFamily "Consolas, Global Monospace" `
          -MinLines 10 -MinWidth 250 -AcceptsReturn -AcceptsTab
} -CommandBindings {
  # The "New" command (using this binds CTRL+N)
  CommandBinding -Command New -On_Executed   { $Content.Text = "" }
  # The "Save" command (using this binds CTRL+S)
  CommandBinding -Command Save `
                 -On_CanExecute { $_.CanExecute = $Content.Text.Length } `
                 -On_Executed   { Set-UIValue $Editor $Content.Text }
} -Show