################################################# 
# Name: Install-SCCMPrereqs.ps1
# Author: Nickolaj Andersen
# Date: 2013-04-14
# Version: 1.2
# 
# Examples:
# 
# .\Install-SCCMPrereqs.ps1 -SiteType CAS
# .\Install-SCCMPrereqs.ps1 -SiteType Primary
# .\Install-SCCMPrereqs.ps1 -SiteType Secondary
# .\Install-SCCMPrereqs.ps1 -ExtendSchema
# .\Install-SCCMPrereqs.ps1 -InstallWADK
#################################################
 
[CmdletBinding()]
param(
[ValidateSet("CAS","Primary","Secondary")]
[string]$SiteType,
[switch]$ExtendSchema,
[switch]$InstallWADK
)
 
function Install-NETFramework3.5 {
    $a = 0
    $NETFeature = @("NET-Framework-Core")
    $NETFeaturesCount = $NETFeature.Count
    $NETFeature | ForEach-Object {
        $a++
        Write-Progress -id 1 -Activity "Installing Windows Features" -Status "Windows Feature $($a) of $($NETFeaturesCount)" -PercentComplete (($a / $NETFeaturesCount)*100)
        Write-Host "Installing: $_"
        Add-WindowsFeature $_ | Out-Null
    }
}
 
function Install-WindowsFeatures {
    $i = 0
    $WinFeatures = @("BITS","BITS-IIS-Ext","BITS-Compact-Server","RDC","WAS-Process-Model","WAS-Config-APIs","WAS-Net-Environment","Web-Server","Web-ISAPI-Ext","Web-ISAPI-Filter","Web-Net-Ext","Web-Net-Ext45","Web-ASP-Net","Web-ASP-Net45","Web-ASP","Web-Windows-Auth","Web-Basic-Auth","Web-URL-Auth","Web-IP-Security","Web-Scripting-Tools","Web-Mgmt-Service","Web-Stat-Compression","Web-Dyn-Compression","Web-Metabase","Web-WMI","Web-HTTP-Redirect","Web-Log-Libraries","Web-HTTP-Tracing","UpdateServices-RSAT","UpdateServices-API","UpdateServices-UI")
    $WinFeaturesCount = $WinFeatures.Count
    $WinFeatures | ForEach-Object {
        $i++
        Write-Progress -id 1 -Activity "Installing Windows Features" -Status "Windows Feature $($i) of $($WinFeaturesCount)" -PercentComplete (($i / $WinFeaturesCount)*100)
        Write-Host "Installing:" $_
        Add-WindowsFeature $_ | Out-Null
    }
    Write-Host "Windows Features successfully installed"
    Write-Host ""
}
 
function Install-WindowsFeaturesSecondary {
    $c = 0
    $SecFeatures = @("BITS","BITS-IIS-Ext","BITS-Compact-Server","RDC","WAS-Process-Model","WAS-Config-APIs","WAS-Net-Environment","Web-Server","Web-ISAPI-Ext","Web-Windows-Auth","Web-Basic-Auth","Web-URL-Auth","Web-IP-Security","Web-Scripting-Tools","Web-Mgmt-Service","Web-Metabase","Web-WMI")
    $SecFeaturesCount = $SecFeatures.Count
    $SecFeatures | ForEach-Object {
        $c++
        Write-Progress -id 1 -Activity "Installing Windows Features" -Status "Windows Feature $($c) of $($SecFeaturesCount)" -PercentComplete (($c / $SecFeaturesCount)*100)
        Write-Host "Installing:" $_
        Add-WindowsFeature $_ | Out-Null
    }
    Write-Host "Windows Features successfully installed"
}
 
function Set-ExtendADAchema {
    if ($ExtendSchema -eq $true) {
        $RegExp = "^[A-Z]*\:$"
        $DriveLetter = Read-Host "Enter drive (e.g. 'D:') letter for ConfigMgr source files"
        if ($DriveLetter -match $RegExp) {
            $Schema = $true
        }
        else {
            Write-Warning "Wrong drive letter specified" -ErrorAction Stop
        }
    }
    if ($Schema) {
        $DC = Read-Host "Enter Domain Controller"
        $GetPath = Get-ChildItem -Recurse -Filter "EXTADSCH.EXE" -Path $DriveLetter\SMSSETUP\BIN\X64
        $Path = $GetPath.DirectoryName + "\EXTADSCH.EXE"
        $Destination = "\\" + $DC + "\C$"
        Copy-Item $Path $Destination -Force
        Invoke-WmiMethod -Class Win32_Process -Name Create -ArgumentList "C:\EXTADSCH.EXE" -ComputerName $DC | Out-Null
    }
    $Content = Get-Content -Path "\\$DC\C$\extadsch.log"
    if ($Content -match "Successfully extended the Active Directory schema") {
        Write-Host "Active Directory was successfully extended"
    }
    else {
        Write-Warning "Active Directory was not extended successfully, refer to C:\ExtADSch.log on domain controller"
    }
}
 
function Get-PrereqFiles {
    $RegExp = "^[A-Z]*\:$"
    $DriveLetter = Read-Host "Enter drive letter (e.g. 'D:') for ConfigMgr source files"
        if ($DriveLetter -match $RegExp) {
                $Prereq = $true
            }
        else {
            Write-Warning "Wrong drive letter specified. Enter drive letter like 'D:'" -ErrorAction Stop
        }
    if ($Prereq) {
        $dldest = "C:\ConfigMgr_Prereq"
        if (!(Test-Path -Path $dldest)) {
            New-Item $dldest -ItemType Directory | Out-Null
        }
        try {
            if (Test-Path "$DriveLetter\SMSSETUP\BIN\X64\setupdl.exe") {
                $Download = $true
            }
        }
        catch {
            Write-Warning "$DriveLetter\SMSSETUP\BIN\X64\setupdl.exe is not found" -ErrorAction Stop
        }
        if ($Download) {
            Write-Host "Downloading Configuration Manager prerequisites to $($dldest), this may take a couple of minutes"
            Start-Process -FilePath "$DriveLetter\SMSSETUP\BIN\X64\setupdl.exe" -ArgumentList "$dldest" -Wait
            Write-Host "Successfully downloaded Configuration Manager prerequisites"
        }
    }
}
 
function Install-WindowsADK {
    $ADKInstalledFeatures = @()
    $ComputerName = $env:COMPUTERNAME
    $UninstallKey = "SOFTWARE\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall"
    $Registry = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine',$ComputerName)
    $RegistryKey = $Registry.OpenSubKey($UninstallKey)
    $SubKeys = $RegistryKey.GetSubKeyNames()
    ForEach ($Key in $SubKeys) {
        $CurrentKey = $UninstallKey + "\\" + $Key
        $CurrentSubKey = $Registry.OpenSubKey($CurrentKey)
        $DisplayName = $CurrentSubKey.GetValue("DisplayName")
        if ($DisplayName -like "Windows PE x86 x64") {
            $ADKInstalledFeatures += $DisplayName
        }
        elseif ($DisplayName -like "User State Migration Tool") {
            $ADKInstalledFeatures += $DisplayName
        }
        elseif ($DisplayName -like "Windows Deployment Tools") {
            $ADKInstalledFeatures += $DisplayName
        }
    }
    if ($ADKInstalledFeatures -notcontains "Windows PE x86 x64") {
        Write-Warning "Windows PE x86 x64 is not installed"
    }
    if ($ADKInstalledFeatures -notcontains "User State Migration Tool") {
        Write-Warning "User State Migration Tool is not installed"
    }
    if ($ADKInstalledFeatures -notcontains "Windows Deployment Tools") {
        Write-Warning "Windows Deployment Tools is not installed"
    }
    $dlfolder = "C:\Downloads"
    if (!(Test-Path -Path $dlfolder)) {
        New-Item $dlfolder -ItemType Directory | Out-Null
    }
    Write-Host ""
    if ($ADKInstalledFeatures.Length -eq 3) {
        Write-Host "All required Windows ADK features are already installed, skipping install"
    }
    else {
        $ADKObject = New-Object Net.WebClient
        $ADKUrl = "http://download.microsoft.com/download/9/9/F/99F5E440-5EB5-4952-9935-B99662C3DF70/adk/adksetup.exe"
        Write-Host "Downloading: adksetup.exe"
        $ADKObject.DownloadFile($ADKUrl, "$dlfolder\adksetup.exe")
        Write-Host "Installing: Windows ADK"
        Write-Host "This may take 10 minutes or more, since the adksetup.exe downloads components from the internet"
        $ADKarguments = "/norestart /q /ceip off /features OptionId.WindowsPreinstallationEnvironment OptionId.DeploymentTools OptionId.UserStateMigrationTool"
        Start-Process -FilePath "$dlfolder\adksetup.exe" -ArgumentList $ADKarguments -Wait
        Write-Warning "Windows ADK is now installing in the background, give it a few minutes to complete"
    }
}
 
function Install-SitePrereq {
    Install-NETFramework3.5
    Install-WindowsFeatures
    Get-PrereqFiles
}
 
function Install-SecondaryPrereq {
    Install-NETFramework3.5
    Install-WindowsFeaturesSecondary
}
 
if ($InstallWADK) {
    Install-WindowsADK
}
 
if ($ExtendSchema) {
    Set-ExtendADAchema
}
 
if (($SiteType -like "CAS") -OR ($SiteType -like "Primary")) {
    Install-SitePrereq
    Write-Host ""
    Write-Host -ForegroundColor Green "Prerequisites installed successfully"
}
elseif ($SiteType -like "Secondary") {
    Install-SecondaryPrereq
    Write-Host ""
    Write-Host -ForegroundColor Green "Prerequisites installed successfully"
}
elseif ($SiteType -eq $null) {
    Write-Warning "The parameter SiteType was not defined"
}