function Get-Uptime
{
  $millisec = [Environment]::TickCount
  [Timespan]::FromMilliseconds($millisec)
}