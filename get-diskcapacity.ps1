function get-diskcapacity {

[CmdletBinding()]

param (

 [string[]]$computername = $env:COMPUTERNAME

)

PROCESS {

foreach ($computer in $computername) {

Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType = 3" -ComputerName $computer |

select PSComputerName, Caption,

@{N='Capacity_GB'; E={[math]::Round(($_.Size / 1GB), 2)}},

@{N='FreeSpace_GB'; E={[math]::Round(($_.FreeSpace / 1GB), 2)}},

@{N='PercentUsed'; E={[math]::Round(((($_.Size - $_.FreeSpace) / $_.Size) * 100), 2) }},

@{N='PercentFree'; E={[math]::Round((($_.FreeSpace / $_.Size) * 100), 2) }}

} # end foreach

} # end PROCESS

}