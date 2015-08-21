<#
.Synopsis
   Gets network adapter configuration information for each adapter installed on a system
.DESCRIPTION
   This function leverages the Win32_NetworkAdapterConfiguration WMI Class and the Get-NetAdapter cmdlet to retrieve information on a network adapter.  It then collates and displays this information to the user.
.EXAMPLE
   Run the script .\Get-AdapterConfig.ps1
   Then use a command such as Get-AdapterConfig -ComputerName Server01
   The results will be displayed.
.NOTES
Created by Will Anderson
January 8, 2015
#>

Function Get-AdapterConfig{[cmdletbinding()]
    Param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)][ValidateNotNullorEmpty()][string[]]$ComputerName
    )
    BEGIN{
        ForEach($System in $ComputerName){
        Write-Verbose "Scanning Network Adapter Configuration for $System"
        }
        }#ENDBEGIN

    PROCESS{
        Try{
            ForEach($Computer in $ComputerName){
                $NetAdapter = (Get-NetAdapter -CimSession $Computer).where({$PSItem.LinkSpeed -gt 1})


                ForEach ($Net in $NetAdapter){
                        $NetMAC = $Net.MACAddress -replace "-",":"
                        $AdapterCfg = (Get-CIMInstance Win32_NetworkAdapterConfiguration -ComputerName $Net.PSComputerName).where({$PSItem.MACAddress -eq $NetMAC}) | Where-Object IPEnabled -EQ $True
                        
                        [PSCustomObject]@{
                        System = $AdapterCfg.PSComputerName
                        Description = $AdapterCfg.Description
                        IPAddress = $AdapterCfg.IPAddress
                        SubnetMask = $AdapterCfg.IPSubnet
                        DefaultGateway = $AdapterCfg.DefaultIPGateway
                        DNSServers = $AdapterCfg.DNSServerSearchOrder
                        DNSDomain = $AdapterCfg.DNSDomain
                        DNSSuffix = $AdapterCfg.DNSDomainSuffixSearchOrder
                        FullDNSREG = $AdapterCfg.FullDNSRegistrationEnabled
                        WINSLMHOST = $AdapterCfg.WINSEnableLMHostsLookup
                        WINSPRI = $AdapterCfg.WINSPrimaryServer
                        WINSSEC = $AdapterCfg.WINSSecondaryServer
                        DOMAINDNSREG = $AdapterCfg.DomainDNSRegistrationEnabled
                        DNSEnabledWINS = $AdapterCfg.DNSEnabledForWINSResolution
                        TCPNETBIOSOPTION = $AdapterCfg.TcpipNetbiosOptions
                        IsDHCPEnabled = $AdapterCfg.DHCPEnabled
                        AdapterName = $Net.name
                        Status = $Netr.status
                        LinkSpeed = $Net.linkspeed
                        Driverinformation = $Net.driverinformation
                        DriverFilename = $Net.DriverFileName
                        MACAddress = $AdapterCfg.MACAddress
                        InterfaceName = $Net.InterfaceDescription
                        }#EndPSCustomObject
                    }#ForEachNet
                }#EndCompForEach
            }#EndTry
        Catch [System.Exception]{
    		Write-Output "An error was encountered while attempting to access $Computer"
		}#EndCatch
    }#ENDPROCESS
    END{Write-Verbose "Complete."}#ENDEND
}#ENDFuction