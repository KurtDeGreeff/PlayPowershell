Import-Module ShowUI
New-Grid -ControlName 'SessionManager' -Rows (            
    'Auto', # Automatically sized header row            
    '1*',   # The remaining space will be where the list of sessions is displayed            
    'Auto' # Buttons will go along the bottom            
) {            
    "Active Sessions"            
    New-ListView -Row 1 -Name SessionList -View {            
        New-GridView -Columns {            
            New-GridViewColumn -Header 'Id' -DisplayMemberBinding 'Id'            
            New-GridViewColumn 'Name'            
            New-GridViewColumn 'ComputerName'            
            New-GridViewColumn 'ConfigurationName'            
            New-GridViewColumn 'State'            
        }            
    }            
                
    New-UniformGrid -Row 2 -Rows 1 {            
        New-Button "_Open" -Name OpenSession -On_Click {            
            # It's very easy to do nested dialogs.  Simply create a new control inside of            
            # an event handler, and use -Show.            
            $sessionParameters = New-UniformGrid -ControlName 'Get-RemoteSessionOption' -Columns 2 {            
                'ComputerName'            
                New-TextBox -Name 'ComputerName'            
                'ConfigurationName'                            
                New-TextBox -Name 'ConfigurationName'            
                'Authentication'            
                New-ComboBox -Name 'Authentication' -SelectedIndex 0 -ItemsSource {            
                    [Enum]::GetValues([Management.Automation.Runspaces.AuthenticationMechanism])            
                }            
                New-Button "Connect" -On_Click {            
                    $parent |            
                        Update-UIValue -passThru |            
                        Close-Control            
                }            
                New-Button "Connect As..." -On_Click {            
                    $parent | Update-UIValue            
                    $parent.Tag.Credential = Get-Credential            
                                
                    $parent | Close-Control                                                    
                }            
            } -show            
            if ($sessionParameters) {            
                New-PSSession @sessionParameters            
                $sessionList.ItemsSource = @(Get-PSSession)               
            }            
        }            
        New-Button "_Close" -On_Click {            
            $sessionList.SelectedItem | Remove-PSSession            
            $sessionList.ItemsSource = @(Get-PSSession)                
        }            
    }                        
} -On_Loaded {            
    $sessionList.ItemsSource = @(Get-PSSession)                
} -show