Import-Module ShowUI
New-StackPanel -Orientation Vertical {
    New-DataGrid -Name ServerManager -Columns {
        New-DataGridCheckBoxColumn -Header "IsSelected" -Binding {New-Binding -Path "selected"}
        New-DataGridTextColumn -Header "ServerName" -Binding {New-Binding -Path "sname"}
        New-DataGridComboBoxColumn -Header "Action" -SelectedValueBinding { New-Binding -Path "saction" } -ItemsSource @("Start","Stop","Sleep") 
    } -ItemsSource { 
        New-Object System.Collections.ObjectModel.ObservableCollection[PSObject]
    } # -CanUserAddRows:$False ## Uncomment CanUserAddRows to hide the "add" row from the DataGrid
    Grid -Columns *,Auto {
        New-TextBox -Name ServerName
        New-Button "Add" -Name btnConnect -Column 2 -On_Click {
            <# Take Action Here to Test-Connection and Set Relevant Action ... #>
            $item= New-Object PSObject -Prop @{"selected"=$true;"sname"=$ServerName.Text;"saction"="Stop"}
            ## Add the item to the list
            $ServerManager.ItemsSource.Add( $item )
            $ServerName.Clear()
        } -IsDefault ## IsDefault makes it so "Enter" clicks this button...
    }
} -Show