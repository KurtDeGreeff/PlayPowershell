
#sample usage:
#c:\scripts\get-drivegridview file01
#c:\scripts\get-drivegridview file01,file02,dc01,dc02,app01,web01

Param(
[string[]]$computername = $env:COMPUTERNAME
)

Write-Host "Collecting drive information...please wait" -ForegroundColor Green

$data = Get-WmiObject -class win32_logicaldisk -ComputerName $computername -filter 'drivetype=3' | 
Select @{Name="Computername";Expression={$_.Systemname}},
@{Name="Drive";Expression={$_.DeviceID}},
@{Name="SizeMB";Expression={[int]($_.Size/1MB)}},
@{Name="FreeMB";Expression={[int]($_.Freespace/1MB)}},
@{Name="UsedMB";Expression={[math]::round(($_.size - $_.Freespace)/1MB,2)}},
@{Name="Free%";Expression={[math]::round(($_.Freespace/$_.Size)*100,2)}},
@{Name="FreeGraph";Expression={
 [int]$per=($_.Freespace/$_.Size)*100
 "|" * $per }
 } 
 
 #send the results to Out-Gridview
 $data | out-gridview -Title "Drive Report"

 #the following examples require PowerShell v3 to take advantage of the new
 #Out-Gridview features.

 <#
 #maybe you'd like to see details?
 $data | out-gridview -Title 'WMI Detail: Please select one or more drives' -PassThru | 
 foreach {get-wmiobject -Class win32_logicaldisk -filter "deviceid='$($_.Drive)'" `
 -computername $_.Computername | Select * } | Out-GridView -Title 'WMI Drive Detail'
 #>

 <#
  #or open the drive in Explorer
  $data | 
  out-gridview -Title "Drive Explorer: Please select one or more drives to open" -PassThru | 
  Foreach { 
   #construct a UNC for the drive that should be the administrative share
   $unc = "\\{0}\{1}" -f $_.Computername,$_.Drive.replace(":","$")
   #open the UNC in Windows Explorer
   invoke-item $unc
  }
 #>