#Requires -RunAsAdministrator
#Requires -Version 3.0 

#References:
#Getting Started with Nano Server <https://technet.microsoft.com/en-us/library/mt126167.aspx>
#Quick Guide - Deploying Nano Server using PowerShell <http://deploymentresearch.com/Research/Post/479/Quick-Guide-Deploying-Nano-Server-using-PowerShell>

param (
    #[ValidateScript({ Test-Path $_ })]
    $ConvertWindowsImageScriptPath = 'C:\Users\Kurt\OneDrive\Powershell\Convert-WindowsImage.ps1'
)

function Main
{
    Set-StrictMode -Version Latest
    $ErrorActionPreference = "Stop"

    Import-Module Hyper-V
    Import-Module DISM
    $VerbosePreference = "Continue"

    #Get DriveLetter that  Windows Server 2016 mouted
    $moutedDrives = (Get-PSDrive -name d) # | where Description -eq 'J_SSS_X64FRE_EN-US_DV5')
    if ($moutedDrives -eq $null){
        # Mout-DiskImage for ISO file is not work in Windows 10/Windows Server 2016 preview. need to mount beforehand.
        throw ('Windows Server 2016 Preview ISO media is not mouted!')
    }
    $isoMountedDrive = $moutedDrives[0].Root

    $params = @{
        SourcePath = Join-Path $isoMountedDrive 'NanoServer\NanoServer.wim' -Resolve
        VHDPath = Join-Path (Get-VMHost).VirtualHardDiskPath "NanoServer.vhdx"
        VHDFormat = 'VHDX'
        #VHDPartitionStyle = 'GPT' #MBR for Gen1 VM, 'GPT' for Gen2 VM
        #Unattend = 'D:\shared\Images\WindowsServer2016Preview\UnattendXml\Unattend.xml'
        Edition = 1 # 1:CORESYSTEMSERVER_INSTALL, 2:CORESYSTEMSERVER_BOOT
    }

    #TODO: specify ps1 file path from parameter
    #Note: Need to remove version check in Convert-WindowsImage.ps when executin Windows 10 environment.
    & $ConvertWindowsImageScriptPath @params -EnableDebugger None -Verbose

    #Setup additional packages
    Mount-DiskImage -ImagePath $params.VHDPath
    try
    {
        #Get DriveLetters information
        $osRootDir = (Get-MoutedVHDInfo -VhdPath $params.VHD).OSRootDir
        $packageBasePath = Join-Path $isoMountedDrive 'NanoServer\Packages' -Resolve

        #Apply additional NanoServer packages
        $packageNames = @(
            #'Microsoft-NanoServer-Compute-Package.cab';
            #'Microsoft-NanoServer-FailoverCluster-Package.cab'; #Failover Clustering
            'Microsoft-NanoServer-Guest-Package.cab'; #Drivers for hosting Nano Server as a virtual machine
            #'Microsoft-NanoServer-OEM-Drivers-Package.cab'; #Basic drivers for a variety of network adapters and storage controllers
            #'Microsoft-NanoServer-Storage-Package.cab'; #File Server role and other storage components
            #'Microsoft-OneCore-ReverseForwarders-Package.cab'; #ReverseForwarder packages
        )
        foreach ($packageName in $packageNames)
        {
            Write-Verbose ('Add package: {0} to {1}...' -f $packageName, $osRootDir)
            Add-WindowsPackage –Path $osRootDir –PackagePath (Join-Path $packageBasePath $packageName -Resolve) -Verbose:$false > $null
            Write-Verbose ('Add package: en-us\{0} to {1}...' -f $packageName, $osRootDir)
            Add-WindowsPackage –Path $osRootDir –PackagePath (Join-Path $packageBasePath "en-us\$packageName" -Resolve) -Verbose:$false > $null
        }

        #Set SetupComplete.cmd file to show DHCP IP address
        Write-Verbose 'Setting SetupComplete.cmd...'
        $startupCmdPath = Join-Path $osRootDir 'Windows\Setup\Scripts\SetupComplete.cmd'
        (New-Object IO.FileInfo($startupCmdPath)).Directory.Create() #Ensure parent directory exists

        #Need some delay for some DHCP environment
        Set-Content -Path $startupCmdPath -Value 'powershell.exe -command "sleep 5" > nul' -Encoding Ascii
        
        #Show assigned IP addesses
        Add-Content -Path $startupCmdPath -Value 'ipconfig' -Encoding Ascii
    }
    finally
    {
        #Get-WindowsOptionalFeature -Path $osRootDir | Out-GridView
        Dismount-DiskImage -ImagePath $params.VHD
    }
}

#Return VHD Partition drive letter info
function Get-MoutedVHDInfo
{
    [OutputType([pscustomobject])]
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        [string] $VhdPath
    )

    $disk = Get-VHD -Path $VhdPath | Get-Disk
    switch ($disk.PartitionStyle)
    {
        "MBR"{
            #Get partition drive letters
            $driveLetters = [array]($disk | Get-Partition | Get-Volume | sort Size).DriveLetter
            
            if ($driveLetters.Count -eq 2)
            {
                #CreateReservedPartition specified
                $bootRootDir = "{0}:\" -f $driveLetters[0]
                $osRootDir = "{0}:\" -f $driveLetters[1]
            }
            else
            {
                #Assume single partition
                $bootRootDir = "{0}:\" -f $driveLetters[0]
                $osRootDir = "{0}:\" -f $driveLetters[0]
            }
        }
        "GPT"
        {
            #Assign Temporary DriveLetter for EFI partition
            $disk | Get-Partition | where Type -eq "System" | Add-PartitionAccessPath -AssignDriveLetter:$true -ErrorAction Continue
            $driveLetters = [array]($disk | Get-Partition | where DriveLetter -ne "`0" | sort Size).DriveLetter

            if ($driveLetters.Count -ne 2)
            {
                throw "Can't find drive letter assigned to partitions"
            }
            $bootRootDir = "{0}:\" -f $driveLetters[0]
            $osRootDir = "{0}:\" -f $driveLetters[1]
        }
    }

    return [pscustomobject] @{
        BootRootDir = $bootRootDir
        OSRootDir = $osRootDir
    }
}

Main