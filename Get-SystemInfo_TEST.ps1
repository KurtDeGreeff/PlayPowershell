function Get-SystemInfo {

[CmdletBinding(SupportsShouldProcess=$True, 
ConfirmImpact="Medium" )]
# adding –WhatIf and –Confirmparameters
param(
[Parameter(#Mandatory=$True,
ValueFromPipeline=$True,
ValueFromPipelineByPropertyName=$True)]
[Alias('hostname')]
[ValidateCount(1,5)] 
[ValidateLength(5,20)]
[ValidateSet("Localhost",{$env:computername},"hostname")]
[ValidateScript({Test-Connection -Computername $_ -Count 1 -Quiet})]
#[ValidatePattern("\w+\\\w+")]
#[ValidateNotNull()]
[ValidateNotNullOrEmpty()]
[string[]]$computerName="$env:COMPUTERNAME",

#[Parameter(Mandatory=$True)]
[ValidateRange(1,5)]
[uint32]$drivetype
)
BEGIN {}
PROCESS {
foreach ($computer in $computername) {
$os = Get-WmiObject –Class Win32_OperatingSystem –comp $computer
$cs = Get-WmiObject –Class Win32_ComputerSystem –comp $computer
$props = @{'OSVersion'=$os.version;
'Model'=$cs.model;
'Manufacturer'=$cs.manufacturer;
'ComputerName'=$os.__SERVER;
'OSArchitecture'=$os.osarchitecture}
$obj = New-Object –TypeName PSObject –Property $props
Write-Output $obj
}
}
END {}
}
Get-SystemInfo
$psScriptRoot
$PSCommandPath
