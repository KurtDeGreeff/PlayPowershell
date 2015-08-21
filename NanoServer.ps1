$ErrorActionPreference = "Stop"

$Script:LogFile = Join-Path $env:TEMP "New-NanoServerImage.log"
$Script:DismLogFile = Join-Path $env:TEMP "New-NanoServerImage (DISM).log"

### -----------------------------------
### Constants
### -----------------------------------

$IMAGE_NAME = "NanoServer.wim"
$IMAGE_CONVERTER = "Convert-WindowsImage.ps1"

$IMAGE_HASH_FILE = "HASH"
$KERNEL_DEBUG_KEY_FILE = "KernelDebugKey.txt"

$LEVEL_WARNING = "WARNING"
$LEVEL_VERBOSE = "VERBOSE"
$LEVEL_OUTPUT = "OUTPUT"
$LEVEL_NONE = "NONE"

$PACK_STORAGE = "Microsoft-NanoServer-Storage-Package.cab"
$PACK_COMPUTE = "Microsoft-NanoServer-Compute-Package.cab"
$PACK_CLUSTERING = "Microsoft-NanoServer-FailoverCluster-Package.cab"
$PACK_OEM_DRIVERS = "Microsoft-NanoServer-OEM-Drivers-Package.cab"
$PACK_GUEST_DRIVERS = "Microsoft-NanoServer-Guest-Package.cab"
$PACK_REVERSE_FORWARDERS = "Microsoft-OneCore-ReverseForwarders-Package.cab"

### -----------------------------------
### Strings
### -----------------------------------

$Strings = @{
	# "Administrator" refers to the Windows user account.
	ERR_USER_MUST_BE_ADMINISTRATOR = "This script must be run as Administrator.";
	
    # The strings after the dashes are not translatable.
    ERR_INCLUDE_DOMAIN_NAME_OR_DOMAIN_BLOB_PATH = "Include either -DomainName or -DomainBlobPath, not both.";
    ERR_INCLUDE_COMPUTER_NAME_OR_DOMAIN_BLOB_PATH = "Include either -ComputerName or -DomainBlobPath, not both.";
    ERR_DOMAIN_NAME_NO_COMPUTER_NAME = "-DomainName was included, but not -ComputerName.";
    ERR_EMS_PORT_WITH_NO_EMS = "-EMSPort was included, but not -EnableEMS.";
    ERR_DEBUG_AND_EMS_PORTS_EQUAL = "Both the kernel debugging port and the EMS port cannot be the same.";
    ERR_REUSE_NODE_WITHOUT_JOIN = "-ReuseDomainJoin was specified without -DomainName nor -DomainBlobPath.";
    ERR_INCLUDE_OEM_OR_GUEST_DRIVERS = "Include either -OEMDrivers or -GuestDrivers, not both.";

    ERR_EXTERNAL_CMD = "Failed with {0}."; # {0} is a number.

    # For the next block of messages, the strings between single quotes are not translatable.
	ERR_DIRECTORY_DOES_NOT_EXIST_IN_MEDIA_DIRECTORY = "The '{0}' directory does not exist in the specified media path.";
	ERR_DIRECTORY_DOES_NOT_EXIST_IN_DIRECTORY = "The '{0}' directory does not exist in the '{1}' directory ('{2}')."; # {2} is a path.
    ERR_BASE_DIRECTORY_DOES_NOT_EXIST = "The specified base directory does not exist.";
	ERR_DIRECTORY_DOES_NOT_EXIST_IN_BASE_DIRECTORY = "The '{0}' directory does not exist in the specified base directory.";
    ERR_IMAGE_DOES_NOT_EXIST = "The '{0}' image does not exist in the 'NanoServer' directory.";
	ERR_IMAGE_DOES_NOT_EXIST_IN_BASE_DIRECTORY = "The '{0}' image does not exist in the specified base directory.";
	ERR_IMAGE_CONVERTER_SCRIPT_DOES_NOT_EXIST = "The image converter script does not exist in the directory where this script is located.";
	ERR_TARGET_DIRECTORY_ALREADY_EXISTS = "The target directory already exists. If you want to rebuild this image, delete the directory first.";
    ERR_PACKAGE_DOES_NOT_EXIST = "Package '{0}' does not exist.";
    ERR_EXTRA_PACKAGE_DOES_NOT_EXIST = "Extra package '{0}' does not exist.";
    ERR_LANGUAGE_PACKAGE_DOES_NOT_EXIST = "Language package '{0}' does not exist.";
    ERR_ONE_OR_MORE_PACKAGES_DO_NOT_EXIST = "One or more packages do not exist.";
    ERR_ONE_OR_MORE_EXTRA_PACKAGES_DO_NOT_EXIST = "One or more extra packages do not exist.";
    ERR_DOMAIN_BLOB_DOES_NOT_EXIST = "The specified domain blob does not exist.";
    ERR_DRIVERS_DIRECTORY_DOES_NOT_EXIST = "The specified drivers directory does not exist ('{0}').";
	ERR_SPECIFIED_VHD_IMAGE_DOES_NOT_EXIST = "The specified VHD image does not exist.";
	
    LOG_HEADER = "New-NanoServerImage Session Started"; # "New-NanoImage cannot be translated."

    MSG_DONE = "Done. The log is at:`n{0}"; # {0} is a file path.
    MSG_TERMINATING_DUE_TO_ERROR = "Terminating due to an error. See log file at:`n{0}"; # {0} is a file path.
    MSG_TERMINATING_DUE_TO_CTRL_C = "Terminating due to Ctrl-C.";

    MSG_COMPUTING_PATHS = "Computing paths...";
    MSG_CHECKING_PATHS = "Checking paths...";
    MSG_CREATING_PATHS = "Creating paths...";

    MSG_COPYING_FILES = "Copying files...";
	MSG_SKIPPING_FILE_COPY = "Skipping file copy.";
	
    MSG_CONVERTING_IMAGE = "Converting image...";
    MSG_SKIPPING_IMAGE_CONVERSION = "Skipping image conversion.";

    MSG_COPYING_IMAGE = "Copying image...";
    MSG_MOUNTING_IMAGE = "Mounting image...";

    MSG_ADDING_PACKAGES = "Adding packages...";
    MSG_ADDING_EXTRA_PACKAGES = "Adding extra packages...";
    MSG_ADDING_PACKAGE = "Adding package '{0}'..."; # {0} is a file name.
    MSG_ADDING_LANGUAGE_PACKAGE = "Adding language package for '{0}'..."; # {0} is a file name.
    MSG_SKIPPING_PACKAGE_ADDITION = "Skipping package addition.";
    MSG_SKIPPING_EXTRA_PACKAGES_ADDITION = "Skipping extra packages addition.";

    MSG_ADDING_DRIVERS = "Adding drivers...";
    MSG_SKIPPING_DRIVER_ADDITION = "Skipping driver addition.";

    MSG_ADDING_UNATTEND = "Adding Unattend.xml..."; # The file name is not translatable.
    MSG_COLLECTING_DOMAIN_BLOB = "Collecting domain provisioning blob...";
    MSG_JOINING_DOMAIN = "Joining domain...";

    MSG_ENABLING_DEBUG = "Enabling Debug and BootDebug...";
    MSG_KERNEL_DEBUG_KEY_FILE = "Find the kernel debugging key at:`n{0}"; # {0} is a file path.

    MSG_ENABLING_EMS = "Enabling EMS and BootEMS...";
    MSG_ENABLING_IP_DISPLAY = "Enabling IP configuration display on boot...";

    MSG_DISMOUNTING_IMAGE = "Dismounting image...";
}

### -----------------------------------
### Build-Image Cmdlet
### -----------------------------------

<#
    .NOTES
        Copyright (C) Microsoft Corporation.  All rights reserved.

    .SYNOPSIS
        Modifies a base Nano Server installation image adding packages, drivers
        and configuring operating system options.

    .DESCRIPTION
        This script makes a local copy of the necessary files from the
        installation media and converts the included WIM Nano Server image into
        a VHD image. It then makes a copy of the converted VHD image into a
        user-supplied path and operates on it as required. The installation
        media copy and WIM image conversion are performed only once.

        Possible operations are: Add packages, add drivers, set computer name,
        set administrator password, join a domain, enable debug, enable EMS and
        enable display of IP configuration information on boot.

    .PARAMETER MediaPath
        The location of the source media. If a local copy of the source media
        already exists, and it is specified as the base path, then no copying
        is performed.

    .PARAMETER BasePath
        The location for the copy of the source media.

    .PARAMETER TargetPath
        The location of the final, modified image.

    .PARAMETER ExistingVHDPath
        The location of an existing VHD image to use.

    .PARAMETER Language
        The language locale of the packages (i.e. en-us, fr-ca).

    .PARAMETER Storage
        Add the Storage package.

    .PARAMETER Compute
        Add the Compute (Hyper-V) package.

    .PARAMETER Clustering
        Add the Clustering package.

    .PARAMETER OEMDrivers
        Add the OEM Drivers package.

    .PARAMETER GuestDrivers
        Add the Guest Drivers package (enables integration of Nano Server
        with Hyper-V when running as a guest).

    .PARAMETER ReverseForwarders
        Adds the Reverse Forwarders package.

    .PARAMETER ExtraPackages
        Paths to extra packages to add to the image.

    .PARAMETER ComputerName
        Sets the computer name of the image.
	
	.PARAMETER AdministratorPassword
        Sets the administrator password of the image.

    .PARAMETER DomainName
        Joins the image to the specified domain performing an offline join. A
        domain blob is harvested from the local computer; if the local computer
        is not a member of the given domain, the command will fail.

    .PARAMETER DomainBlobPath
        Joins the image to the domain as specified in the given domain blob.

    .PARAMETER ReuseDomainNode
        When joining a domain, reuse a node with the same name if it exists.

    .PARAMETER DriversPath
        Path containing the drivers (.inf and binaries) to add to the image.
        If the drivers are not signed, the command will fail.

    .PARAMETER EnableIPDisplayOnBoot
        Configures the image to show the output of 'ipconfig' on every boot.

    .PARAMETER DebugMethod
        Enables kernel debugging on the target image with the specified method.
        Possible values are:
        1. Serial
        2. Net (KDNET)
        3. 1394 (FireWire)
        4. USB

        Depending on the value of this parameter, other parameters become
        available.
     
    .PARAMETER DebugCOMPort
        Specifies the serial port that kernel debugging is enabled on (only if
        DebugMethod is Serial). Default is 2.

    .PARAMETER DebugBaudRate
        The baud rate to use for kernel debugging. Default is 115200bps.

    .PARAMETER DebugRemoteIP
        Specifies the IP address of the computer running the debugger (only if
        DebugMethod is Net).

    .PARAMETER DebugPort
        Specifies the port that the computer running the debugger can use to
        connect to the host (only if DebugMethod is Net).

    .PARAMETER DebugChannel
        Specifies the channel that the computer running the debugger can use to
        connect to the host (only if DebugMethod is 1394).

    .PARAMETER DebugTargetName
        Specifies the target name that the computer running the debugger can
        use to connect to the host (only if DebugMethod is USB).

    .PARAMETER EnableEMS
        Enables EMS (Emergency Management Services) and BootEMS on the image.

    .PARAMETER EMSPort
        The port to enable EMS on. Default is 1.

    .PARAMETER EMSBaudRate
        The baud rate to use for EMS. Default is 115200bps.

    .PARAMETER EnableRemoteManagementPort
        Open port 5985 for inbound TCP connections for WinRM.

    .EXAMPLE
        New-NanoServerImage -MediaPath D:\ -BasePath .\Base -TargetPath '.\Target 1' -Compute -ComputerName "NANO" -DomainName "ContosoDomain" -EnableIPDisplayOnBoot

        This example will copy the necessary files from D:\ into .\Base. It
        will convert the Nano Server WIM image into a VHD file .\Base\Base.vhd.
        It will then copy that image into .\Target 1\Target 1.vhd and operate
        on it as follows:

        1. Add the Compute (Hyper-V) package;
        2. Set the computer name to 'NANO';
        3. Set the administrator password to 'Passw0rd';
        4. Perform an offline domain join of the machine to 'ContosoDomain';
        5. Enable the display of IP configuration information on boot.
#>
Function New-NanoServerImage
{
    [CmdletBinding()]
    Param
    (
        # Location of the source media.
        [Parameter()]
        [String]$MediaPath = "-",
        # Where to place the copy of the source media.
        [Parameter(Mandatory = $True)]
        [String]$BasePath,
        # Where to place the output files.
        [Parameter(Mandatory = $True)]
        [String]$TargetPath,

        # Location of the VHD to use.
        [Parameter()]
        [String]$ExistingVHDPath,

        # Language of the packages to include (i.e. en-us, fr-ca, etc.)
        [ValidateNotNullOrEmpty()]
        [String]$Language = [System.Globalization.CultureInfo]::CurrentCulture.Name.ToLower(),

        # Include the Storage package.
        [Switch]$Storage,
        # Include the Compute (Hyper-V) package.
        [Switch]$Compute,
        # Include the Failover Clustering package.
        [Switch]$Clustering,
        # Include the OEM Drivers package.
        [Switch]$OEMDrivers,
        # Include the Guest Drivers package.
        [Switch]$GuestDrivers,
        # Include the Reverse Forwarders package.
        [Switch]$ReverseForwarders,
        # List of paths to extra packages to include.
        [ValidateNotNullOrEmpty()]
        [String[]]$ExtraPackages,

        # Name to give to the target computer.
        [ValidateLength(1, 15)]
        [String]$ComputerName,
        # Password for the administrator account of the target computer.
        [Parameter(Mandatory = $True)]
        [SecureString]$AdministratorPassword,

        # Name of the domain.
        [ValidateNotNullOrEmpty()]
        [String]$DomainName,
        # Location of the domain blob.
        [ValidateNotNullOrEmpty()]
        [String]$DomainBlobPath,
        # Force reusing a node when joining a domain.
        [Switch]$ReuseDomainNode,

        # Location of additional drivers to include.
        [ValidateNotNullOrEmpty()]
        [String]$DriversPath,

        # Make Nano Server display its IP configuration on boot.
        [Switch]$EnableIPDisplayOnBoot,

        # Enable Debug and BootDebug in the target BCD.
        [ValidateSet("Serial", "Net", "1394", "USB")]
        [String]$DebugMethod,

        # Enable EMD and BootEMS in the target BCD.
        [Switch]$EnableEMS,
        # Port to use for EMS.
        [Parameter()]
        [Int]$EMSPort = 1,
        # Baud rate to use for EMS.
        [Parameter()]
        [Int]$EMSBaudRate = 115200,

        # Open port 5985 for inbound TCP connections for WinRM.
        [Switch]$EnableRemoteManagementPort
    )

    DynamicParam {
        $DynamicParameters = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        
        # If -DebugMethod is not set in the command line, $DebugMethod is
        # therefore undefined. However, if we are running in strict mode,
        # evaluating $DebugMethod in the switch will result in an error.
        try { [void]$DebugMethod }
        catch { $DebugMethod = [String]::Empty }

        switch($DebugMethod)
        {
            "Serial" {
                # Debug Port
                $DebugCOMPortParamAttr = New-Object System.Management.Automation.ParameterAttribute
                $DebugCOMPortParamAttr.ParameterSetName  = "__AllParameterSets"
                $DebugCOMPortParamAttr.Mandatory = $False

                $DebugCOMPortAttrCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
                $DebugCOMPortAttrCollection.Add($DebugCOMPortParamAttr)

                $DebugCOMPort = New-Object System.Management.Automation.RuntimeDefinedParameter("DebugCOMPort", [UInt16], $DebugCOMPortAttrCollection)
                $DebugCOMPort.Value = 2

                # Debug Baud Rate
                $DebugBaudRateParamAttr = New-Object System.Management.Automation.ParameterAttribute
                $DebugBaudRateParamAttr.ParameterSetName  = "__AllParameterSets"
                $DebugBaudRateParamAttr.Mandatory = $False

                $DebugBaudRateAttrCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
                $DebugBaudRateAttrCollection.Add($DebugBaudRateParamAttr)

                $DebugBaudRate = New-Object System.Management.Automation.RuntimeDefinedParameter("DebugBaudRate", [UInt16], $DebugBaudRateAttrCollection)
                $DebugBaudRate.Value = 115200

                # Collect
                $DynamicParameters.Add("DebugCOMPort", $DebugCOMPort)
                $DynamicParameters.Add("DebugBaudRate", $DebugBaudRate)
            }

            "Net" {
                # Remote IP
                $DebugRemoteIPParamAttr = New-Object System.Management.Automation.ParameterAttribute
                $DebugRemoteIPParamAttr.ParameterSetName  = "__AllParameterSets"
                $DebugRemoteIPParamAttr.Mandatory = $True

                $DebugRemoteIPParamNotNullAttr = New-Object System.Management.Automation.ValidateNotNullOrEmptyAttribute

                $DebugRemoteIPAttrCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
                $DebugRemoteIPAttrCollection.Add($DebugRemoteIPParamAttr)
                $DebugRemoteIPAttrCollection.Add($DebugRemoteIPParamNotNullAttr)

                $DebugRemoteIP = New-Object System.Management.Automation.RuntimeDefinedParameter("DebugRemoteIP", [String], $DebugRemoteIPAttrCollection)

                # Remote Port
                $DebugPortParamAttr = New-Object System.Management.Automation.ParameterAttribute
                $DebugPortParamAttr.ParameterSetName  = "__AllParameterSets"
                $DebugPortParamAttr.Mandatory = $True

                $DebugPortAttrCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
                $DebugPortAttrCollection.Add($DebugPortParamAttr)

                $DebugPort = New-Object System.Management.Automation.RuntimeDefinedParameter("DebugPort", [UInt16], $DebugPortAttrCollection)

                # Key
                $DebugKeyParamAttr = New-Object System.Management.Automation.ParameterAttribute
                $DebugKeyParamAttr.ParameterSetName  = "__AllParameterSets"
                $DebugKeyParamAttr.Mandatory = $False

                $DebugKeyParamNotNullAttr = New-Object System.Management.Automation.ValidateNotNullOrEmptyAttribute

                $DebugKeyAttrCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
                $DebugKeyAttrCollection.Add($DebugKeyParamAttr)
                $DebugKeyAttrCollection.Add($DebugKeyParamNotNullAttr)

                $DebugKey = New-Object System.Management.Automation.RuntimeDefinedParameter("DebugKey", [String], $DebugKeyAttrCollection)

                # Collect
                $DynamicParameters.Add("DebugRemoteIP", $DebugRemoteIP)
                $DynamicParameters.Add("DebugPort", $DebugPort)
                $DynamicParameters.Add("DebugKey", $DebugKey)
            }

            "1394" {
                # Channel
                $DebugChannelParamAttr = New-Object System.Management.Automation.ParameterAttribute
                $DebugChannelParamAttr.ParameterSetName  = "__AllParameterSets"
                $DebugChannelParamAttr.Mandatory = $True

                $DebugChannelAttrCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
                $DebugChannelAttrCollection.Add($DebugChannelParamAttr)

                $DebugChannel = New-Object System.Management.Automation.RuntimeDefinedParameter("DebugChannel", [UInt16], $DebugChannelAttrCollection)

                # Collect
                $DynamicParameters.Add("DebugChannel", $DebugChannel)
            }

            "USB" {
                # Target Name
                $DebugTargetNameParamAttr = New-Object System.Management.Automation.ParameterAttribute
                $DebugTargetNameParamAttr.ParameterSetName  = "__AllParameterSets"
                $DebugTargetNameParamAttr.Mandatory = $True

                $DebugTargetNameParamNotNullAttr = New-Object System.Management.Automation.ValidateNotNullOrEmptyAttribute

                $DebugTargetNameAttrCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
                $DebugTargetNameAttrCollection.Add($DebugTargetNameParamAttr)
                $DebugTargetNameAttrCollection.Add($DebugTargetNameParamNotNullAttr)

                $DebugTargetName = New-Object System.Management.Automation.RuntimeDefinedParameter("DebugTargetName", [String], $DebugTargetNameAttrCollection)

                # Collect
                $DynamicParameters.Add("DebugTargetName", $DebugTargetName)
            }
        }

        return $DynamicParameters
    }

    Process
    {
        # Checks
		$CurrentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
        if(!$CurrentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator))
		{
			Throw $Strings.ERR_USER_MUST_BE_ADMINISTRATOR
		}
		
        if($DomainName -and $DomainBlobPath)
        {
            Throw $Strings.ERR_INCLUDE_DOMAIN_NAME_OR_DOMAIN_BLOB_PATH
        }
        if($DomainBlobPath -and $ComputerName)
        {
            Throw $Strings.ERR_INCLUDE_COMPUTER_NAME_OR_DOMAIN_BLOB_PATH
        }
        if($DomainName -and !$ComputerName)
        {
            Throw ERR_DOMAIN_NAME_NO_COMPUTER_NAME
        }
        if(!$EnableEMS -and $PSBoundParameters.ContainsKey("EMSPort"))
        {
            Throw $Strings.ERR_EMS_PORT_WITH_NO_EMS
        }
        if($OEMDrivers -and $GuestDrivers)
        {
            Throw $String.ERR_INCLUDE_OEM_OR_GUEST_DRIVERS
        }
        if(($DebugMethod -eq "Serial") -and $EnableEMS -and ($DebugCOMPort.Value -eq $EMSPort))
        {
            Throw $Strings.ERR_DEBUG_AND_EMS_PORTS_EQUAL
        }
        if($ReuseDomainNode -and (!$DomainName -and !$DomainBlobPath))
        {
            Throw $Strings.ERR_REUSE_NODE_WITHOUT_JOIN
        }
        
        # Write out a header to make it easier to find distinct runs.
        Write-Log $LEVEL_NONE "========================================"
        Write-Log $LEVEL_NONE $Strings.LOG_HEADER
        Write-Log $LEVEL_NONE "========================================"

        # Tracking (used to handle Ctrl-C gracefully)
        $HasWorkFinished = $False
        $HasMountedImage = $False
        $HasExceptionOccurred = $False
        $HasCreatedPaths = $False

        # Phase 0
        $Packages = @();
        if($Storage) { $Packages += $PACK_STORAGE }
        if($Compute) { $Packages += $PACK_COMPUTE }
        if($Clustering) { $Packages += $PACK_CLUSTERING }
        if($OEMDrivers) { $Packages += $PACK_OEM_DRIVERS }
        if($GuestDrivers) { $Packages += $PACK_GUEST_DRIVERS }
        if($ReverseForwarders) { $Packages += $PACK_REVERSE_FORWARDERS }

        try
        {
            Initialize-PathValues $MediaPath $BasePath $TargetPath $DriversPath $DomainBlobPath $Language $Packages $ExistingVHDPath
            Test-Paths $Packages $ExtraPackages
            Initialize-Paths
            $HasCreatedPaths = $True

            # Phase 1
            Copy-Files
            Convert-Image
            Copy-Image

            # Phase 2
            Mount-Image
            $HasMountedImage = $True

            Add-Packages $Packages
            Add-ExtraPackages $ExtraPackages
            Add-Drivers

            # Phase 3
            Add-ServicingDescriptor $ComputerName $AdministratorPassword
            Join-Domain $DomainName $ReuseDomainNode

            # Phase 4
            if($DebugMethod)
            {
                $BCDPath = "$Script:TargetMountPath\boot\bcd"
                Enable-Debug $BCDPath

                switch($DebugMethod)
                {
                    "Serial" { Enable-DebugSerial $BCDPath $DebugCOMPort.Value $DebugBaudRate.Value }
                    "Net" { Enable-DebugNet $BCDPath $DebugRemoteIP.Value $DebugPort.Value $DebugKey.Value }
                    "1394" { Enable-DebugFirewire $BCDPath $DebugChannel.Value }
                    "USB" { Enable-DebugUSB $BCDPath $DebugTargetName.Value }
                }
            }
            if($EnableEMS)
            {
                Enable-EMS $BCDPath $EMSPort $EMSBaudRate
            }
            if($EnableIPDisplayOnBoot)
            {
                Write-SetupComplete $EnableRemoteManagementPort
            }

            # Done
            Dismount-Image

            Write-Log $LEVEL_OUTPUT ($Strings.MSG_DONE -f $LogFile) $True

            $HasWorkFinished = $True
        }
        catch
        {
            Write-Log $LEVEL_WARNING $_
            Write-Log $LEVEL_WARNING ($Strings.MSG_TERMINATING_DUE_TO_ERROR -f $Script:LogFile) $True

            if($HasMountedImage)
            {
                # The mount point is within $TargetPath, so we must dismount first.
                Dismount-Image -Discard
            }
            if($HasCreatedPaths)
            {
                Remove-Item $TargetPath -Recurse -Force
            }

            $HasExceptionOccurred = $True
        }
        finally
        {
            if($HasWorkFinished)
            {
                # All good.
                Remove-Item $Script:TargetPath\* -Exclude *.vhd, $KERNEL_DEBUG_KEY_FILE
            }
            elseif(!$HasExceptionOccurred)
            {
                if($HasMountedImage)
                {
                    # Ctrl-C was pressed and the Finally block is not running after
                    # catching an exception.
                    Dismount-Image -Discard
                }

                if($HasCreatedPaths)
                {
                    Remove-Item $TargetPath -Recurse -Force
                }

                Write-Log $LEVEL_WARNING $Strings.MSG_TERMINATING_DUE_TO_CTRL_C $True
            }
        }
    }
}

### -----------------------------------
### Phase 0
### -----------------------------------

Function Initialize-PathValues([String]$MediaPath, [String]$BasePath, [String]$TargetPath, [String]$DriversPath, [String]$DomainBlobPath, [String]$Language, [String[]]$Packages, [String]$ExistingVHDPath)
{
    Write-Verbose $Strings.MSG_COMPUTING_PATHS

    # Compute the directory structure.
    # --------------------------------

    # Source
	$Script:HasMediaPath = !($MediaPath -eq "-")
    $Script:NanoPath = Join-Path $MediaPath "NanoServer"
    $Script:PackagesPath = Join-Path $NanoPath "Packages"
    $Script:LanguagePackagesPath = Join-Path $PackagesPath $Language

    $Script:SourcesPath = Join-Path $MediaPath "sources"

    # Base
    $Script:BasePath = $BasePath
    $Script:BaseToolsPath = Join-Path $BasePath "Tools"
    $Script:BasePackagesPath = Join-Path $BasePath "Packages"
    $Script:BaseLanguagePackagesPath = Join-Path $Script:BasePackagesPath $Language
    $Script:BaseImageHashFilePath = Join-Path $Script:BasePath $IMAGE_HASH_FILE

    # Existing VHD
    $Script:UseExistingVHD = !([String]::IsNullOrEmpty($ExistingVHDPath))
    
    # Target
    $Script:TargetPath = $TargetPath

    # Drivers
    $Script:DriversPath = $DriversPath

    # Domain
    $Script:DomainBlobPath = $DomainBlobPath

    # Compute the file paths.
    # -----------------------

    # Source
    $Script:ImageFilePath = Join-Path $Script:NanoPath $IMAGE_NAME;
    $Script:ImageConverterPath = Join-Path $PSScriptRoot $IMAGE_CONVERTER

    $Script:PackageFilePaths = @{}
    $Script:LanguagePackageFilePaths = @{}

    $Packages | ForEach-Object { $Script:PackageFilePaths.Add($_, (Join-Path $Script:PackagesPath $_)) }
    $Packages | ForEach-Object { $Script:LanguagePackageFilePaths.Add($_, (Join-Path $Script:LanguagePackagesPath $_)) }

    # Base
    $Script:BaseImageFilePath = Join-Path $BasePath $IMAGE_NAME
    $Script:BaseDismFilePath = Join-Path $Script:BaseToolsPath dism

    $Script:BasePackageFilePaths = @{}
    $Script:BaseLanguagePackageFilePaths = @{}

    $Packages | ForEach-Object { $Script:BasePackageFilePaths.Add($_, (Join-Path $Script:BasePackagesPath $_)) }
    $Packages | ForEach-Object { $Script:BaseLanguagePackageFilePaths.Add($_, (Join-Path $Script:BaseLanguagePackagesPath $_)) }

    # Existing VHD
    if($Script:UseExistingVHD)
    {
        $Script:BaseVHDImageFilePath = $ExistingVHDPath
    }
    else
    {
        $Script:BaseVHDImageFilePath = Join-Path $BasePath ((Split-Path $BasePath -Leaf) + ".vhd")
    }

    # Target
    $Script:TargetMountPath = Join-Path $TargetPath "Mount"
    $Script:TargetUnattendFilePath = Join-Path $TargetPath "Unattend.xml"
    $Script:TargetVHDImageFilePath = Join-Path $TargetPath ((Split-Path $TargetPath -Leaf) + ".vhd")
    $Script:TargetDomainBlobPath = Join-Path $TargetPath "djoin.blob"
    $Script:TargetSetupCompleteFilePath = Join-Path $TargetPath "SetupComplete.cmd"
    $Script:TargetDebuggingKeyFilePath = Join-Path $TargetPath $KERNEL_DEBUG_KEY_FILE
}

Function Test-Paths([String[]]$Packages, [String[]]$ExtraPackages)
{
    Write-Verbose $Strings.MSG_CHECKING_PATHS

	if($Script:HasMediaPath)
	{
		# Check media directory structure.
		if(!(Test-Path $Script:NanoPath))
		{
			Throw ($Strings.ERR_DIRECTORY_DOES_NOT_EXIST_IN_MEDIA_DIRECTORY -f "NanoServer")
		}
		if(!(Test-Path $Script:PackagesPath))
		{
			Throw ($Strings.ERR_DIRECTORY_DOES_NOT_EXIST_IN_DIRECTORY -f "Packages", "NanoServer", $Script:NanoPath)
		}
		if(!(Test-Path $Script:LanguagePackagesPath))
		{
			Throw ($Strings.ERR_DIRECTORY_DOES_NOT_EXIST_IN_DIRECTORY -f $Language, "Packages", $Script:PackagesPath)
		}

		if(!(Test-Path $Script:SourcesPath))
		{
			Throw ($Strings.ERR_DIRECTORY_DOES_NOT_EXIST_IN_MEDIA_DIRECTORY -f "Sources")
		}
		
		# Check that the Nano Server image is present in the media path.
		if(!$Script:UseExistingVHD -and !(Test-Path $Script:ImageFilePath))
		{
			Throw ($Strings.ERR_IMAGE_DOES_NOT_EXIST -f $IMAGE_NAME)
		}
	}
	else
	{
		# Check base directory structure.
		if(!(Test-Path $Script:BasePath))
		{
			Throw $Strings.ERR_BASE_DIRECTORY_DOES_NOT_EXIST
		}
		if(!(Test-Path $Script:BaseToolsPath))
		{
			Throw ($Strings.ERR_DIRECTORY_DOES_NOT_EXIST_IN_BASE_DIRECTORY -f "Tools")
		}
		if(!(Test-Path $Script:BasePackagesPath))
		{
			Throw ($Strings.ERR_DIRECTORY_DOES_NOT_EXIST_IN_BASE_DIRECTORY -f "Packages")
		}

		if(!(Test-Path $Script:BaseLanguagePackagesPath))
		{
			Write-Output ($Strings.ERR_DIRECTORY_DOES_NOT_EXIST_IN_DIRECTORY -f $Language, "Packages", $Script:BasePackagesPath)
		}
		
		# Check that the Nano Server image is present in the base path.
		if(!$Script:UseExistingVHD -and !(Test-Path $Script:BaseImageFilePath))
		{
			Throw ($Strings.ERR_IMAGE_DOES_NOT_EXIST_IN_BASE_DIRECTORY -f $IMAGE_NAME)
		}
	}

    # Check that the existing VHD actually exists
    if($Script:UseExistingVHD -and !(Test-Path $Script:BaseVHDImageFilePath))
    {
		Throw $Strings.ERR_SPECIFIED_VHD_IMAGE_DOES_NOT_EXIST
    }

    # Check that the given drivers path exists.
    if($Script:DriversPath -and !(Test-Path $Script:DriversPath))
    {
		Throw ($Strings.ERR_DRIVERS_DIRECTORY_DOES_NOT_EXIST -f $Script:DriversPath)
    }

    # Check if the target path already exists.
    if(Test-Path $Script:TargetPath)
    {
        Throw $Strings.ERR_TARGET_DIRECTORY_ALREADY_EXISTS
    }

    # Check that the image converter script is present.
    if(!$Script:UseExistingVHD -and !(Test-Path $Script:ImageConverterPath))
    {
		Throw $Strings.ERR_IMAGE_CONVERTER_SCRIPT_DOES_NOT_EXIST
    }

	if($Script:HasMediaPath)
	{
		# Check that the files for the requested packages are present in the media directory.
		$PackagesNotFound = $Script:PackageFilePaths.GetEnumerator() | Where-Object { ($Packages.Contains($_.Key) -and !(Test-Path $_.Value)) }
		$LanguagePackagesNotFound = $Script:LanguagePackageFilePaths.GetEnumerator() | Where-Object { ($Packages.Contains($_.Key) -and !(Test-Path $_.Value)) }
	}
	else
	{
		# Check that the files for the requested packages are present in the base directory.
		$PackagesNotFound = $Script:BasePackageFilePaths.GetEnumerator() | Where-Object { ($Packages.Contains($_.Key) -and !(Test-Path $_.Value)) }
		$LanguagePackagesNotFound = $Script:BaseLanguagePackageFilePaths.GetEnumerator() | Where-Object { ($Packages.Contains($_.Key) -and !(Test-Path $_.Value)) }
	}
	
	if($PackagesNotFound)
	{
		$PackagesNotFound | ForEach-Object { Write-Log $LEVEL_WARNING ($Strings.ERR_PACKAGE_DOES_NOT_EXIST -f $_.Value) }
	}
	if($LanguagePackagesNotFound)
	{
		$LanguagePackagesNotFound | ForEach-Object { Write-Log $LEVEL_WARNING ($Strings.ERR_LANGUAGE_PACKAGE_DOES_NOT_EXIST -f $_.Value) }
	}

	if($PackagesNotFound -or $LanguagePackagesNotFound)
	{
		Throw $Strings.ERR_ONE_OR_MORE_PACKAGES_DO_NOT_EXIST
	}
	
    # Check that the paths to the extra packages exist.
    if($ExtraPackages)
    {
        $ExtraPackagesNotFound = $ExtraPackages.GetEnumerator() | Where-Object { !(Test-Path $_) }

        if($ExtraPackagesNotFound)
        {
		    $ExtraPackagesNotFound | ForEach-Object { Write-Log $LEVEL_WARNING ($Strings.ERR_EXTRA_PACKAGE_DOES_NOT_EXIST -f $_) }
        }

        if($ExtraPackagesNotFound)
        {
            Throw $Strings.ERR_ONE_OR_MORE_EXTRA_PACKAGES_DO_NOT_EXIST
        }
    }

    # Check that the specified domain blob path exists.
    if($Script:DomainBlobPath -and !(Test-Path $Script:DomainBlobPath))
    {
        Throw $Strings.ERR_DOMAIN_BLOB_DOES_NOT_EXIST
    }
}

Function Initialize-Paths()
{
    Write-Verbose $Strings.MSG_CREATING_PATHS

    New-Item -ItemType Directory -Force -Path $Script:TargetPath | Write-Verbose
    New-Item -ItemType Directory -Force -Path $Script:TargetMountPath  | Write-Verbose
    
    New-Item -ItemType Directory -Force -Path $Script:BasePath | Write-Verbose
    New-Item -ItemType Directory -Force -Path $Script:BaseToolsPath | Write-Verbose
    New-Item -ItemType Directory -Force -Path $Script:BasePackagesPath | Write-Verbose
    New-Item -ItemType Directory -Force -Path $Script:BaseLanguagePackagesPath | Write-Verbose
}

### -----------------------------------
### Phase 1
### -----------------------------------

Function Copy-Files()
{
	if(!$Script:HasMediaPath)
	{
		Write-Verbose $Strings.MSG_SKIPPING_FILE_COPY
	
		return
	}

    Write-Verbose $Strings.MSG_COPYING_FILES
    Write-Progress $Strings.MSG_COPYING_FILES

    # Copy the tools (exclude the large, unnecessary WIM's in that folder).
    Copy-Item $Script:SourcesPath\* $Script:BaseToolsPath -Exclude *.wim -Force

    # Copy the image
    Copy-Item $Script:ImageFilePath $Script:BasePath -Force

    # Copy the packages
    Copy-Item $Script:PackagesPath\*.cab $Script:BasePackagesPath -Force
    Copy-Item $Script:LanguagePackagesPath\*.cab $Script:BaseLanguagePackagesPath -Force

    # Compute and store the hash of the WIM. If the image we just copied from
    # the source media is different from the one for which we had possibly
    # generated a VHD previously, convert it again despite the VHD already
    # being there.
    $ImageHash = (Get-FileHash -Path $Script:ImageFilePath -Algorithm SHA1).Hash
    if(Test-Path $Script:BaseImageHashFilePath)
    {
        $ExistingHash = Get-Content $Script:BaseImageHashFilePath
        $Script:ForceConvertImage = $ImageHash -ne $ExistingHash

        $ImageHash > $Script:BaseImageHashFilePath
    }
    else
    {
        $ImageHash > $Script:BaseImageHashFilePath
        $Script:ForceConvertImage = $False
    }
}

Function Convert-Image()
{
    # Do not convert if the image is already present or we have an existing
    # VHD.
    if($Script:UseExistingVHD -or ((Test-Path $Script:BaseVHDImageFilePath) -and !$Script:ForceConvertImage))
    {
        Write-Verbose $Strings.MSG_SKIPPING_IMAGE_CONVERSION

        return
    }
    
    Write-Verbose $Strings.MSG_CONVERTING_IMAGE
    Write-Progress $Strings.MSG_CONVERTING_IMAGE

    . .\Convert-WindowsImage.ps1
	Convert-WindowsImage -SourcePath $Script:BaseImageFilePath -VHD $Script:BaseVHDImageFilePath –VHDformat VHD -EnableDebugger None -Edition "CORESYSTEMSERVER_INSTALL" -VHDPartitionStyle MBR
}

Function Copy-Image()
{
    Write-Verbose $Strings.MSG_COPYING_IMAGE
    Write-Progress $Strings.MSG_COPYING_IMAGE

    Copy-Item $Script:BaseVHDImageFilePath $Script:TargetVHDImageFilePath
}

### -----------------------------------
### Phase 2
### -----------------------------------

Function Add-Packages([String[]]$Packages)
{
    if(!$Packages)
    {
        Write-Verbose $Strings.MSG_SKIPPING_PACKAGE_ADDITION
        
        return
    }

    Write-Verbose $Strings.MSG_ADDING_PACKAGES
    Write-Progress $Strings.MSG_ADDING_PACKAGES

    $Packages | ForEach-Object { Add-Package $Script:BasePackageFilePaths[$_] $False }
    $Packages | ForEach-Object { Add-Package $Script:BaseLanguagePackageFilePaths[$_] $True }
}

Function Add-ExtraPackages([String[]]$ExtraPackages)
{
    if(!$ExtraPackages)
    {
        Write-Verbose $Strings.MSG_SKIPPING_EXTRA_PACKAGES_ADDITION

        return
    }

    Write-Verbose $Strings.MSG_ADDING_EXTRA_PACKAGES
    Write-Progress $Strings.MSG_ADDING_EXTRA_PACKAGES

    $ExtraPackages | ForEach-Object { Add-Package $_ $False }
}

Function Add-Package([String]$PackageFilePath, [Bool]$IsLanguage)
{
    if($IsLanguage)
    {        
        $Message = $Strings.MSG_ADDING_LANGUAGE_PACKAGE -f (Split-Path $PackageFilePath -Leaf)
    }
    else
    {
        $Message = $Strings.MSG_ADDING_PACKAGE -f (Split-Path $PackageFilePath -Leaf)
    }

    Write-Progress -Id 1 -Activity $Message

    Invoke-ExternalCommand "& '$Script:BaseDismFilePath' /Add-Package /PackagePath:'$PackageFilePath' /Image:'$Script:TargetMountPath' /LogLevel:2 /LogPath:'$Script:DismLogFile'"

    Write-Progress -Id 1 -Activity $Message -Completed
}

Function Add-Drivers()
{
    if(!$Script:DriversPath)
    {
        Write-Verbose $Strings.MSG_SKIPPING_DRIVER_ADDITION

        return
    }

    Write-Verbose $Strings.MSG_ADDING_DRIVERS
    Write-Progress $Strings.MSG_ADDING_DRIVERS

    Invoke-ExternalCommand "& '$Script:BaseDismFilePath' /Add-Driver /Driver:'$Script:DriversPath' /Recurse /Image:'$Script:TargetMountPath' /LogLevel:2 /LogPath:'$Script:DismLogFile'"
}

### -----------------------------------
### Phase 3
### -----------------------------------

Function Add-ServicingDescriptor([String]$ComputerName, [SecureString]$AdministratorPassword)
{
    Write-Verbose $Strings.MSG_ADDING_UNATTEND
    Write-Progress $Strings.MSG_ADDING_UNATTEND

    $PointerToPasswordString = [System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode($AdministratorPassword)
    $ManagedPasswordString = [System.Runtime.InteropServices.Marshal]::PtrToStringUni($PointerToPasswordString)
    [System.Runtime.InteropServices.Marshal]::ZeroFreeCoTaskMemUnicode($PointerToPasswordString)

    # Write out the unattend.
    Write-Xml $ComputerName $ManagedPasswordString

    # Embed the descriptor into the image.
    Invoke-ExternalCommand "& '$Script:BaseDismFilePath' /Image:'$Script:TargetMountPath' /Apply-Unattend:'$Script:TargetUnattendFilePath' /LogLevel:2 /LogPath:'$Script:DismLogFile'"

    # Copy the unattend over.
    New-Item -ItemType Directory -Force -Path $Script:TargetMountPath\Windows\Panther | Out-Null
    Copy-Item $Script:TargetUnattendFilePath $Script:TargetMountPath\Windows\Panther -Force
}

Function Write-Xml([String]$ComputerName, [String]$AdministratorPassword)
{
    $Xml = New-Object Xml
    $XmlNs = "urn:schemas-microsoft-com:unattend"
    
    $XmlDecl = $Xml.CreateXmlDeclaration("1.0", "utf-8", $Null)
    $XmlRoot = $Xml.DocumentElement
    $Xml.InsertBefore($XmlDecl, $XmlRoot) | Out-Null;

    $XmlUnattended = $Xml.CreateElement("unattend", $XmlNs)
    $XmlUnattended.SetAttribute("xmlns:wcm", "http://schemas.microsoft.com/WMIConfig/2002/State")
    $XmlUnattended.SetAttribute("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance")
    $Xml.AppendChild($XmlUnattended) | Out-Null;

    Write-AdministratorPasswordXml $Xml $XmlNs $XmlUnattended $AdministratorPassword

    if($ComputerName)
    {
        Write-ComputerNameXml $Xml $XmlNs $XmlUnattended $ComputerName
    }
    
    # Normal .NET methods are unaware of the PowerShell context. In this case,
    # the path to save the XML to is relative. While PowerShell would resolve
    # it as we would expect, the .NET method will do so relative to its working
    # directory, which is not necessarily the same as PowerShell's. So, we need
    # to expand the relative path manually.
    if([System.IO.Path]::IsPathRooted($Script:TargetUnattendFilePath))
    {
        $Xml.Save([System.IO.Path]::GetFullPath($Script:TargetUnattendFilePath))
    }
    else
    {
        $Xml.Save([System.IO.Path]::GetFullPath((Join-Path (pwd) $Script:TargetUnattendFilePath)))
    }
}

Function Write-ComputerNameXml([Xml]$Xml, [String]$XmlNs, [System.Xml.XmlElement]$XmlUnattended, [String]$ComputerName)
{
    $XmlSettings = $Xml.CreateElement("settings", $XmlNs)
    $XmlSettings.SetAttribute("pass", "offlineServicing")
    $XmlUnattended.AppendChild($XmlSettings) | Out-Null

    $XmlComponent = $Xml.CreateElement("component", $XmlNs)
    $XmlComponent.SetAttribute("name", "Microsoft-Windows-Shell-Setup")
    $XmlComponent.SetAttribute("processorArchitecture", "amd64")
    $XmlComponent.SetAttribute("publicKeyToken", "31bf3856ad364e35")
    $XmlComponent.SetAttribute("language", "neutral")
    $XmlComponent.SetAttribute("versionScope", "nonSxS")
    $XmlSettings.AppendChild($XmlComponent) | Out-Null

    $XmlComputerName = $Xml.CreateElement("ComputerName", $XmlNs)
    $XmlName = $Xml.CreateTextNode($ComputerName)
    $XmlComputerName.AppendChild($XmlName) | Out-Null
    $XmlComponent.AppendChild($XmlComputerName) | Out-Null
}

Function Write-AdministratorPasswordXml([Xml]$Xml, [String]$XmlNs, [System.Xml.XmlElement]$XmlUnattended, [String]$AdministratorPassword)
{
    $XmlSettings = $Xml.CreateElement("settings", $XmlNs)
    $XmlSettings.SetAttribute("pass", "oobeSystem")
    $XmlUnattended.AppendChild($XmlSettings) | Out-Null

    $XmlComponent = $Xml.CreateElement("component", $XmlNs)
    $XmlComponent.SetAttribute("name", "Microsoft-Windows-Shell-Setup")
    $XmlComponent.SetAttribute("processorArchitecture", "amd64")
    $XmlComponent.SetAttribute("publicKeyToken", "31bf3856ad364e35")
    $XmlComponent.SetAttribute("language", "neutral")
    $XmlComponent.SetAttribute("versionScope", "nonSxS")
    $XmlSettings.AppendChild($XmlComponent) | Out-Null

    $XmlUserAccounts = $Xml.CreateElement("UserAccounts", $XmlNs)
    $XmlComponent.AppendChild($XmlUserAccounts) | Out-Null

    $XmlAdministratorPassword = $Xml.CreateElement("AdministratorPassword", $XmlNs)
    $XmlUserAccounts.AppendChild($XmlAdministratorPassword) | Out-Null

    $XmlValue = $Xml.CreateElement("Value", $XmlNs)
    $XmlComputerName = $Xml.CreateTextNode($AdministratorPassword)
    $XmlValue.AppendChild($XmlComputerName) | Out-Null
    $XmlAdministratorPassword.AppendChild($XmlValue) | Out-Null

    $XmlPlainText = $Xml.CreateElement("PlainText", $XmlNs)
    $XmlPassword = $Xml.CreateTextNode("true")
    $XmlPlainText.AppendChild($XmlPassword) | Out-Null
    $XmlAdministratorPassword.AppendChild($XmlPlainText) | Out-Null
}

Function Join-Domain([String]$DomainName, [Bool]$ReuseDomainNode)
{
    # If the target image must join a domain, but a blob was not provided, one
    # must be harvested from the local machine.
    if($DomainName -and !$Script:DomainBlobPath)
    {
        Write-Verbose $Strings.MSG_COLLECTING_DOMAIN_BLOB

        $Command = "djoin /Provision /Domain $DomainName /Machine $ComputerName /SaveFile '$Script:TargetDomainBlobPath'"
        if($ReuseDomainNode)
        {
            $Command += " /Reuse"
        }

        Invoke-ExternalCommand $Command

        $Script:DomainBlobPath = $Script:TargetDomainBlobPath
    }

    if($Script:DomainBlobPath)
    {
		Write-Verbose $Strings.MSG_JOINING_DOMAIN

        Invoke-ExternalCommand "djoin /RequestODJ /LoadFile '$Script:DomainBlobPath' /WindowsPath '$Script:TargetMountPath\Windows'"
    }
}

### -----------------------------------
### Phase 4
### -----------------------------------

Function Enable-Debug([String]$BCDPath)
{
    Write-Verbose $Strings.MSG_ENABLING_DEBUG
    Write-Progress $Strings.MSG_ENABLING_DEBUG
 
    Invoke-ExternalCommand("bcdedit /Store '$BCDPath' /BootDebug ``{bootmgr``} ON")
    Invoke-ExternalCommand("bcdedit /Store '$BCDPath' /BootDebug ``{default``} ON")
    Invoke-ExternalCommand("bcdedit /Store '$BCDPath' /Debug ``{default``} ON")
}

Function Enable-DebugSerial([String]$BCDPath, [Int]$Port, [Int]$BaudRate)
{
    Invoke-ExternalCommand("bcdedit /Store '$BCDPath' /DBGSettings SERIAL DEBUGPORT:$Port BAUDRATE:$BaudRate")
}

Function Enable-DebugNet([String]$BCDPath, [String]$RemoteIP, [String]$RemotePort, [String]$Key)
{
    $Command = "bcdedit /Store '$BCDPath' /DBGSettings NET HOSTIP:$RemoteIP PORT:$RemotePort"
    if($Key)
    {
        $Command += " KEY:$Key"
    }

    Invoke-ExternalCommand("$Command > '$Script:TargetDebuggingKeyFilePath'")
    
    Write-Log $LEVEL_OUTPUT ($Strings.MSG_KERNEL_DEBUG_KEY_FILE -f $Script:TargetDebuggingKeyFilePath)
}

Function Enable-DebugFirewire([String]$BCDPath, [Int]$Channel)
{
    Invoke-ExternalCommand("bcdedit /Store '$BCDPath' /DBGSettings 1394 Channel:$Channel")
}

Function Enable-DebugUSB([String]$BCDPath, [String]$TargetName)
{
    Invoke-ExternalCommand("bcdedit /Store '$BCDPath' /DBGSettings USB TargetName:$TargetName")
}

Function Enable-EMS([String]$BCDPath, [Int]$Port, [Int]$BaudRate)
{
    Write-Verbose $Strings.MSG_ENABLING_EMS
    Write-Progress $Strings.MSG_ENABLING_EMS

    Invoke-ExternalCommand("bcdedit /Store '$BCDPath' /EMS ``{default``} ON")
    Invoke-ExternalCommand("bcdedit /Store '$BCDPath' /EMSSettings EMSPORT:$Port EMSBAUDRATE:$BaudRate")
    Invoke-ExternalCommand("bcdedit /Store '$BCDPath' /BootEMS ``{default``} ON")
    Invoke-ExternalCommand("bcdedit /Store '$BCDPath' /BootEMS ``{bootmgr``} ON")
}

Function Write-SetupComplete([Bool]$OpenPort)
{
    Write-Verbose $Strings.MSG_ENABLING_IP_DISPLAY
    Write-Progress $Strings.MSG_ENABLING_IP_DISPLAY

    New-Item -ItemType Directory -Force -Path "$Script:TargetMountPath\Windows\Setup\Scripts" | Out-Null

    # To populate the batch file, the > and >> operators cannot be used. The
    # resulting file must be encoded in ASCII.
    $SetupCompleteCommand = "@ECHO OFF`n"
    if($OpenPort)
    {
        $SetupCompleteCommand += "netsh advfirewall firewall add rule name=`"WinRM 5985`" protocol=TCP dir=in localport=5985 action=allow`n"
    }
    $SetupCompleteCommand += "schtasks /Create /TN IPBootDisplay /SC ONSTART /RU SYSTEM /Delay 0000:30 /TR ipconfig > nul`nping localhost -n 30 > nul 2>&1`nipconfig"
    Set-Content -Value $SetupCompleteCommand -Path "$Script:TargetSetupCompleteFilePath" -Encoding ASCII
    
    Copy-Item $Script:TargetSetupCompleteFilePath "$Script:TargetMountPath\Windows\Setup\Scripts" -Force
}

### -----------------------------------
### Helper Methods
### -----------------------------------

Function Mount-Image()
{
    Write-Verbose $Strings.MSG_MOUNTING_IMAGE
    Write-Progress $Strings.MSG_MOUNTING_IMAGE

    Invoke-ExternalCommand "& '$Script:BaseDismFilePath' /Mount-Image /ImageFile:'$Script:TargetVHDImageFilePath' /MountDir:'$Script:TargetMountPath' -Index:1 /LogLevel:2 /LogPath:'$Script:DismLogFile'"
}

Function Dismount-Image([Switch]$Discard)
{
    Write-Verbose $Strings.MSG_DISMOUNTING_IMAGE
    Write-Progress $Strings.MSG_DISMOUNTING_IMAGE

    if($Discard)
    {
        Invoke-ExternalCommand "& '$Script:BaseDismFilePath' /Unmount-Image /MountDir:'$Script:TargetMountPath' /Discard /LogLevel:2 /LogPath:'$Script:DismLogFile'"
    }
    else
    {
        Invoke-ExternalCommand "& '$Script:BaseDismFilePath' /Unmount-Image /MountDir:'$Script:TargetMountPath' /Commit /LogLevel:2 /LogPath:'$Script:DismLogFile'"
    }
}

Function Invoke-ExternalCommand([String]$Command)
{
    Write-Log $LEVEL_VERBOSE $Command
    $Output = (Invoke-Expression ("{0} 2>&1" -f $Command)  | Out-String)

    if($LastExitCode)
    {
        Write-Log $LEVEL_NONE $Output -Verbose

        Throw($Strings.ERR_EXTERNAL_CMD -f $LastExitCode)
   }
}

Function Write-Log([String]$Level, [String]$Message, [Bool]$AppendNewLine = $False)
{
    switch($Level)
    {
        { $_ -eq $LEVEL_WARNING } { Write-Warning $Message }
        { $_ -eq $LEVEL_VERBOSE } { Write-Verbose $Message }
        { $_ -eq $LEVEL_OUTPUT } { Write-Output $Message }
    }

    if($AppendNewLine)
    {
        $Message += "`n"
    }
    Write-Output "$(Get-Date) $Message" | Out-File -FilePath $Script:LogFile -Append
}
