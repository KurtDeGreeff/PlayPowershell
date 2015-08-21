function Get-HPHardwareInfo {
    <#
        .SYNOPSIS
            Get hardware information from HP computers.
        .DESCRIPTION
            This function uses CIM to query the root\hpq WMI namespace for hardware information. This namespace is HP specific
            and needs to be installed to be able to use this function. If you are missing root\hpq, try intalling HP WBEM.
        .EXAMPLE
            Get-HPHardwareInfo Computer01
            Will get hardware information from Computer01
        .OUTPUTS
            PSObject
        .NOTES
            Author: Øyvind Kallstad
            Date: 08.12.2014
            Version: 1.1
    #>
    [CmdletBinding()]
    param (
        # Specifies the target computer. Enter a fully qualified domain name, NetBIOS name, or an IP address. When the remote computer is in a different domain than the local computer,
        # the fully qualified domain name is required.
        [Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullorEmpty()]
        [string[]] $ComputerName = $env:COMPUTERNAME,
 
        # Specifies a user account that has permission to perform this action. 
        [Parameter()]
        [System.Management.Automation.Credential()] $Credential = [System.Management.Automation.PSCredential]::Empty,
 
        # Use this parameter to force the creation of a new CIM session. The default behaviour is to save the session and reuse it if possible.
        [Parameter()]
        [switch] $ForceNewCimSession
    )
   
    process {
        foreach ($computer in $ComputerName) {
            try {
            
                # define hashtable for Test-WSMan properties
                $wsmanProperties = @{
                    ComputerName = $computer
                    ErrorAction  = 'SilentlyContinue'
                }
                if ($PSBoundParameters['Credential']){
                    $wsmanProperties.Authentication = 'Basic'
                    $wsmanProperties.Credential = $Credential
                }
                
                # check if wsman is responding
                $wsmanTest = Test-WSMan @wsmanProperties
 
                # based on whether the result of the wsman test, we decide on the protocol to use for the cim session
                if (-not([string]::IsNullOrEmpty($wsmanTest))) {
                    $cimSessionOption = New-CimSessionOption -Protocol Wsman
                    Write-Verbose 'Using protocol "Wsman"'
                }
 
                else {
                    $cimSessionOption = New-CimSessionOption -Protocol Dcom
                    Write-Verbose 'Using protocol "Dcom"'
                }
 
                # define hashtable for cim session properties
                $cimSessionProperties = @{
                    Name          = $computer
                    ComputerName  = $computer
                    SessionOption = $cimSessionOption
                    Verbose       = $false
                    ErrorAction   = 'Stop'
                }
                if ($PSBoundParameters['Credential']){ $cimSessionProperties.Credential = $Credential}
                                
                # first check to see if a cim session already exist, if so use this - if not, we create a new one
                # if -ForceNewCimSession is used, always create a new cim session
                if ((-not($cimSession = Get-CimSession -Name $computer -ErrorAction SilentlyContinue)) -or ($ForceNewCimSession)) {
                    Write-Verbose 'Creating new CIM session'
                    $cimSession = New-CimSession @cimSessionProperties -SkipTestConnection
                } else { Write-Verbose 'Using existing CIM session' }
 
                # check that root\hpq is present on the target system
                $wmiHPQ = Get-CimInstance -CimSession $cimSession -Namespace 'root' -ClassName '__NAMESPACE' -Filter "Name='hpq'" -Verbose:$false
                Write-Verbose 'root\hpq found - we are ready to go'
 
                if($wmiHPQ) {
 
                    $cimParametersCommon = @{
                        CimSession = $cimSession
                        Namespace  = 'root\hpq'
                        Verbose    = $false
                    }
 
                    # define our data gathering queries
                    $queryIndex = 0
                    $wmiQueries = @{
                        'HP_ComputerSystem'        = 'SELECT LocationIndicator,HealthState FROM HP_WinComputerSystem'
                        'HP_ComputerSystemChassis' = 'SELECT SerialNumber,ProductID FROM HP_ComputerSystemChassis'
                        'HP_ManagementProcessor'   = 'SELECT Name,IPAddress,ActiveLicense,LicenseKey FROM HP_ManagementProcessor'
                        'HP_MPFirmware'            = 'SELECT VersionString FROM HP_MPFirmware'
                        'HP_BladeEnclosureCS'      = 'SELECT Name FROM HP_BladeEnclosureCS'
                        'HP_BladeCSLocation'       = 'SELECT PhysicalPosition FROM HP_BladeCSLocation'
                        'HP_Processor'             = 'SELECT DeviceID,AddressWidth,DataWidth,MaxClockSpeed,CurrentClockSpeed,ExternalBusClockSpeed,Name,Description,CPUStatus,NumberOfEnabledCores,Family,HealthState FROM HP_Processor'
                        'HP_MemoryModule'          = 'SELECT Name,Capacity,MaxMemorySpeed,IsSpeedInMhz,HealthState,DataWidth,TotalWidth,InterleavePosition FROM HP_MemoryModule'
                        'HPSA_ArraySystem'         = 'SELECT Name,ElementName FROM HPSA_ArraySystem'
                        'HPSA_DiskDrive'           = 'SELECT DeviceID,Name,SystemName,ElementName,Description,DriveRotationalSpeed,TotalPowerOnHours,OperationalStatus FROM HPSA_DiskDrive'
                        'HPSA_StorageVolume'       = 'SELECT DeviceID,Name,ElementName,OSName,BlockSize,StripeSize,FaultTolerance,ExtentStatus FROM HPSA_StorageVolume'
                        'HPFCHBA_PhysicalPackage'  = 'SELECT ElementName,Manufacturer,Model,Name,OtherIdentifyingInfo,OperationalStatus,SerialNumber,Tag FROM HPFCHBA_PhysicalPackage'
                        'HP_SystemROMFirmware'     = 'SELECT Name,ElementName,VersionString FROM HP_SystemROMFirmware'
                        'HP_SoftwareIdentity'      = 'SELECT Caption,ElementName,VersionString,Description FROM HP_SoftwareIdentity'
                        'HP_EthernetTeam'          = 'SELECT MinNumberNeeded,MaxNumberSupported,ActiveMaximumTransmissionUnit,LoadBalanceAlgorithm,RedundancyStatus,GroupOperationalStatus,TeamOperatingMode,VendorIdentifyingInfo,Caption,Description,OtherLoadBalanceAlgorithm,Speed FROM HP_EthernetTeam'
                    }
 
                    # run queries to gather data from target computer (see http://h20628.www2.hp.com/km-ext/kmcsdirect/emr_na-c04436796-1.pdf for detailed information about the HP WBEM providers for Windows)
                    # this might take some time due to the many different queries needed, so we use write-progress to give the user some feedback
                    $wmiQueries.GetEnumerator() | ForEach-Object {
                        $queryIndex++
                        Write-Progress -Activity "Gathering data from '$($computer)'" -PercentComplete (($queryIndex/$wmiQueries.count)*100)
                        New-Variable -Name $_.Name -Value (Get-CimInstance @cimParametersCommon -Query $_.Value)
                    }
 
                    
                    # HP Teaming
                    if($HP_EthernetTeam) {
                        switch($HP_EthernetTeam.LoadBalanceAlgorithm) {
                            0       { $LoadBalanceAlgorithm = 'None' }
                            1       { $LoadBalanceAlgorithm = 'Other' }
                            3       { $LoadBalanceAlgorithm = 'Round Robin' }
                            DEFAULT { $LoadBalanceAlgorithm = 'Unknown' }
                        }
 
                        switch($HP_EthernetTeam.RedundancyStatus) {
                            2       { $RedundancyStatus = 'Fully Redundant' }
                            3       { $RedundancyStatus = 'Degraded Redundancy' }
                            4       { $RedundancyStatus = 'Redundancy Lost' }
                            5       { $RedundancyStatus = 'Overall Failure' }
                            DEFAULT { $RedundancyStatus = 'Unknown' }
                        }
 
                        switch($HP_EthernetTeam.GroupOperationalStatus) {
                            2       { $OperationalStatus = 'OK' }
                            3       { $OperationalStatus = 'Degraded' }
                            6       { $OperationalStatus = 'Error' }
                            DEFAULT { $OperationalStatus = 'Unknown' }
                        }
 
                        switch($HP_EthernetTeam.TeamOperatingMode) {
                            {1000..1006 -contains $_}  { $OperatingMode = 'Switch Fault Tolerant (SFT)' }
                            1007    { $OperatingMode = 'IEEE 802.3ad DLA' }
                            1008    { $OperatingMode = 'Receive Load Balancing (RLB)' }
                            1009    { $OperatingMode = 'Static Link Aggregation (SLA)' }
                            1010    { $OperatingMode = 'Adapter Load Balance (ALB)' }
                            1011    { $OperatingMode = 'Network Fault Tolerance Only (NFT)' }
                            DEFAULT { $OperatingMode = 'Unknown' }
                        }
 
                        $teamingObject = [PSCustomObject] [Ordered] @{
                            VendorIdentifyingInfo     = $HP_EthernetTeam.VendorIdentifyingInfo
                            Caption                   = $HP_EthernetTeam.Caption
                            Description               = $HP_EthernetTeam.Description
                            RedundancyStatus          = $RedundancyStatus
                            OperationalStatus         = $OperationalStatus
                            OperatingMode             = $OperatingMode
                            LoadBalanceAlgorithm      = $LoadBalanceAlgorithm
                            OtherLoadBalanceAlgorithm = $HP_EthernetTeam.OtherLoadBalanceAlgorithm
                            Speed                     = ($HP_EthernetTeam.Speed)/1000000
                            MaxTransmissionUnit       = $HP_EthernetTeam.ActiveMaximumTransmissionUnit
                            PortsConfigured           = $HP_EthernetTeam.MaxNumberSupported
                            MinimumPortsNeeded        = $HP_EthernetTeam.MinNumberNeeded
                        }
                        $teamingObject | Add-Member -MemberType ScriptMethod -Name 'ToString' -Value {$this.VendorIdentifyingInfo} -Force
                    }
 
                    # Processor
                    if($HP_Processor) {
                        foreach ($cpu in $HP_Processor) {                           
 
                            switch($cpu.CpuStatus) {
                                1       { $cpuStatus = 'CPU Enabled' }
                                2       { $cpuStatus = 'CPU Disabled by User using BIOS Setup' }
                                3       { $cpuStatus = 'CPU Disabled by BIOS (POST Error)' }
                                7       { $cpuStatus = 'Other' }
                                DEFAULT { $cpuStatus = 'Unknown' }
                            }
 
                            switch($cpu.HealthState) {
                                0       { $cpuHealthState = 'Unknown' }
                                5       { $cpuHealthState = 'OK' }
                                15      { $cpuHealthState = 'Minor Failure' }
                                20      { $cpuHealthState = 'Major Failure' }
                                25      { $cpuHealthState = 'Critical Failure' }
                                DEFAULT { $cpuHealthState = 'Unknown' }
                            }
 
                            $processorObject += (,([PSCustomObject] [Ordered] @{
                                Name                  = $cpu.Name
                                DeviceID              = $cpu.DeviceID
                                Description           = $cpu.Description
                                Family                = (Get-CpuFamily -Key $cpu.Family)
                                Status                = $cpuStatus
                                HealthState           = $cpuHealthState
                                NumberOfEnabledCores  = $cpu.NumberOfEnabledCores
                                AddressWidth          = $cpu.AddressWidth
                                DataWidth             = $cpu.DataWidth
                                MaxClockSpeed         = $cpu.MaxClockSpeed
                                CurrentClockspeed     = $cpu.CurrentClockSpeed
                                ExternalBusClockSpeed = $cpu.ExternalBusClockSpeed
                            }))
                        }
                        $processorObject | Add-Member -MemberType ScriptMethod -Name 'ToString' -Value {$this.DeviceID} -Force
                    }
 
                    # Memory
                    if($HP_MemoryModule) {
                        foreach ($memoryModule in $HP_MemoryModule) {
                            
                            switch($memoryModule.HealthState) {
                                0       { $MemoryHealthState = 'Unknown' }
                                5       { $MemoryHealthState = 'OK' }
                                10      { $MemoryHealthState = 'Degraded' }
                                DEFAULT { $MemoryHealthState = 'Unknown' }
                            }
 
                            $memoryModuleObject += (,([PSCustomObject] [Ordered] @{
                                Name               = $memoryModule.Name
                                Capacity           = $memoryModule.Capacity
                                MaxMemorySpeed     = $memoryModule.MaxMemorySpeed
                                IsSpeedInMhz       = $memoryModule.IsSpeedInMhz
                                HealthState        = $MemoryHealthState
                                DataWidth          = $memoryModule.DataWidth
                                TotalWidth         = $memoryModule.TotalWidth
                                InterleavePosition = $memoryModule.InterleavePosition
                            }))
                        }
                        $memoryModuleObject | Add-Member -MemberType ScriptMethod -Name 'ToString' -Value {$this.Name} -Force
                    }
 
                    # ArraySystem
                    if($HPSA_ArraySystem) {
                        foreach ($array in $HPSA_ArraySystem) {
                            $arrayObject += (,([PSCustomObject] [Ordered] @{
                                Name        = $array.Name
                                ElementName = $array.ElementName
                            }))
                        }
                        $arrayObject | Add-Member -MemberType ScriptMethod -Name 'ToString' -Value {$this.ElementName} -Force
                    }
 
                    # DiskDrive
                    if($HPSA_DiskDrive) {
                        foreach ($disk in $HPSA_DiskDrive) {
                            
                            switch($disk.OperationalStatus) {
                                0       { $DiskStatus = 'Unknown' }
                                2       { $DiskStatus = 'OK' }
                                5       { $DiskStatus = 'Predictive Failure' }
                                6       { $DiskStatus = 'Error' }
                                DEFAULT { $DiskStatus = 'Unknown' }
                            }
 
                            $diskObject += (,([PSCustomObject] [Ordered] @{
                                Name                 = $disk.Name
                                SystemName           = $disk.SystemName
                                ElementName          = $disk.ElementName
                                Description          = $disk.Description
                                DriveRotationalSpeed = $disk.DriveRotationalSpeed
                                TotalPowerOnHours    = $disk.TotalPowerOnHours
                                OperationalStatus    = $DiskStatus
                            }))
                        }
                        $diskObject | Add-Member -MemberType ScriptMethod -Name 'ToString' -Value {$this.Name} -Force
                    }
 
                    # StorageVolume
                    if($HPSA_StorageVolume) {
                        foreach ($volume in $HPSA_StorageVolume) {
                            switch($volume.ExtentStatus) {
                                2       { $VolumeExtentStatus = 'None' }
                                11      { $VolumeExtentStatus = 'Rebuild - Volume is currently rebuilding data' }
                                DEFAULT { $VolumeExtentStatus = 'Unknown' }
                            }
 
                            $volumeObject += (,([PSCustomObject] [Ordered] @{
                                Name           = $volume.Name
                                DeviceID       = $volume.DeviceID
                                ElementName    = $volume.ElementName
                                OSName         = $volume.OSName
                                BlockSize      = $volume.BlockSize
                                StripeSize     = $volume.StripeSize
                                FaultTolerance = $volume.FaultTolerance
                                ExtentStatus   = $VolumeExtentStatus
                            }))
                        }
                        $volumeObject | Add-Member -MemberType ScriptMethod -Name 'ToString' -Value {$this.OSName} -Force
                    }
 
                    # HBA
                    if ($HPFCHBA_PhysicalPackage) {
                        foreach ($adapter in $HPFCHBA_PhysicalPackage) {
 
                            # query for more data
                            $FCPortInfo  = Get-CimInstance @cimParametersCommon -Query "SELECT PortNumber,OtherPortType FROM HPFCHBA_FCPort WHERE PermanentAddress = '$($adapter.Name)'"
                            $DriverInfo  = Get-CimInstance @cimParametersCommon -Query "SELECT VersionString FROM HPFCHBA_SoftwareIdentityDrv WHERE Name = '$($adapter.Name)'"
                            $FWInfo      = Get-CimInstance @cimParametersCommon -Query "SELECT VersionString FROM HPFCHBA_FirmwareIdentityFW WHERE Name = '$($adapter.Name)'"
                            $ROMBiosInfo = Get-CimInstance @cimParametersCommon -Query "SELECT VersionString FROM HPFCHBA_FirmwareIdentityBIOS WHERE Name = '$($adapter.Name)'"
 
                            switch ($adapter.OperationalStatus) {
                                1       { $OpStatus = 'Other' }
                                2       { $OpStatus = 'OK' }
                                3       { $OpStatus = 'Degraded' }
                                6       { $OpStatus = 'Error' }
                                DEFAULT { $OpStatus = 'Unknown' }
                            }
 
                            $hbaObject += (,([PSCustomObject] [Ordered] @{
                                Manufacturer      = $adapter.Manufacturer
                                Model             = $adapter.Model
                                SerialNumber      = $adapter.SerialNumber
                                PortWWN           = $adapter.Name
                                NodeWWN           = $adapter.Tag.Split(':')[4]
                                Location          = $adapter.OtherIdentifyingInfo
                                OperationalStatus = $OpStatus
                                PortNumber        = $FCPortInfo.PortNumber
                                PortType          = $FCPortInfo.OtherPortType
                                DriverVersion     = $DriverInfo.VersionString
                                AdapterFirmware   = $FWInfo.VersionString
                                AdapterBIOS       = $ROMBiosInfo.VersionString
                            }))
                        }
                        $hbaObject | Add-Member -MemberType ScriptMethod -Name 'ToString' -Value {$this.Model} -Force
                    }
 
                    # System ROM
                    if($HP_SystemROMFirmware) {
                        foreach ($rom in $HP_SystemROMFirmware) {
                            $romObject += (,([PSCustomObject] [Ordered] @{
                                Name          = $rom.Name
                                ElementName   = $rom.ElementName
                                VersionString = $rom.VersionString
                            }))
                        }
                        $romObject | Add-Member -MemberType ScriptMethod -Name 'ToString' -Value {$this.Name} -Force
                    }
 
                    # Software
                    if ($HP_SoftwareIdentity) {
                        foreach ($sw in $HP_SoftwareIdentity) {
                            $swObject += (,([PSCustomObject] [Ordered] @{
                                Caption       = $sw.Caption
                                ElementName   = $sw.ElementName
                                VersionString = $sw.VersionString
                                Description   = $sw.Description
                            }))
                        }
                        $swObject | Add-Member -MemberType ScriptMethod -Name 'ToString' -Value {$this.Caption} -Force
                    }
 
                    # General Information
                    switch ($HP_ComputerSystem.HealthState) {
                        0       { $HealthState = 'Unknown' }
                        5       { $HealthState = 'OK' }
                        10      { $HealthState = 'Degraded' }
                        20      { $HealthState = 'Major Failure' }
                        DEFAULT { $HealthState = 'Unknown' }
                    }
 
                    switch ($HP_ComputerSystem.LocationIndicator) {
                        0       { $LocationIndicator = 'Unknown' }
                        2       { $LocationIndicator = 'On' }
                        3       { $LocationIndicator = 'Off' }
                        5       { $LocationIndicator = 'Alternating' }
                        DEFAULT { $LocationIndicator = 'Unknown' }
                    }
 
                    switch ($HP_ComputerSystem.ActiveLicense) {
                        0       { $mpActiveLicense = 'Unknown' }
                        1       { $mpActiveLicense = 'None' }
                        2       { $mpActiveLicense = 'iLO Advanced' }
                        3       { $mpActiveLicense = 'iLO Light' }
                        4       { $mpActiveLicense = 'iLO Advanced for BladeSystem' }
                        5       { $mpActiveLicense = 'iLO Standard for BladeSystem' }
                        DEFAULT { $mpActiveLicense = 'Unknown' }
                    }
 
                    $output = [PSCustomObject] [Ordered] @{
                        ComputerName                  = $computer
                        HealthState                   = $HealthState
                        LocationIndicator             = $LocationIndicator
                        SerialNumber                  = $HP_ComputerSystemChassis.SerialNumber
                        ProductID                     = $HP_ComputerSystemChassis.ProductID
                        ManagementProcessorType       = $HP_ManagementProcessor.Name
                        ManagementProcessorIpAddress  = $HP_ManagementProcessor.IPAddress
                        ManagementProcessorLicense    = $mpActiveLicense
                        ManagementProcessorLicenseKey = $HP_ManagementProcessor.LicenseKey
                        ManagementProcessorFirmware   = $HP_MPFirmware.VersionString
                        EnclosureName                 = $HP_BladeEnclosureCS.Name
                        EnclosurePosition             = $HP_BladeCSLocation.PhysicalPosition
                        Software                      = $swObject
                        ROM                           = $romObject
                        HBA                           = $hbaObject
                        StorageVolume                 = $volumeObject
                        DiskDrive                     = $diskObject
                        ArraySystem                   = $arrayObject
                        Memory                        = $memoryModuleObject
                        CPU                           = $processorObject
                        NetworkTeam                   = $teamingObject
                    }
 
                    # define default properties for the output object
                    $defaultProperties = @('ComputerName','SerialNumber','EnclosureName','EnclosurePosition','HealthState')
                    $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet',[string[]]$defaultProperties)
                    $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
                    $output | Add-Member -MemberType MemberSet -Name PSStandardMembers -Value $PSStandardMembers
 
                    Write-Output $output
 
                    Remove-Variable -Name 'teamingObject','processorObject','memoryModuleObject','arrayObject','diskObject','volumeObject','hbaObject','romObject','swObject','LocationIndicator','HealthState' -ErrorAction 'SilentlyContinue'
                }
            }
 
            catch {
                # if the connection fail we don't want to keep the session
                Remove-CimSession -Name $computer -ErrorAction SilentlyContinue
                Write-Warning "At line:$($_.InvocationInfo.ScriptLineNumber) char:$($_.InvocationInfo.OffsetInLine) Command:$($_.InvocationInfo.InvocationName), Exception: '$($_.Exception.Message.Trim())'"
            }
        }
    }
}