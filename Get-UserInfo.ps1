function Get-UserInfo {
    Grid -Rows 3 -Columns 2 -Show -On_Loaded {
        $Window.Title = "Our Help Desk"
    } {            

        Label "First Name" -Row 0 -Column 0 -FontWeight Bold
        Label "Last Name" -Row 0 -Column 1 -FontWeight Bold              

        TextBox -Row 1 -Column 0 -Margin 5 -Name FirstName
        TextBox -Row 1 -Column 1 -Margin 5 -Name LastName            

        Button "Unlock Account" -On_Click {
            $Window | Set-UIValue -passThru | Close-Control
        } -IsDefault -Margin 5 -Row 2 -Column 0 -ColumnSpan 2
    }}
Get-UserInfo