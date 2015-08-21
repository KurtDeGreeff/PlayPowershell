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

# Samba Domain joining
 function JoinDomain ([string]$Domain, [string]$user, [string]$Password) {
 $domainUser= $Domain + "\" + $User
 $OU= $null
 $computersystem= gwmi Win32_Computersystem
 $computerSystem.JoinDomainOrWorkgroup($Domain,$Password,$DomainUser,$OU,3)
 }

#endregion

# Add 2 reg entries for Win7/Samba domain compatibility
$LM= 'HKLM:\SYSTEM\CurrentControlSet\services\LanmanWorkstation\Parameters'
New-ItemProperty -Path $LM  -Name DomainCompatibilityMode -PropertyType DWord -Value 1 -ErrorAction:SilentlyContinue | Out-Null
New-ItemProperty -Path $LM  -Name DNSNameResolutionRequired -PropertyType DWord -Value 0 -ErrorAction:SilentlyContinue | Out-Null
Restart-Service Workstation -force


New-Window -Title "Network Config: $PScommandpath" -HorizontalContentAlignment Center -WindowStartupLocation CenterScreen -Height 640 -Width 400 -WindowStyle ThreeDBorderWindow -ShowActivated -Show {

    New-StackPanel -Background LightBlue {
        New-Menu -ControlName SampleMenu -margin 2 {             
        New-MenuItem "File" {
        New-MenuItem "Installed Updates" -On_Click { 
        get-wmiobject Win32_QuickFixEngineering | sort -property HotFixID | select -property HotFixID, Description, Caption, InstalledOn | Out-GridView -Title "Installed Updates"}
        New-MenuItem "Installed Services" -On_Click { 
        Get-WmiObject Win32_Service | sort -property Name | select DisplayName, State, Name, Description, StartName | Out-GridView -Title "Installed Services"}
        New-MenuItem "Environment Variables" -On_Click { 
        get-wmiobject Win32_Environment | sort -property Name | select -property Name, Status, SystemVariable, UserName | Out-GridView -Title "Environment Variables"}
        New-MenuItem "Startup Commands" -On_Click { 
        get-wmiobject Win32_StartupCommand | sort -property Name | select -property Name, Command, Location | Out-GridView -Title "Startup Commands"}
        New-MenuItem "Installed Software" -On_Click { 
        Get-ChildItem HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall | % {Get-ItemProperty $_.PsPath} | where {$_.Displayname -and ($_.Displayname -match ".*")} | sort Displayname | select DisplayName, Publisher, UninstallString | Out-GridView -Title "Installed Software"}
        New-MenuItem "Active NIC's" -On_Click {
        get-wmiobject Win32_NetworkAdapterConfiguration -Filter "IPEnabled=$true" | Out-GridView -Title "Active Network Cards"}
        New-MenuItem "IPv4 Route Table" -On_Click {
        get-wmiobject Win32_IP4RouteTable | sort Destination | select Destination, Mask, NextHop, Age | Out-GridView -Title "Route Tabel"}
        New-MenuItem "Mapped Drives" -On_Click {        
        get-wmiobject Win32_MappedLogicalDisk | select Name, Description, FileSystem, @{Label="Size";Expression={"{0,12:n0} MB" -f ($_.Size/1mb)}}, @{Label="Free Space";Expression={"{0,12:n0} MB" -f ($_.FreeSpace/1mb)}}, ProviderName, VolumeName | Out-GridView -Title "Mapped Drives"}
        New-MenuItem "E_xit" -on_click {             
            $window.Close()            
        }             
    }   
        New-MenuItem "Help" {
        New-MenuItem "Credits" -On_Click { New-BalloonTip "Network Config Tool" "DTTD/Team Client"}         
        New-MenuItem "About..." -On_Click { 
        get-wmiobject Win32_ComputerSystem | select Username,DNSHostName,Domain,Manufacturer,Model,SystemType,TotalPhysicalMemory | Out-GridView -Title "System Info"}       
}
}
        $Layout = @{ FontSize = 14; Margin = 1; Maxwidth = 300}
        New-Label "Network Config Tool" -HorizontalContentAlignment Center -FontSize 18  -Foreground Green
        New-Label "Enter your IP Address:" @Layout
        New-TextBox -Name ip @Layout -Text ""
        New-Label "Enter subnet mask:" @Layout
        New-TextBox -Name mask @Layout -Text ""
        New-Label "Enter Gateway:" @Layout
        New-TextBox -Name gw @Layout -Text ""
        New-Button -VerticalAlignment Top -Margin 10 -MaxWidth 150 -HorizontalContentAlignment center -FontSize 15 -Content "Get Local IP" -On_Click { $ip.text = (Get-NetConfig).ipaddress[0]; $mask.text = (Get-NetConfig).ipsubnet[0]; $gw.text = (Get-NetConfig).DefaultIPGateway } # Out-GridView -PassThru
        $range = (Get-Content -Path "$home\Documents\Microsoft Script Explorer\ipranges.txt").Replace(";"," ") | Sort-Object 
    New-StackPanel  -Children {
        New-Label "Select your NIC:" @Layout
        # New-ComboBox -Name nics -items (gwmi win32_networkadapter -Filter "NetEnabled=$true" | select @{n="Name";e={$_.name +" - "+ $_.macaddress}} | select -ExpandProperty name) @layout
        New-ComboBox -Name nics -items ($nic_name=((gwmi win32_networkadapter -Filter "NetEnabled=$true").name)) @layout -On_SelectionChanged {$index=(gwmi win32_networkadapter | where name -eq $nic_name ).InterfaceIndex}
        New-Label "Select your PDC on the list:" @Layout
        New-ComboBox -Name iprange -Items $range @Layout -On_SelectionChanged {
        $cdp = ($iprange.SelectedValue).split("  ")
        $pdc.text = $cdp[0]
        $pdc_ip.text = $cdp[1]
        $net.text = $cdp[2]
        
        }
        New-Label "Your PDC Name:" @Layout
        New-TextBox -Name pdc @Layout -text $pdc.text
        New-Label "Your PDC IP:" @Layout
        New-TextBox -Name pdc_ip @Layout -text $pdc_ip.text
        New-Label "Your Subnet:" @Layout
        New-TextBox -Name net @Layout -text $net.text
        New-Button -VerticalAlignment Bottom -Margin 10 -MaxWidth 150 -FontSize 15 -Content "Join to Domain" -On_Click { 
        Get-ParentControl | Set-UIValue -passThru
        $dom = $pdc.text + "_DOM"
        Write-Host "index is $index `n Domain is $dom"
        $nic=gwmi Win32_NetworkAdapterConfiguration -Filter "InterfaceIndex=$Index"
        $nic.EnableStatic($ip.Text,$mask.Text)
        $nic.SetGateways($gw.Text)
        $window.Cursor = "Wait"
        [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null
        if (JoinDomain $dom admin ctislp) { [Microsoft.VisualBasic.Interaction]::Msgbox("Successfully joined domain $dom",0,"Joining Domain")}
        Close-Control }
        }
        New-Button -VerticalAlignment Bottom -HorizontalAlignment Center -Margin 10 -Background Green -MinWidth 100 -FontSize 15 -Content "Exit" -On_Click { $window.close() }


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

# Build combobox dependent on other combobox
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

#endregion 