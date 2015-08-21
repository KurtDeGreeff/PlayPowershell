Import-Module Showui
New-Window -SizeToContent WidthAndHeight -DataContext {
    New-Object psobject -Property @{
        name ="Jon"
        age = 10
    }

} -Show {
    UniformGrid -Columns 1 {
        TextBox -IsReadOnly -Margin 5 -DataBinding @{Text= New-Binding -Path name}
        TextBox -IsReadOnly -Margin 5 -DataBinding @{Text= New-Binding -Path age}
    }
}