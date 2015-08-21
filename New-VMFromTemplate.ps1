<#
.Synopsis
Provision a new Hyper-V virtual machine based on a template
.Description
This script will create a new Hyper-V virtual machine based on a template or
hardware profile. You can create a Small, Medium or Large virtual machine. All
virtual machines will use the same virtual switch and the same paths for the
virtual machine and VHDX file.  All virtual machines will be created with dynamic
VHDX files and dynamic memory. All virtual machines will mount the same Windows
Server 2012 ISO file so that you can start the virtual machine and load an
operating system.
VM Types
Small (default)
        MemoryStartup=512MB
        VHDSize=10GB
        ProcCount=1
        MemoryMinimum=512MB
        MemoryMaximum=1GB
Medium
        MemoryStartup=512MB
        VHDSize=20GB
        ProcCount=2
        MemoryMinimum=512MB
        MemoryMaximum=2GB
Large
        MemoryStartup=1GB
        VHDSize=40GB
        ProcCount=4
        MemoryMinimum=512MB
        MemoryMaximum=4GB
This script requires the Hyper-V 3.0 PowerShell module.
.Example
PS C:\Scripts\> .\New-VMFromTemplate WEB2012-01 -VMType Small -passthru
Name       State CPUUsage(%) MemoryAssigned(M) Uptime   Status
----       ----- ----------- ----------------- ------   ------
WEB2012-01 Off   0           0                 00:00:00 Operating normally
.Link
New-VM
Set-VM
#>
[cmdletbinding(SupportsShouldProcess)]
Param(
[Parameter(Position=0,Mandatory,HelpMessage="Enter the name of your new virtual machine")]
[ValidateNotNullOrEmpty()]
[string]$Name,
[ValidateSet("Small","Medium","Large")]
[string]$VMType="Small",
[switch]$Passthru
)
Write-Verbose "Creating new $VMType virtual machine"
#universal settings regardless of type
#the ISO for installing Windows 2012
$ISO = "G:\iso\9200.16384.WIN8_RTM.120725-1247_X64FRE_SERVER_EVAL_EN-US-HRM_SSS_X64FREE_EN-US_DV5.ISO"
#all VMs will be on the same network switch
$Switch = "Work Network"
#path for the virtual machine. All machines will use the same path.
$Path="C:\VMs"
#path for the new VHDX file. All machines will use the same path.
$VHDPath= Join-Path "F:\VHD" "$($name)_C.vhdx"
#define parameter values based on VM Type
Switch ($VMType) {
    "Small" {
        $MemoryStartup=512MB
        $VHDSize=10GB
        $ProcCount=1
        $MemoryMinimum=512MB
        $MemoryMaximum=1GB
    }
    "Medium" {
        $MemoryStartup=512MB
        $VHDSize=20GB
        $ProcCount=2
        $MemoryMinimum=512MB
        $MemoryMaximum=2GB
    }
    "Large" {
        $MemoryStartup=1GB
        $VHDSize=40GB
        $ProcCount=4
        $MemoryMinimum=512MB
        $MemoryMaximum=4GB
    }
} #end switch
#define a hash table of parameters for New-VM
$newParam = @{
Name=$Name
SwitchName=$Switch
MemoryStartupBytes=$MemoryStartup
Path=$Path
NewVHDPath=$VHDPath
NewVHDSizeBytes=$VHDSize
ErrorAction="Stop"
}
#define a hash table of parameters for Set-VM
$setParam = @{
ProcessorCount=$ProcCount
DynamicMemory=$True
MemoryMinimumBytes=$MemoryMinimum
MemoryMaximumBytes=$MemoryMaximum
ErrorAction="Stop"
}
if ($Passthru) {
    $setParam.Add("Passthru",$True)
}
Try {
    Write-Verbose "Creating new virtual machine"
    Write-Verbose ($newParam | out-string)
    $VM = New-VM @newparam
}
Catch {
    Write-Warning "Failed to create virtual machine $Name"
    Write-Warning $_.Exception.Message
    #bail out
    Return
}
if ($VM) {
    #mount the ISO file
    Try {
        Write-Verbose "Mounting DVD $iso"
        Set-VMDvdDrive -vmname  $vm.name -Path $iso -ErrorAction Stop
    }
    Catch {
        Write-Warning "Failed to mount ISO for $Name"
        Write-Warning $_.Exception.Message
        #don't bail out but continue to try and configure virtual machine
    }
    Try {
        Write-Verbose "Configuring new virtual machine"
        Write-Verbose ($setParam | out-string)
        $VM | Set-VM @setparam
    }
    Catch {
    Write-Warning "Failed to configure virtual machine $Name"
    Write-Warning $_.Exception.Message
    #bail out
    Return
    }
} #if $VM


Read more: http://www.altaro.com/hyper-v/create-virtual-machine-from-template-powershell/#ixzz2QteXUff8