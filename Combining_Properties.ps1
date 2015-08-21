$bios = Get-WmiObject -Class Win32_BIOS
$os = Get-WmiObject -Class Win32_OperatingSystem
$hashtable = $bios |
  Get-Member -MemberType *Property |
  Select-Object -ExpandProperty Name |
  Sort-Object |
  ForEach-Object { $rv=@{} } { Write-Warning $_;$rv.$_ = $bios.$_ } {$rv}
 
$os | Add-Member ($hashtable) -ErrorAction SilentlyContinue
$os
