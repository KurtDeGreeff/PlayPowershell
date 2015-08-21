function Get-IPConfig
{
    <#
        .SYNOPSIS
        Short Description
        .DESCRIPTION
        Detailed Description
        .EXAMPLE
        Get-NetIPConfig
        explains how to use the command
        can be multiple lines
        .EXAMPLE
        Get-NetIPConfig
        another example
        can have as many examples as you like
    #>
    [cmdletbinding()]
    param (
        [parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [string[]]$ComputerName = $env:computername
    )            
    
    begin {}
    process {
        foreach ($Computer in $ComputerName) {
            if(Test-Connection -ComputerName $Computer -Count 1 -ea 0) {
                $Networks = Get-WmiObject Win32_NetworkAdapterConfiguration -ComputerName $Computer | ? {$_.IPEnabled}
                foreach ($Network in $Networks) {
                    $IPAddress  = $Network.IpAddress[0]
                    $SubnetMask  = $Network.IPSubnet[0]
                    $DefaultGateway = $Network.DefaultIPGateway
                    $DNSServers  = $Network.DNSServerSearchOrder
                    $IsDHCPEnabled = $false
                    If($network.DHCPEnabled) {
                        $IsDHCPEnabled = $true
                    }
                    $MACAddress  = $Network.MACAddress
                    $OutputObj  = New-Object -Type PSObject
                    $OutputObj | Add-Member -MemberType NoteProperty -Name ComputerName -Value $Computer.ToUpper()
                    $OutputObj | Add-Member -MemberType NoteProperty -Name IPAddress -Value $IPAddress
                    $OutputObj | Add-Member -MemberType NoteProperty -Name SubnetMask -Value $SubnetMask
                    $OutputObj | Add-Member -MemberType NoteProperty -Name Gateway -Value $DefaultGateway
                    $OutputObj | Add-Member -MemberType NoteProperty -Name IsDHCPEnabled -Value $IsDHCPEnabled
                    $OutputObj | Add-Member -MemberType NoteProperty -Name DNSServers -Value $DNSServers
                    $OutputObj | Add-Member -MemberType NoteProperty -Name MACAddress -Value $MACAddress
                    $OutputObj
                }
            }
        }
    }            
    
    end {}
}

