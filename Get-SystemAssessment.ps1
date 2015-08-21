$satstate = DATA {

ConvertFrom-StringData -StringData @'

0 = StateUnknown

1 = Valid

2 = IncoherentWithHardware

3 = NoAssessmentAvailable

4 = Invalid

'@

}

 

function get-systemassessment{

[CmdletBinding()]

param (

[parameter(ValueFromPipeline=$true,

   ValueFromPipelineByPropertyName=$true )]

   [string]$computername="$env:COMPUTERNAME"

)

PROCESS{

 Get-WmiObject -Class Win32_WinSat -ComputerName $computername |

 select CPUScore, D3DScore, DiskScore, GraphicsScore,

 MemoryScore, TimeTaken,

 @{N="AssessmentState"; E={$satstate["$($_.WinSATAssessmentState)"]}},

 @{N="BaseScore"; E={$_.WinSPRLevel}}

 

}#process

}

get-systemassessment