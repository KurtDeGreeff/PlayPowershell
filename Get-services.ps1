#$ScriptPath   = (Split-Path ((Get-Variable MyInvocation).Value).MyCommand.Path)

Function Get-Running {

Param(
[Parameter(Position=0,ValueFromPipeline=$True)]
[string]$Computername=$env:COMPUTERNAME
)

Process {
  #region Getting service information
  Write-Host "Getting running services from $computername" -ForegroundColor Cyan
  $s = Get-Service -ComputerName $computername | 
  where status -eq 'running'
  #endregion
  Write-Host "Found $($s.count) services" -ForegroundColor Cyan
  foreach ($item in $s) {
  $item.DisplayName.ToLower()
  }
} #end process
} #end function
Get-Running
