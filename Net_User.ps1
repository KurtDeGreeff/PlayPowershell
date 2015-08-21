Import-Module ShowUI            

$windowAttributes = @{
    Title = "ShowUI Form"
    WindowStartupLocation = "CenterScreen"
    SizeToContent = "WidthAndHeight"
}            

New-Window @windowAttributes -Show {            

    Grid -Columns 75*, 75 -Rows 40, 10* {
        TextBox -Name UserId -Row 0 -Column 0 -Margin 5 -Text finked            

        Button _Go -Row 0 -Column 1 -Margin 5 -On_Click {            

            foreach( $record in (net user $UserId.Text) ) {
                $result.appendText("$record `r`n")
            }
        }            

        TextBox -Name Result `
            -Row 1 -Column 0 -ColumnSpan 2 `
            -Margin 5 -IsReadOnly `
            -FontFamily "Courier New"
    }
}