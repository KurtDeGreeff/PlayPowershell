#Author: Kurt De Greeff
$ScriptPath = Split-path -parent $MyInvocation.MyCommand.Definition
$ScriptPath = $ScriptPath.Replace("\","")
cd $ScriptPath
Import-Module ServerManager # Must be run as Administrator console

#region Function Extract-Zip
Function Extract-Zip
{
param([string]$zipfilename,[string]$destination)
if (Test-Path($zipfilename))
{
$shellApplication = New-Object -ComObject shell.application
$zipPackage = $shellApplication.NameSpace($zipfilename)
$destinationFolder = $shellApplication.NameSpace($destination)
$destinationFolder.CopyHere($zipPackage.Items())
}
}
#endregion

#region Install Windows AIK 2.0

#endregion

#region Install DHCP (scope will be created by other script)

if ((Get-WindowsFeature DHCP | add-WindowsFeature).exitCode -eq "success")
{ Write-Host "DHCP Server successfully installed" -BackgroundColor DarkGreen
}
else
{ Write-Host "DHCP Server already installed" -BackgroundColor DarkGreen
}
#endregion

#region Add WDS Transport Server role
if ((Get-WindowsFeature WDS-Transport | add-WindowsFeature).exitCode -eq "success")
{ Write-Host "WDS Transport Server successfully installed" -BackgroundColor DarkGreen
}
else
{ Write-Host "WDS Transport Server already installed" -BackgroundColor DarkGreen
}
#endregion   

#region Create & share RemoteInstall folder structure
Write-Host "Creating & sharing WDS Remoteinstall older" -BackgroundColor DarkGreen
New-Item -Path d:\ -Name RemoteInstall -ItemType Directory -Force

$share = [wmiclass]"win32_share"
$Results = $share.create("d:\remoteinstall","REMINST",0,0, "WDS Remote Install")
if ($Results.returnvalue -eq "0") {Write-Host "WDS Share successfully created" -BackgroundColor DarkGreen}

#endregion

start-sleep -Seconds 2

#region unzip the x86/x64 boot files and images
Write-Host "Creating folder structure..." -BackgroundColor DarkGreen
Extract-Zip "$ScriptPath\wds.zip" "D:\RemoteInstall" | Write-Host "Extracting.." 

#endregion

#region Configure the WDS Providers
#WDS Provider Order
New-ItemProperty -Path HKLM:\System\CurrentControlSet\services\WDSServer\Providers\WDSPXE -Name ProvidersOrder -PropertyType MultiString -Value WDSSIPR

#Configure TFTP root folder
New-ItemProperty -Path HKLM:\System\CurrentControlSet\services\WDSServer\Providers\WDSTFTP -Name RootFolder -PropertyType String -Value D:\RemoteInstall
#endregion

#region Configure the Policies
Write-Host "Copying wdssipr.dll.conf.ini ..." -BackgroundColor DarkGreen
Copy-Item "D:\RemoteInstall\wdssipr.dll.conf.ini" -Destination "c:\windows\system32\" -Force

#endregion

#region Additional DHCP/WDS Provider Configuration
WDSUTIL /Set-TransportServer /ObtainIPv4From:DHCP
Set-ItemProperty -Path HKLM:\System\CurrentControlSet\services\WDSServer\Providers\WDSPXE -Name UseDhcpPorts -Value 0
WDSUTIL /Start-TransportServer

#endregion

Write-Host "WDS Successfully installed" -BackgroundColor DarkGreen