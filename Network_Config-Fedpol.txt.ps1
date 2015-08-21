IPMO ShowUI

#region Functions
# Get Latest Powershell Tip every day from powershell.org
Function Get-PSTip {
   param (
      [switch]$Multiple
   )
 
   $url = Invoke-RestMethod -Uri "http://bit.ly/QwjgRd"
 
   if ($Multiple) {
      $selectedTips = $url | Select-Object Title, Link | Out-GridView -PassThru
      if ($selectedTips) {
         $selectedTips | Foreach-Object {
            Start-Process $_.Link
         }
      }
   } else {
      Start-Process $url[0].Link
   }
}

Function Get-NetConfig {
Param(
    $ComputerName = $env:COMPUTERNAME,
    $Credential
)
 
Begin {
    $WMIParam = @{
        ComputerName = $ComputerName
        Class = 'Win32_NetworkAdapterConfiguration'
        Namespace = 'Root\CIMV2'
        Filter = "IPEnabled=$true"
        ErrorAction = 'Stop'
    }
    If ($PSBoundParameters['Credential']) {
        $WMIParam.Credential = $Credential
    }
}
 
Process {
    Try {
        Get-WmiObject @WMIParam
    } Catch {
        Write-Warning ("{0}: {1}" -f $ComputerName,$_.Exception.Message)
    }
}
}
# Get-NetConfig | Out-GridView

Function Test-IsValidIP {
 
    [CmdletBinding()]
 
    Param (
        [parameter(ValueFromPipeLine=$True,ValueFromPipeLineByPropertyName=$True)]
        [Alias("IP")]
        [string]$IPAddress
    )
 
    Process {
        Try {
            [ipaddress]$IPAddress | Out-Null
            Write-Output $True
        } Catch {
            Write-Output $False
        }
    }
}

function New-BalloonTip {
[CmdletBinding()]
Param(
$TipText='This is the body text.',
$TipTitle='This is the title.',
$TipDuration='10000'
)
[system.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') | Out-Null
$balloon = New-Object System.Windows.Forms.NotifyIcon
$path = Get-Process -id $pid | Select-Object -ExpandProperty Path
$icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
$balloon.Icon = $icon
$balloon.BalloonTipIcon = 'Info' #replace info with error or warning for other icon
$balloon.BalloonTipText = $TipText
$balloon.BalloonTipTitle = $TipTitle
$balloon.Visible = $true
$balloon.ShowBalloonTip($TipDuration)
}

#endregion

New-Window -Title "Network Config" -WindowStartupLocation CenterScreen -Height 700 -Width 450 -WindowStyle ThreeDBorderWindow -ShowActivated -Show {

    New-StackPanel -Background LightBlue {
        New-Menu -ControlName SampleMenu -margin 2 {             
        New-MenuItem "File" {
        New-MenuItem "Balloon" -On_Click { New-BalloonTip "Happy New Year" "Greetings"}         
        New-MenuItem "E_xit" -on_click {             
            $window.Close()            
        }             
    }            
}
        New-Label "Network Config Tool" -FontSize 18 -Margin 5 -Foreground Green
        New-Label "Enter your IP Address:" -FontSize 15 -Margin 5 -MaxWidth 300
        ($ip = New-TextBox -Name ip -FontSize 15 -MaxWidth 300 -Text "" )
        New-Label "Enter subnet mask:" -FontSize 15 -Margin 5 -MaxWidth 300
        ($mask = New-TextBox -Name mask -FontSize 15 -MaxWidth 300 -Text "" )
        New-Label "Enter Gateway:" -FontSize 15 -Margin 5 -MaxWidth 300
        ($gw = New-TextBox -Name gw -FontSize 15 -MaxWidth 300 -Text "" )
        New-Button -VerticalAlignment Top -Margin 15 -MaxWidth 200 -HorizontalContentAlignment center -FontSize 15 -Content "Get Local IP" -On_Click { $ip.text = (Get-NetConfig).ipaddress[0]; $mask.text = (Get-NetConfig).ipsubnet[0]; $gw.text = (Get-NetConfig).DefaultIPGateway } # Out-GridView -PassThru
        New-Button -VerticalAlignment Bottom -Margin 15 -Background Green -MaxWidth 100 -FontSize 15 -Content "Exit" -On_Click { $window.close() }
        $range = (Get-Content -Path "$home\Documents\Microsoft Script Explorer\ipranges.txt").Replace(";"," ") | Sort-Object
        
        # Split then Join to get Network id - based on /24 mask 
        $j=$ip.split(".")
        $join= $j[0],$j[1],$j[2] -join "."

        # Search iprange.txt for match, assign samba ip/name vars
        $s=Get-Content c:\temp\samba.txt | Select-String -Pattern $join\s
        $s=$s.tostring()
        $s=$s.split(" ")
        $net=$s[0]
        $pdc_ip=$s[1]
        $pdc_name=$s[2]      
        
        New-StackPanel -Name PdcStack -Background Gray -Children {
                New-Label "Select your PDC on the list"
                New-ComboBox -Name iprange -Items $range  -Margin 15 -On_SelectionChanged {
                $cdp = ($iprange.SelectedValue).split("  ")
                $pdc.text = $cdp[0]
                $pdc_ip.text = $cdp[1]
                $net.text = $cdp[2]
                }
                New-Label "Your PDC Name"
                New-TextBox -Name pdc -FontSize 15 -MaxWidth 400 -text $pdc.text -Margin 5
                New-Label "Your PDC IP"
                New-TextBox -Name pdc_ip -FontSize 15 -MaxWidth 400 -text $pdc_ip.text -Margin 5
                New-Label "Your Subnet"
                New-TextBox -Name net -FontSize 15 -MaxWidth 400 -text $net.text -Margin 5
                New-Button -IsDefault -VerticalAlignment Bottom -Margin 15 -MaxWidth 150 -FontSize 15 -Content "Join to Domain" -On_Click { 
                Get-ParentControl | Set-UIValue -passThru
                Write-host "Ip address = " $ip.text
                Write-host "Subnet Mask = " $mask.text
                $index=(Get-NetConfig | Out-GridView -Title "SELECT YOUR NETWORK CARD" -PassThru).InterfaceIndex
                (gwmi Win32_NetworkAdapterConfiguration -Filter "ipenabled=$true" | Where-Object { $_.InterfaceIndex -eq $index}).EnableStatic($ip.Text,$mask.Text)
                Close-Control
                }
                }

<#
$servers = "localhost"
 
New-Grid -rows 3 {
	# Don't specify the SelectedIndex, that way the user has to select something AFTER the app starts up
	New-ComboBox -Width 200 -row 1 -column 1 -IsTextSearchEnabled:$true -Name serverName -items $servers -On_SelectionChanged {
		$DBName.itemsSource = ((Get-process).Name)
	# If you want to start up with default values ... select them after everything is loaded:
	}
    New-ComboBox -Name DBName -Width 200 -Row 3 -Column 1 -Items $DBName.itemsSource
} -Show
#>



# Stackpanel where content of one list changes the content of the other list. Secret here is that they share the same dataContext 
<#    StackPanel -Orientation Horizontal -Margin 15 -MaxHeight 250 -DataContext { 
            Get-ChildItem | Sort-Object Extension | Group-Object Extension 
            } -Children {
            Listbox -Width 75 -MinHeight 100 -DataBinding @{ ItemsSource = New-Binding -Path "." } -DisplayMemberPath Name -IsSynchronizedWithCurrentItem:$true
            Listbox -MinWidth 350 -DataBinding @{ ItemsSource = New-Binding -Path "CurrentItem.Group" }
        } #>
    }
}




#region  TEST EXAMPLES of http://showui.codeplex.com/discussions
<#
# Get-Eventlogs Gui
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
#>

<#
#Binding a GroupBox's IsEnabled to a CheckBox's IsChecked
New-Window -SizeToContent WidthAndHeight {
    New-Grid -Columns 1 -Rows 2 {
        New-CheckBox -Name Check1 'Enable Group 1'
        New-GroupBox -Name Group1 -Row 1 'Group 1' {
            New-TextBox 'Item 1'
        } -IsEnabled:$false
        #(New-Binding -Path IsChecked -ElementName Check1)
    }
} -On_Loaded {
   Set-Property -InputObject $Group1 @{IsEnabled = {New-Binding -Source $Check1 -Path IsChecked}}
} -Show
#>

<#      Sortable column headings
$Items = Get-Process
$tableHeaders = @{ HandleCount = "Handles"; NonpagedSystemMemorySize = "NPM";
                   PagedMemorySize = "PM"; WorkingSet ="WS"; VirtualMemorySize = "VM";
                   TotalProcessorTime ="CPU Time"; Id = "Id"; ProcessName = "Process Name" }

ScrollViewer -Margin 5 -Row 1 {
    ListView -SelectionMode Extended -ItemsSource $Items -Name SelectedItems `
            -FontFamily "Consolas, Courier New" -View {
                GridView -Columns {
                    ## tableHeaders is a hashtable with keys that are property names and values that are labels
                    foreach($h in $tableHeaders.GetEnumerator()) {
                        GridViewColumn -Header $h.Value -DisplayMember { Binding $h.Key }
                    }
                }
            } -On_SelectionChanged {
                if($selectedItems.SelectedItems.Count -gt 0)
                {
                    $SelectFTList | Set-UIValue -value ( $selectedItems.SelectedItems | ForEach-Object { $_.OriginalItem } )
                } else {
                    $SelectFTList | Set-UIValue -value ( $selectedItems.Items | ForEach-Object { $_.OriginalItem } )
                }
            } -On_Loaded {
                ## Default output, in case you close the window without selecting anything
                $SelectFTList | Set-UIValue -value ( $selectedItems.Items | ForEach-Object { $_.OriginalItem } )
            }
            # -On_MouseDoubleClick { Close-Control $parent }
} -On_Load {

    Add-EventHandler -Input $SelectedItems -SourceType GridViewColumnHeader -EventName Click { 
        if($_.OriginalSource -and $_.OriginalSource.Role -ne "Padding") {
            ## We need to sort by a PROPERTY of the objects in the gridview, in our example, we can just use the path that we used for binding ...
            $Sort = $_.OriginalSource.Column.DisplayMemberBinding.Path.Path
            $direction = if($Sort -eq $lastSort) { "Descending" } else { "Ascending" }
            $lastSort = $Sort
            $view = [System.Windows.Data.CollectionViewSource]::GetDefaultView( $SelectedItems.ItemsSource )
            $view.SortDescriptions.Clear()
            $view.SortDescriptions.Add(( New-Object System.ComponentModel.SortDescription $Sort, $direction ))
            $view.Refresh()
        }
    }
} -Show
#>

<# Auto-refresh ListView ItemsSource for services? not possible
#Import-Module ShowUI
# http://showui.codeplex.com/discussions/270871
New-Grid -Name ServiceManager -Rows Auto,1*,Auto {
    New-StackPanel -Orientation Horizontal {
        New-Label "Computer Name"
        New-TextBox -Name computerName -Width 100 -Text "localhost" -Margin 5
        New-Button "Connect" -Width 100 -On_Click {
            $serviceList.ItemsSource = @(Get-Service -ComputerName $computerName.Text)
        }
    }    
    New-ListView -Row 1 -Name ServiceList -MaxHeight 500 -View {
        New-GridView -Columns {
            New-GridViewColumn -Header Name -DisplayMemberBinding Name
            New-GridViewColumn Status
            New-GridViewColumn DisplayName
        }
    } -On_SelectionChanged  {
        $Toggle.IsEnabled = $true
    }
    New-StackPanel -Row 2 -Orientation Horizontal -HorizontalAlignment Center {
        New-Button -Name Toggle "Toggle State" -Width 100 -IsEnabled:$false -On_Click {
            Foreach ($item in $ServiceList.SelectedItems) {
                if ($item.Status -eq 'Running') {
                    (Get-WmiObject -computer $computerName.Text -Class Win32_Service -Filter "Name='$($item.Name)'").StopService()
                } else {
                    (Get-WmiObject -computer $computerName.Text -Class Win32_Service -Filter "Name='$($item.Name)'").StartService()
                }
            }
            $serviceList.ItemsSource = @(Get-Service -ComputerName $computerName.Text)
        }
        New-Button "Close" -IsCancel -Width 100
    }           
} -On_Load {
        $serviceList.ItemsSource = @(Get-Service -ComputerName $computerName.Text)
        $computerName.Focus()
} -show
#>

# New-label "Test" -Show -On_Loaded { New-Combobox |  Get-Member | Out-GridView }

<#
UniformGrid -Columns 1 -Show {    
    Label -Margin 5 -Name lbl        

    Button _Go -Margin 5 -On_Click {
         $lbl.Content = "warming up server..."        

         Get-PowerShellDataSource -On_OutputChanged {
             $lbl.Content = "done"
          } -Script {sleep 2; get-date}
    }
}
#>

# Add waiting cursor to window
# $window.Cursor = "Wait"

# Bind a listbox item to the keys of a hash
<#
$commandList = @{
  CommandStrings = @{
    MinSessionTimestampInRange = "select 1"
    MaxSessionTimestampInRange = "Select 2"
    CountOfSessionsInRange = "select 3"
    AllSessionsInRange = "select * "
  }
}

ListBox -ControlName Selector -ItemsSource $commandList.CommandStrings -ItemTemplate {
   StackPanel -HorizontalAlignment "Left" -VerticalAlignment "Top" -Orientation "Horizontal" -Name "c_sp_1" {
      Label -HorizontalAlignment "Left" -VerticalAlignment "Center" -Name "c_lbl_coName"
   } | ConvertTo-DataTemplate -Binding @{
      "c_lbl_coName.Content" = "Key"
   }   
} -On_SelectionChanged { 
   Set-UIValue $this $this.SelectedItem.Value
} -show
#>

#Function show Environment
<#
function Show-Environment ($window, $servers)
{
    $e = Get-ChildControl -ByName "Environment"
    $servers.DataContext = Load-Environment $e.SelectedItem
}

$my_input = New-Window -Title "Deployment Runner" -WindowStartupLocation CenterScreen -SizeToContent WidthAndHeight -Show -On_Loaded {
    $environment.DataContext = $environments.Keys
} {
    $labelStyle = @{
        Margin = 5
        HorizontalAlignment = "Right"
    }

    Grid -Columns 1 -Rows Auto, Auto, 55 {
        Grid -Name TestX -Row 0 -Columns 100, 100 -Rows 35, 35, 35 {
        
            Label   -Content "Environment" -Row 0 -Column 0 @labelStyle
            New-ComboBox -Name "Environment" -Row 0 -Column 1 -Margin 5 -HorizontalAlignment "Right" -DataBinding @{ ItemsSource = New-Binding } -On_SelectionChanged {
                Show-Environment $window localhost
            } -SelectedIndex 0
                       
           # TextBox -Name Environment -Text Staging -Row 0 -Column 1 -Margin 5

            Label   -Content "Deploy Web" -Row 1 -Column 0 @labelStyle
            CheckBox -Name do_apps -IsChecked $true -Row 1 -Column 1 @labelstyle

            Label   -Content "Deploy DB"  -Row 2 -Column 0 @labelStyle
            CheckBox -Name do_dbs -IsChecked $true -Row 2 -Column 1 @labelstyle

        }

        ListView -Name Servers -Row 1 -Margin 5 -Column 0 -DataBinding @{ ItemsSource = New-Binding } -View {
            New-GridView -Columns {
				New-GridViewColumn Name
				New-GridViewColumn Role
			}
        }

        Button -Row 2 -Margin 15 _Run -IsDefault -On_Click {
        $window.Cursor = "Wait"; start-sleep 3
        Get-ParentControl | Set-UIValue -passThru | Close-Control
        }
    }
}
#>

#Build combobox dependent on other combobox
<#
StackPanel -Orientation Horizontal -DataContext { 
   Get-ChildItem | Sort-Object Extension | Group-Object Extension 
} -Children {
   ListBox -Width 75 -MinHeight 300 -DataBinding @{ ItemsSource = New-Binding -Path "." } -DisplayMemberPath Name -IsSynchronizedWithCurrentItem:$true
   ListBox -MinWidth 350 -DataBinding @{ ItemsSource = New-Binding -Path "CurrentItem.Group" }
} -Show
#>

#endregion 