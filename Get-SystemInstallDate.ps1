#requires -version 2.0
function Get-SystemInstallDate([String]$Computer = '.') {
  <#
    .NOTES
        Author: greg zakharov
  #>
  
  try {
    [Management.ManagementDateTimeConverter]::ToDateTime(
      ((New-Object Management.ManagementClass(
        [Management.ManagementPath]('\\' + $Computer + '\root\cimv2:Win32_OperatingSystem')
      )).PSBase.GetInstances() | select InstallDate).InstallDate
    )
  }
  catch [Management.Automation.MethodInvocationException] {
    if ($_.Exception) {
      [TimeZone]::CurrentTimeZone.ToLocalTime([DateTime]'1.1.1970').AddSeconds(
        (gp 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').InstallDate
      )
    }
  }
}