function Get-TimeServer {
<#
    .Synopsis
    Gets the time server as configured on a computer.
    .DESCRIPTION
    Gets the time server as configured on a computer.
    The default is localhost but can be used for remote computers.
    .EXAMPLE
    Get-TimeServer -ComputerName "Server1"
    .EXAMPLE
    Get-TimeServer -ComputerName "Server1","Server2"
    .EXAMPLE
    Get-TimeServer -Computer "Server1","Server2"
    .EXAMPLE
    Get-TimeServer "Server1","Server2"
    .NOTES
    Written by Jeff Wouters.
#>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param ( 
        [parameter(mandatory=$true,position=0)][alias("computer")][array]$ComputerName="localhost"
    )
    begin {
        $HKLM = 2147483650
    }
    process {
        foreach ($Computer in $ComputerName) {
            $TestConnection = Test-Connection -ComputerName $Computer -Quiet -Count 1
            $Output = New-Object -TypeName psobject
            $Output | Add-Member -MemberType 'NoteProperty' -Name 'ComputerName' -Value $Computer
            $Output | Add-Member -MemberType 'NoteProperty' -Name 'TimeServer' -Value "WMI Error"
            $Output | Add-Member -MemberType 'NoteProperty' -Name 'Type' -Value "WMI Error"
            if ($TestConnection) {              
                try {
                    $reg = [wmiclass]"\\$Computer\root\default:StdRegprov"
                    $key = "SYSTEM\CurrentControlSet\Services\W32Time\Parameters"
                    $servervalue = "NtpServer"
                    $server = $reg.GetStringValue($HKLM, $key, $servervalue)
                    $ServerVar = $server.sValue -split ","
                    $Output.TimeServer = $ServerVar[0]
                    $typevalue = "Type"
                    $type = $reg.GetStringValue($HKLM, $key, $typevalue)
                    $Output.Type = $Type.sValue             
                    return $Output
                } catch {
                    return $output
                }
            } else {
            }
        }
    }
}