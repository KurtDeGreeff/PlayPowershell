#Requires -Modules ShowUI
IPMO ShowUI

#region Functions

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

# Helper function for setting MTU value
 function SetProperty([string]$path, [string]$key, [string]$Value) {
$oldValue = (Get-ItemProperty -path $path).$key
Set-ItemProperty -path $path -name $key -Type DWORD -Value $Value
$newValue = (Get-ItemProperty -path $path).$key
$data =  "$path\$key=$oldValue" 
Write-Output "Value for $path\$key changed from $oldValue to $newValue"
}

#endregion

[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null

If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::`
    GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")){
		Write-Warning "You need Administrator rights to run this!"
        [Microsoft.VisualBasic.Interaction]::Msgbox("You need Administrator rights to run this!",0,"Admin rights needed")
		Break
	}


# Add 2 reg entries for Win7/Samba domain compatibility
$LM= 'HKLM:\SYSTEM\CurrentControlSet\services\LanmanWorkstation\Parameters'

New-ItemProperty -Path $LM  -Name DomainCompatibilityMode -PropertyType DWord `
-Value 1 -ErrorAction:SilentlyContinue | Out-Null

New-ItemProperty -Path $LM  -Name DNSNameResolutionRequired -PropertyType DWord `
-Value 0 -ErrorAction:SilentlyContinue | Out-Null
Restart-Service Workstation -force | Out-Null


<#Get NetworkAdapter Configuration via WMI with parameter hashtable
$WMIParam = @{
        Class = 'Win32_NetworkAdapterConfiguration'
        Namespace = 'Root\CIMV2'
        ErrorAction = 'Stop'
        Filter = "InterFaceIndex=11"
}
$NetAdapter = Get-WmiObject @WMIParam
#>

#region Main Section, New window with 2 Stackpanels
$window = New-Window -Title "Network Config: $PScommandpath" -HorizontalContentAlignment Center `
-WindowStartupLocation CenterScreen -Height 630 -Width 350 -WindowStyle ThreeDBorderWindow `
-ShowActivated -Show {
    
    New-StackPanel -Background LightBlue {
      
      New-Menu -ControlName SampleMenu -margin 2 {             
        
        New-MenuItem "File" {
        
        New-MenuItem "Installed Updates" -On_Click { 
            get-wmiobject Win32_QuickFixEngineering | sort -property HotFixID | 
            select -property HotFixID, Description, Caption, InstalledOn | Out-GridView -Title "Installed Updates"}
        
        New-MenuItem "Installed Services" -On_Click { 
            Get-WmiObject Win32_Service | sort -property Name | 
            select DisplayName, State, Name, Description, StartName | Out-GridView -Title "Installed Services"}
        
        New-MenuItem "Environment Variables" -On_Click { 
            get-wmiobject Win32_Environment | sort -property Name | 
            select -property Name, Status, SystemVariable, UserName | Out-GridView -Title "Environment Variables"}
        
        New-MenuItem "Startup Commands" -On_Click { 
            get-wmiobject Win32_StartupCommand | sort -property Name | 
            select -property Name, Command, Location | Out-GridView -Title "Startup Commands"}
        
        New-MenuItem "Installed Software" -On_Click { 
            Get-ChildItem HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall | 
            % {Get-ItemProperty $_.PsPath} | where {$_.Displayname -and ($_.Displayname -match ".*")} | 
            sort Displayname | select DisplayName, Publisher, UninstallString | Out-GridView -Title "Installed Software"}
        
        New-MenuItem "Active NIC's" -On_Click {
            get-wmiobject Win32_NetworkAdapterConfiguration -Filter "IPEnabled=$true" | Out-GridView -Title "Active Network Cards"}
        
        New-MenuItem "IPv4 Route Table" -On_Click {
            get-wmiobject Win32_IP4RouteTable | sort Destination | 
        select Destination, Mask, NextHop, Age | Out-GridView -Title "Route Tabel"}
        
        New-MenuItem "E_xit" -on_click {             
            $window.Close()            
        }             
    }   
        New-MenuItem "Help" {
        
        New-MenuItem "Credits" -On_Click { New-BalloonTip "Network Config Tool" "DTTD/Team Client"}         
        
        New-MenuItem "About..." -On_Click { 
            get-wmiobject Win32_ComputerSystem | 
            Select Username,DNSHostName,Domain,Manufacturer,Model,SystemType,TotalPhysicalMemory | 
            Out-GridView -Title "System Info"}       
}
}
        $Layout = @{ FontSize = 14; Margin = 1; Maxwidth = 300}
        
        New-Label "Network Config Tool" -HorizontalContentAlignment Center -FontSize 18  -Foreground Green

        New-Label "Select your NIC:" @Layout

        New-ComboBox -Name nics -items ($nic_name=((gwmi win32_networkadapter -Filter "NetEnabled=$true").name)) `
        @layout -On_SelectionChanged {
        $nicname.text = (gwmi win32_networkadapter | where name -EQ "$($nics.SelectedValue)").InterfaceIndex 
        $NetAdapter = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -filter "InterfaceIndex = $($nicname.text)"
        $ip.text = ($NetAdapter).ipaddress[0]; 
        $mask.text = ($NetAdapter).ipsubnet[0]; 
        $gw.text = ($NetAdapter).DefaultIPGateway[0]
        }
        
        New-Label "Enter your IP Address:" @Layout
        New-TextBox -Name ip @Layout -Text ""
        
        New-Label "Enter subnet mask:" @Layout
        New-TextBox -Name mask @Layout -Text ""
        
        New-Label "Enter Gateway:" @Layout
        New-TextBox -Name gw @Layout -Text ""
        
        New-CheckBox -Content "Set MTU" -FontSize 10 -Margin 5 -HorizontalAlignment Center -MaxWidth 300 -Name setmtu -ToolTip "1476"

        $range = (Get-Content -Path "$PSScriptRoot\ipranges.txt").Replace(";"," ") | Sort-Object 

    New-StackPanel  -Children {
        
        New-Label "Select your PDC on the list:" @Layout
        
        New-ComboBox -Name iprange -Items $range @Layout -On_SelectionChanged {
        $cdp = ($iprange.SelectedValue).split("  ")
        $pdc.text = $cdp[0]
        [ipaddress]$pdc_ip.text = $cdp[1]
        $net.text = $cdp[2]
        }
        
        New-Label "Your PDC Name:" @Layout
        New-TextBox -Name pdc @Layout -text $pdc.text
        
        New-Label "Your PDC IP:" @Layout
        New-TextBox -Name pdc_ip @Layout -text $pdc_ip.text
        
        New-Label "Your Subnet:" @Layout
        New-TextBox -Name net @Layout -text $net.text
        
        # New-Label "Your Nic name:" @Layout
        # Invisible textbox
        New-TextBox -Name nicname -text $nicname.text -MaxWidth 1 -MaxHeight 1
        
        New-Button -VerticalAlignment Bottom -Margin 10 -MaxWidth 150 -FontSize 15 `
        -Content "Join Domain" -On_Click { 
        Get-ParentControl | Set-UIValue -passThru
        
        $dom = $pdc.text + "_DOM"
        write-host "Selected NIC is $($nics.SelectedValue) with index $($nicname.text)"
        
        $nic=gwmi Win32_NetworkAdapterConfiguration -Filter "InterfaceIndex=$($nicname.text)"
        $nic.EnableStatic("$($ip.Text)","$($mask.Text)")
        $nic.SetGateways("$($gw.Text)")
        $window.Cursor = "Wait"
        
        if ($setmtu.IsChecked) {write-host "MTU will be set to $($setmtu.tooltip)";
        $RegistryEntries = Get-ItemProperty -path "HKLM:\system\currentcontrolset\services\tcpip\parameters\interfaces\*"
        foreach ( $iface in $RegistryEntries ) {
        $ip = $iface.DhcpIpAddress
        if ( $ip -ne $null ) { $childName = $iface.PSChildName}
        else {
        $ip = $iface.IPAddress
        if ($ip -ne $null) { $childName = $iface.PSChildName }
        }
        $Interface = Get-ItemProperty -path "HKLM:\system\currentcontrolset\services\tcpip\parameters\interfaces\$childName"
        $path = $Interface.PSPath
        SetProperty $path MTU 1476
        }
        }
        if (JoinDomain $dom admin ctislp) { 
        [Microsoft.VisualBasic.Interaction]::Msgbox("Successfully joined domain $dom",0,"Joining Domain")}
        Close-Control
        }
      }

    }
}

#endregion 