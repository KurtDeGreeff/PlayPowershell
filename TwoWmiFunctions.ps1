# ----------------------------------------------------------------------------- 
# Script: TwoWmiFunctions.ps1 
# Author: ed wilson, msft 
# Date: 05/08/2013 11:17:12 
# Keywords: Function, Scripting Techniques, WMI 
# comments:  
# HSG-5-14-2013 
# ----------------------------------------------------------------------------- 
Function Get-Volume 
{ 
 Param($cn = $env:computername) 
 Get-WmiObject -class win32_volume -ComputerName $cn|  
 Select-Object driveletter, @{LABEL='FileSystemLabel';EXPRESSION={$_.label}},  
  filesystem,  
  @{LABEL="Size";EXPRESSION={"{0:N2} Gigabytes" -f ($_.capacity/1GB) }},  
  @{LABEL="SizeRemaining";EXPRESSION={"{0:N2} Gigabytes" -f ($_.freespace/1GB) }} 
 } #end function Get-Volume 
 
Function Get-NetAdapter 
{ 
 Param($cn = $env:computername) 
  Get-WmiObject win32_networkadapter |  
   Where-Object {$_.netconnectionstatus} | 
    Select-Object name,  
     @{LABEL='InterfaceDescription';EXPRESSION={$_.Description}},  
     @{LABEL='ifIndex';EXPRESSION={$_.Index}}, 
     @{LABEL='Status';EXPRESSION={  
      If($_.netconnectionstatus -eq 2){"not present"} 
      If($_.netconnectionstatus -eq 4){"up"}}} 
 } # end function get-NetAdapter 