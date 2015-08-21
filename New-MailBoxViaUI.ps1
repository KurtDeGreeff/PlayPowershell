# Requires ShowUI 1.3
function New-MailBoxViaUI {
   $MailboxInfo = UniformGrid -ControlName "GetMailboxInfo" -Columns 2 {
      Label "First Name:"
      TextBox -Name FirstName

      Label "Last Name:"
      TextBox -Name "LastName"

      Label "Mailbox Name:"
      TextBox -Name "Name"
      
      Button -Content "Cancel" -IsCancel -On_Click {
          Get-ParentControl | 
              Close-Control
      }    
      Button "Ok" -IsDefault -On_Click {
          Get-ParentControl | 
              Set-UIValue -passThru | 
              Close-Control
      }
   } -On_Load { 
      $this.Children[1].Focus() 
   } -On_PreviewMouseLeftButtonDown { 
      if($_.Source -notmatch ".*\.(TextBox|Button)") { $ShowUI.ActiveWindow.DragMove() }
   } -Show 

   New-Mailbox @MailboxInfo
}
New-MailBoxViaUI