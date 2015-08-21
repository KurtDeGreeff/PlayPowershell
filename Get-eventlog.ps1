$getEventInput = StackPanel -ControlName 'Get-EventLogsSinceDate' {
    New-Label -VisualStyle 'MediumText' "Get Event Logs Since..."
    New-ComboBox -IsEditable:$false -SelectedIndex 0 -Name LogName @("Application", "Security", "System", "Setup")
    Select-Date -Name After          
    New-Button "Get Events" -On_Click {
        Get-ParentControl |
            Set-UIValue -passThru |
            Close-Control  
    }
} -show
            
Get-EventLog @getEventInput