<#
.Synopsis
   This script retreives the timezone of a local or remote computer via WMI.
.DESCRIPTION
   This script retreives the timezone of a local or remote computer via WMI.
.NOTES
    Created by: Jason Wasser
    Modified: 2/27/2015 10:48:55 AM 
.EXAMPLE
   Get-TimeZone
   Shows the localhost timezone.
.EXAMPLE
   Get-TimeZone -ComputerName SERVER1
   Shows the timezone of SERVER1.
.EXAMPLE
   Get-TimeZone -ComputerName (Get-Content c:\temp\computerlist.txt)
   Shows the timezone of a list of computers.
#>
Function Get-TimeZone {
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        # Computer name
        [Alias('Name')]
        [Parameter(Mandatory=$false,
                    ValueFromPipeLine=$true,
                    ValueFromPipelineByPropertyName=$true,
                    Position=0)]
        [string[]]$ComputerName=$env:COMPUTERNAME
    )
    Begin
    {
    }
    Process
    {
        foreach ($Computer in $ComputerName) {
            try {
                $ServerInfo = Get-WmiObject -Class win32_timezone -ComputerName $Computer -ErrorAction Stop | Select-Object -Property __SERVER,Caption
                $objServerInfo = New-Object PSOBject
                $objServerInfo | Add-Member -Type NoteProperty -Name ComputerName -Value $ServerInfo.__SERVER
                $objServerInfo | Add-Member -Type NoteProperty -Name TimeZone -Value $ServerInfo.Caption
                $objServerInfo
            }
            catch {
                $objServerInfo = New-Object PSOBject
                $objServerInfo | Add-Member -Type NoteProperty -Name ComputerName -Value $Computer
                $objServerInfo | Add-Member -Type NoteProperty -Name TimeZone -Value "Error: $Error"
                $objServerInfo
            }
            finally {
            }
        }
    }
    End
    {
    }
}