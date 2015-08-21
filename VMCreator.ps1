# VMCreator v2.4.1003           #
# Copyright 2013 Microsoft      #
# A TED Sample Solution         #
# Created by Rob Willis         #
# Rob.Willis@microsoft.com      #

Param
(
    [Parameter(Mandatory=$false,Position=0)]
    [String]$Path = (Get-Location)
)

$host.UI.RawUI.BackgroundColor = "Black"; Clear-Host

# Elevate
Write-Host "Checking for elevation... " -NoNewline
$CurrentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
if (($CurrentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) -eq $false)  {
    $ArgumentList = "-noprofile -noexit -file `"{0}`" -Path `"$Path`""
    Write-Host "elevating"
    Start-Process powershell.exe -Verb RunAs -ArgumentList ($ArgumentList -f ($myinvocation.MyCommand.Definition))
    Exit
}

$Host.UI.RawUI.BackgroundColor = "Black"; Clear-Host
$Validate = $true

# Check PS host
If ($Host.Name -ne 'ConsoleHost') {
    $Validate = $false
    Write-Host "VMCreator.ps1 should not be run from ISE" -ForegroundColor Red
}

# Check OS version
If ((Get-WmiObject -Class Win32_OperatingSystem).Version -ne "6.2.9200") {
    $Validate = $false
    Write-Host "VMCreator.ps1 should be run from Windows Server 2012 or Windows 8" -ForegroundColor Red
}

# Change to path
If (Test-Path $Path -PathType Container) {
    Set-Location $Path
} Else {
    $Validate = $false
    Write-Host "Invalid path" -ForegroundColor Red
}

Function Get-Value ($Value,$Count) {
    If ((Invoke-Expression ("`$Variable.Installer.VMs.VM | Where-Object {`$_.Count -eq `$Count} | ForEach-Object {`$_.$Value}")) -ne $null) {
        Invoke-Expression ("Return `$Variable.Installer.VMs.VM | Where-Object {`$_.Count -eq `$Count} | ForEach-Object {`$_.$Value}")
    } Else {
        Invoke-Expression ("Return `$Variable.Installer.VMs.Default.$Value")
    }
}

Write-Host "Importing Hyper-V module"
If (!(Get-Module Hyper-V)) {Import-Module Hyper-V}

If (Get-Module Hyper-V) {
    
    Write-Host "Getting VMCreator input"

    $Validate = $true
    Write-Host ""

    If (Test-Path ".\Variable.xml") {
        try {$Variable = [XML] (Get-Content ".\Variable.xml")} catch {$Validate = $false;Write-Host "Invalid Variable.xml" -ForegroundColor Red}
    } Else {
        $Validate = $false
        Write-Host "Missing Variable.xml" -ForegroundColor Red
    }

    If ($Validate) {
        # Get how many VMs to create
        $VMCount = $Variable.Installer.VMs.Count
        Write-Host "Creating $VMCount VMs"
        $AutonamePrefix = $Variable.Installer.VMs.Default.VMName.Prefix
        [Int]$AutonameSequence = $Variable.Installer.VMs.Default.VMName.Sequence
        $AutoMACPrefix = $Variable.Installer.VMs.Default.NetworkAdapter.MAC.Prefix
        [Int]$AutoMACSequence = $Variable.Installer.VMs.Default.NetworkAdapter.MAC.Sequence
        $AutoIPPrefix = $Variable.Installer.VMs.Default.NetworkAdapter.IP.Prefix
        [Int]$AutoIPSequence = $Variable.Installer.VMs.Default.NetworkAdapter.IP.Sequence
        $InstallerServiceAccount = $Variable.Installer.Variable | Where-Object {$_.Name -eq "InstallerServiceAccount"}
        $InstallerServiceAccountDomain = $InstallerServiceAccount.Value.Split("\")[0]
        $InstallerServiceAccountUsername = $InstallerServiceAccount.Value.Split("\")[1]

        $AutonameCount = 0
        $AutoMACCount = 0
        $AutoIPCount = 0

        For ($i = 1; $i -le $VMCount; $i++) {

            $CreateVM = $true
            $DataDrive = 0
            $DataDisk = 0

            Write-Host ""
            # Get the VM name - specific or autonamed
            If ((Get-Value -Count $i -Value "VMName").GetType().FullName -eq "System.String") {
                $VMName = Get-Value -Count $i -Value "VMName"
            } Else {
                $VMName = $AutonamePrefix + ($AutonameSequence + $AutonameCount).ToString("00")
                $AutonameCount ++
            }

            # Check required resources for creation exist

            # Get the VM host
            $VMHost = Get-Value -Count $i -Value "Host"
            Write-Host "  VM$i - $VMName on $VMHost"
            If (!(Get-VMHost -ComputerName $VMHost -ErrorAction SilentlyContinue)) {
                $CreateVM = $false
                Write-Host "    Host $VMHost does not exist" -ForegroundColor Red
            }
        
            # Check resources on VM host only if the host exists
            If ($CreateVM) {
                # Get OS disk
                $OSDisk = Get-Value -Count $i -Value "OSDisk.Parent"
                $OSDiskUNC = "\\" + $VMHost + "\" + $OSDisk.Replace(":","$")
                $VHDFolder = (Get-Value -Count $i -Value "VHDFolder") + "\" + $VMName + "\Virtual Hard Disks"
                $VHDFolderUNC = "\\" + $VMHost + "\" + $VHDFolder.Replace(":","$")
                $OSVHDFormat = $OSDisk.Split(".")[$OSDisk.Split(".").Count - 1]
                If (!(Test-Path $OSDiskUNC)) {
                    $CreateVM = $false
                    Write-Host "    OS parent disk $OSDisk does not exist" -ForegroundColor Red
                }

                # Get pagefile disk
                $PagefileDisk = Get-Value -Count $i -Value "PagefileDisk"
                If (($PagefileDisk -ne $null) -and ($PagefileDisk -ne "")) {
                    $PagefileDiskUNC = "\\" + $VMHost + "\" + $PagefileDisk.Replace(":","$")
                    If (!(Test-Path $PagefileDiskUNC)) {
                        $CreateVM = $false
                        Write-Host "    Pagefile parent disk $PagefileDisk does not exist" -ForegroundColor Red
                    }
                }

                # Get the VM switch
                $VMSwitch = Get-Value -Count $i -Value "NetworkAdapter.VirtualSwitch"
                If (!(Get-VMSwitch -Name $VMSwitch -ComputerName $VMHost -ErrorAction SilentlyContinue)) {
                    $CreateVM = $false
                    Write-Host "    Virtual switch does not exist" -ForegroundColor Red
                }
            }

            # Check resources to be created do not already exist
            If ($CreateVM) {

                # Check the VM does not already exist
                If (Get-VM -Name $VMName -ComputerName $VMHost -ErrorAction SilentlyContinue) {
                    $CreateVM = $false
                    Write-Host "    VM already exists" -ForegroundColor Red
                }

                # Check the OS disk does not already exist
                If (Test-Path "$VHDFolderUNC\$VMName.$OSVHDFormat") {
                    $CreateVM = $false
                    Write-Host "    Disk $VHDFolder\$VMName.$OSVHDFormat already exists" -ForegroundColor Red
                }

                # Check the pagefile disk does not already exist
                If (($PagefileDisk -ne $null) -and ($PagefileDisk -ne "")) {
                    $PagefileVHDFormat = $PagefileDisk.Split(".")[$PagefileDisk.Split(".").Count - 1]
                    $PagefileVHDName = $VMName + "_" + [char](68 + $DataDrive) + "1"
                    If (Test-Path "$VHDFolderUNC\$PagefileVHDName.$PagefileVHDFormat") {
                        $CreateVM = $false
                        Write-Host "    Disk $VHDFolder\$PagefileVHDName.$PagefileVHDFormat already exists" -ForegroundColor Red
                    }
                }
            }

            # Create
            If ($CreateVM) {

                # Create the VM
                Write-Host "    Creating $VMName"
                New-VM -Name $VMName -ComputerName $VMHost -Path (Get-Value -Count $i -Value "VMFolder") -NoVHD | Out-Null

                # Set processors
                $Processor = Get-Value -Count $i -Value "Processor"
                Write-Host "    Setting processors to $Processor"
                Set-VMProcessor -VMName $VMName -ComputerName $VMHost -Count $Processor

                # Set memory
                If (((Get-Value -Count $i -Value "Memory").GetType().FullName -eq "System.String") -or ((Get-Value -Count $i -Value "Memory.Minimum") -eq (Get-Value -Count $i -Value "Memory.Maximum"))) {
                    If ((Get-Value -Count $i -Value "Memory").GetType().FullName -eq "System.String") {
                        [Int64]$Memory = Get-Value -Count $i -Value "Memory"
                    }
                    If ((Get-Value -Count $i -Value "Memory.Minimum") -eq (Get-Value -Count $i -Value "Memory.Maximum")) {
                        [Int64]$Memory = Get-Value -Count $i -Value "Memory.Maximum"
                    }
                    Write-Host "    Setting memory to $Memory`MB"
                    $Memory = $Memory * 1024 * 1024
                    Set-VMMemory -VMName $VMName -ComputerName $VMHost -DynamicMemoryEnabled $false -StartupBytes $Memory
                } Else {
                    [Int64]$StartupMemory = Get-Value -Count $i -Value "Memory.Startup"
                    [Int64]$MinimumMemory = Get-Value -Count $i -Value "Memory.Minimum"
                    [Int64]$MaximumMemory = Get-Value -Count $i -Value "Memory.Maximum"
                    [Int64]$MemoryBuffer = Get-Value -Count $i -Value "Memory.Buffer"
                    Write-Host "    Setting memory to startup $StartupMemory`MB, minimum $MinimumMemory`MB, maximum $MaximumMemory`MB, buffer $MemoryBuffer`%"
                    $StartupMemory = $StartupMemory * 1024 * 1024
                    $MinimumMemory = $MinimumMemory * 1024 * 1024
                    $MaximumMemory = $MaximumMemory * 1024 * 1024
                    Set-VMMemory -VMName $VMName -ComputerName $VMHost -DynamicMemoryEnabled $true -StartupBytes $StartupMemory -MinimumBytes $MinimumMemory -MaximumBytes $MaximumMemory -Buffer $MemoryBuffer
                }

                # Set network adapter
                Remove-VMNetworkAdapter -VMName $VMName -ComputerName $VMHost
                $MAC = Get-Value -Count $i -Value "NetworkAdapter.MAC"
                If (($MAC -eq $null) -or ($MAC -eq "") -or ($MAC -eq "Dynamic")) {
                    Write-Host "    Adding network adapter with dynamic MAC on $VMSwitch"
                    Add-VMNetworkAdapter -VMName $VMName -ComputerName $VMHost -DynamicMACAddress -SwitchName $VMSwitch
                } Else {
                    If ($MAC.GetType().FullName -eq "System.String") {
                        $MAC = Get-Value -Count $i -Value "NetworkAdapter.MAC"
                    } Else {
                        $MACSuffix = ($AutoMACSequence + $AutoMACCount)
                        If ($MACSuffix -lt 16) {
                            $MAC = $AutoMACPrefix + "0" + [Convert]::ToString($MACSuffix,16)
                        } Else {
                            $MAC = $AutoMACPrefix + [Convert]::ToString($MACSuffix,16)
                        }
                        $AutoMACCount ++
                    }
                    Write-Host "    Adding network adapter with MAC $MAC on $VMSwitch"
                    Add-VMNetworkAdapter -VMName $VMName -ComputerName $VMHost -StaticMACAddress $MAC -SwitchName $VMSwitch
                }

                # Set OS disk
                Switch (Get-Value -Count $i -Value "OSDisk.Type") {
                    "Differencing" {
                        Write-Host "    Creating differencing disk $VHDFolder\$VMName.$OSVHDFormat"
                        New-VHD -ComputerName $VMHost -Path "$VHDFolder\$VMName.$OSVHDFormat" -ParentPath $OSDisk | Out-Null
                    }
                    "Copy" {
                        Write-Host "    Copying disk $OSDisk to $VHDFolder\$VMName.$OSVHDFormat"
                        If (!(Test-Path $VHDFolderUNC)) {New-Item -Path $VHDFolderUNC -ItemType Directory | Out-Null}
                        Copy-Item -Path $OSDiskUNC -Destination "$VHDFolderUNC\$VMName.$OSVHDFormat"
                    }
                }
                Write-Host "    Attaching disk $VHDFolder\$VMName.$OSVHDFormat to IDE 0:0"
                Add-VMHardDiskDrive -VMName $VMName -ComputerName $VMHost -ControllerType IDE -ControllerNumber 0 -ControllerLocation 0 -Path "$VHDFolder\$VMName.$OSVHDFormat"

                # Set pagefile disk
                If (($PagefileDisk -ne $null) -and ($PagefileDisk -ne "")) {
                    $DataDrive++
                    Write-Host "    Copying disk $PagefileDisk to $VHDFolder\$PagefileVHDName.$PagefileVHDFormat"
                    Copy-Item -Path $PagefileDiskUNC -Destination "$VHDFolderUNC\$PagefileVHDName.$PagefileVHDFormat"
                    Write-Host "    Attaching disk $VHDFolder\$PagefileVHDName.$PagefileVHDFormat to IDE 0:1"
                    Add-VMHardDiskDrive -VMName $VMName -ComputerName $VMHost -ControllerType IDE -ControllerNumber 0 -ControllerLocation 1 -Path "$VHDFolder\$PagefileVHDName.$PagefileVHDFormat"
                    $DiskPrepStart = 2
                } Else {
                    $DiskPrepStart = 1
                }

                # Set DVD
                $DVD = Get-Value -Count $i -Value "DVD"
                If ($DVD -ne "True") {
                    Write-Host "    Removing DVD"
                    Remove-VMDVDDrive -VMName $VMName -ComputerName $VMHost -ControllerNumber 1 -ControllerLocation 0
                } Else {
                    $DataDrive++
                }

                # Set data disks
                $DataDisks = Get-Value -Count $i -Value "DataDisks"
                $DiskPrepCount = 0
                If (($DataDisks -ne $null) -and ($DataDisks -ne "")) {
                    $DataDisks | ForEach-Object {
                        $DataDiskCount = $_.Count
                        $DataDiskFormat = $_.Format
                        [int64]$DataDiskSizeGB = $_.Size
                        $DataDiskSize = $DataDiskSizeGB * 1024 * 1024 * 1024
                        For ($j = 1; $j -le $DataDiskCount; $j++) {
                            $DataDiskName = $VMName + "_" + [char](68 + $DataDrive) + "1"
                            Write-Host "    Creating $DataDiskSizeGB`GB data disk $VHDFolder\$DataDiskName.$DataDiskFormat"
                            New-VHD -ComputerName $VMHost -Path "$VHDFolder\$DataDiskName.$DataDiskFormat" -Dynamic -SizeBytes $DataDiskSize | Out-Null
                            Write-Host "    Attaching disk $VHDFolder\$DataDiskName.$DataDiskFormat to SCSI 0:$DataDisk"
                            Add-VMHardDiskDrive -VMName $VMName -ComputerName $VMHost -ControllerType SCSI -ControllerNumber 0 -ControllerLocation $DataDisk -Path "$VHDFolder\$DataDiskName.$DataDiskFormat"
                            $DataDrive++
                            $DataDisk++
                            $DiskPrepCount++
                        }
                    }
                }

                # Mount OS disk to insert unattend files
                $Drive = $null
                While ($Drive -eq $null) {
                    Write-Host "    Mounting $VHDFolder\$VMName.$OSVHDFormat"
                    $Drive = (Mount-VHD -Path "$VHDFolderUNC\$VMName.$OSVHDFormat" -PassThru | Get-Disk | Get-Partition).DriveLetter
                    If ($Drive -ne $null) {
                        Write-Host "      $VHDFolder\$VMName.$OSVHDFormat mounted as $Drive`:"
                        $JoinDomain = Get-Value -Count $i -Value "JoinDomain.Domain"
                        $JoinDomainDomain = Get-Value -Count $i -Value "JoinDomain.Credentials.Domain"
                        $JoinDomainPassword = Get-Value -Count $i -Value "JoinDomain.Credentials.Password"
                        $JoinDomainUsername = Get-Value -Count $i -Value "JoinDomain.Credentials.Username"
                        $AdministratorPassword = Get-Value -Count $i -Value "AdministratorPassword"
                        Write-Host "      Inserting unattend.xml"
                        Write-Host "        Join domain: $JoinDomain"
                        Write-Host "        Join domain credentials: $JoinDomainDomain\$JoinDomainUsername"
                        Write-Host "        Installer service account: $InstallerServiceAccountDomain\$InstallerServiceAccountUsername"
                        $JoinDomainOrganizationalUnit = Get-Value -Count $i -Value "JoinDomain.OrganizationalUnit"
                        $JoinDomainOrganizationalUnitFull = ""
                        If (($JoinDomainOrganizationalUnit -ne $null) -and ($JoinDomainOrganizationalUnit -ne "")) {
                            $JoinDomainOrganizationalUnit.Split(".") | ForEach-Object {
                                $JoinDomainOrganizationalUnitFull = $JoinDomainOrganizationalUnitFull + "OU=$_,"
                            }
                            $JoinDomainDomain.Split(".") | ForEach-Object {
                                $JoinDomainOrganizationalUnitFull = $JoinDomainOrganizationalUnitFull + "DC=$_,"
                            }
                            $JoinDomainOrganizationalUnitFull = $JoinDomainOrganizationalUnitFull.Substring(0,$JoinDomainOrganizationalUnitFull.Length - 1)
                            Write-Host "        Organizational unit: $JoinDomainOrganizationalUnitFull"
                        }
@"
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
    <settings pass="specialize">
        <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <ComputerName>$VMName</ComputerName>
            <RegisteredOrganization></RegisteredOrganization>
            <RegisteredOwner></RegisteredOwner>
        </component>
"@ | Out-File "$Drive`:\unattend.xml" -Encoding ASCII
                        $IP = Get-Value -Count $i -Value "NetworkAdapter.IP"
                        If (!(($IP -eq $null) -or ($IP -eq "") -or ($IP -eq "DHCP"))) {
                            $IPAddress = Get-Value -Count $i -Value "NetworkAdapter.IP.Address"
                            If ($IPAddress -eq $null) {
                                $IPAddress = $AutoIPPrefix + ($AutoIPSequence + $AutoIPCount)
                                $AutoIPCount ++
                            }
                            $IPMask = Get-Value -Count $i -Value "NetworkAdapter.IP.Mask"
                            Write-Host "        IP address: $IPAddress/$IPMask"
                            $IPGateway = Get-Value -Count $i -Value "NetworkAdapter.IP.Gateway"
                            Write-Host "        IP gateway: $IPGateway"
@"
        <component name="Microsoft-Windows-TCPIP" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <Interfaces>
                <Interface wcm:action="add">
                    <Ipv4Settings>
                        <DhcpEnabled>false</DhcpEnabled>
                    </Ipv4Settings>
                    <UnicastIpAddresses>
                        <IpAddress wcm:action="add" wcm:keyValue="1">$IPAddress/$IPMask</IpAddress>
                    </UnicastIpAddresses>
                    <Identifier>Ethernet</Identifier>
                    <Routes>
                        <Route wcm:action="add">
                            <Identifier>1</Identifier>
                            <Prefix>0.0.0.0/0</Prefix>
                            <NextHopAddress>$IPGateway</NextHopAddress>
                        </Route>
                    </Routes>
                </Interface>
            </Interfaces>
        </component>
        <component name="Microsoft-Windows-DNS-Client" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <Interfaces>
                <Interface wcm:action="add">
                    <DNSServerSearchOrder>
"@ | Out-File "$Drive`:\unattend.xml" -Append -Encoding ASCII
                            $DNSCount = 0
                            $DNS = Get-Value -Count $i -Value "NetworkAdapter.IP.DNS"
                            $DNS | ForEach-Object {
                                $DNSCount++
                                Write-Host "        DNS address: $_"
@"
                        <IpAddress wcm:action="add" wcm:keyValue="$DNSCount">$_</IpAddress>
"@ | Out-File "$Drive`:\unattend.xml" -Append -Encoding ASCII
                        }
@"
                    </DNSServerSearchOrder>
                    <Identifier>Ethernet</Identifier>
                </Interface>
            </Interfaces>
        </component>
"@ | Out-File "$Drive`:\unattend.xml" -Append -Encoding ASCII
                    }
@"
        <component name="Microsoft-Windows-UnattendedJoin" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <Identification>
                <Credentials>
                    <Domain>$JoinDomainDomain</Domain>
                    <Password>$JoinDomainPassword</Password>
                    <Username>$JoinDomainUsername</Username>
                </Credentials>
                <JoinDomain>$JoinDomain</JoinDomain>
"@ | Out-File "$Drive`:\unattend.xml" -Append -Encoding ASCII
                        If ($JoinDomainOrganizationalUnitFull -ne "") {
@"
                <MachineObjectOU>$JoinDomainOrganizationalUnitFull</MachineObjectOU>
"@ | Out-File "$Drive`:\unattend.xml" -Append -Encoding ASCII
                    }
@"
            </Identification>
        </component>
"@ | Out-File "$Drive`:\unattend.xml" -Append -Encoding ASCII
@"
        <component name="Networking-MPSSVC-Svc" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <DomainProfile_EnableFirewall>false</DomainProfile_EnableFirewall>
            <PrivateProfile_EnableFirewall>false</PrivateProfile_EnableFirewall>
            <PublicProfile_EnableFirewall>false</PublicProfile_EnableFirewall>
        </component>
        <component name="Microsoft-Windows-TerminalServices-LocalSessionManager" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <fDenyTSConnections>false</fDenyTSConnections>
        </component>
        <component name="Microsoft-Windows-TerminalServices-RDP-WinStationExtensions" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <UserAuthentication>0</UserAuthentication>
        </component>
    </settings>
    <settings pass="oobeSystem">
        <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <UserAccounts>
                <DomainAccounts>
                    <DomainAccountList wcm:action="add">
                        <Domain>$InstallerServiceAccountDomain</Domain>
                        <DomainAccount wcm:action="add">
                            <Name>$InstallerServiceAccountUsername</Name>
                            <Group>Administrators</Group>
                        </DomainAccount>
                    </DomainAccountList>
                </DomainAccounts>
                <AdministratorPassword>
                    <Value>$AdministratorPassword</Value>
                    <PlainText>true</PlainText>
                </AdministratorPassword>
            </UserAccounts>
            <RegisteredOrganization></RegisteredOrganization>
            <RegisteredOwner></RegisteredOwner>
            <OOBE>
                <HideEULAPage>true</HideEULAPage>
                <SkipMachineOOBE>true</SkipMachineOOBE>
            </OOBE>
        </component>
    </settings>
</unattend>
"@ | Out-File "$Drive`:\unattend.xml" -Append -Encoding ASCII
                        Write-Host "      Inserting SetupComplete.cmd"
                        If (!(Test-Path "$Drive`:\Windows\Setup\Scripts")) {New-Item -Path "$Drive`:\Windows\Setup\Scripts" -ItemType Directory | Out-Null}
@"
@echo off
if exist %SystemDrive%\unattend.xml del %SystemDrive%\unattend.xml
reg add HKLM\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell /v ExecutionPolicy /t REG_SZ /d "Unrestricted" /f
powershell.exe -command %WinDir%\Setup\Scripts\SetupComplete.ps1
"@ | Out-File "$Drive`:\Windows\Setup\Scripts\SetupComplete.cmd" -Encoding ASCII
                        Write-Host "      Inserting SetupComplete.ps1"
@"
Enable-PSRemoting -Force
For (`$a = $DiskPrepStart; `$a -lt ($DiskPrepStart + $DiskPrepCount); `$a++) {
    Get-Disk | Where-Object {`$_.Number -eq `$a} | Set-Disk -IsOffline `$false
    Get-Disk | Where-Object {`$_.Number -eq `$a} | Initialize-Disk -PartitionStyle MBR
    New-Partition -DiskNumber `$a -UseMaximumSize -AssignDriveLetter
    While ((Get-Partition -DiskNumber `$a -PartitionNumber 1).Type -ne "IFS") {            
        Get-Partition -DiskNumber `$a | Format-Volume -FileSystem NTFS -Confirm:`$false
    }
}
"@ | Out-File "$Drive`:\Windows\Setup\Scripts\SetupComplete.ps1" -Encoding ASCII
                    }
                    Write-Host "      Dismounting $VHDFolder\$VMName.$OSVHDFormat"
                    Dismount-VHD -Path "$VHDFolderUNC\$VMName.$OSVHDFormat"
                }

                # Set startup
                $AutoStartAction = Get-Value -Count $i -Value "AutoStart.Action"
                $AutoStartDelay = Get-Value -Count $i -Value "AutoStart.Delay"
                Write-Host "    Setting automatic start to `"$AutoStartAction`", delay $AutoStartDelay"
                Set-VM -VMName $VMName -ComputerName $VMHost -AutomaticStartAction $AutoStartAction
                Set-VM -VMName $VMName -ComputerName $VMHost -AutomaticStartDelay $AutoStartDelay

                # Start
                Start-VM -VMName $VMName -ComputerName $VMHost
            } Else {
                $AutoMACCount++
                $AutoIPCount++
            }

        }
        Write-Host ""
    }
} Else {
    Write-Host "Hyper-V module not available"
}