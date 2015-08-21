$grid = Grid -Columns "110","*" -MinWidth 260 -Rows 6 {
    Label "VMName" -Target VMName -Row 0
        TextBox -Name VMName -Column 1 -Row 0 -Margin "5,2,5,2"

    Label "Template" -Target Template -Row 1
        ComboBox -Name Template -Items (<#Get-Template#> 1,2,3) -Column 1 -Row 1 -Margin "5,2,5,2"

    Label "Cores" -Target Cores -Row 2
        ComboBox -Name Cores -Items 1,2,4,6,8 -Column 1 -Row 2 -Margin "5,2,5,2"

    Label "CPU" -Target CPU -Row 3
        ComboBox -Name CPU -Items "2GB","4GB","8GB","16GB","32GB" -Column 1 -Row 3 -Margin "5,2,5,2"

    Label "HDD" -Target HDD -Row 4
        TextBox -Name HDD  -Column 1 -Row 4 -Margin "5,2,5,2"

    Button "OK" -IsDefault -Column 1 -Row 5 -Margin "5,2,5,2" -On_Click { Set-UIValue $window; $window.Close() }
} -show

