# http://techibee.com/powershell/power-ping-a-script-to-monitor-your-server-restart/706
# .Restart-Monitor.ps1 -computer server1 -timeout 10
# Where server1 is the name of the remote server I am monitoring and timeout is the max time(in minutes) server takes to reboot.
Param (            
 [Parameter(ValueFromPipeline=$False,Mandatory=$True)]            
 [string]$computer,            
 [Parameter(ValueFromPipeline=$False,Mandatory=$False)]            
 [int]$timeout=5            
)            
            
$MAX_PINGTIME = $timeout * 60            
$max_iterations = $MAX_PINGTIME/5            
$Notification_timeout = 10 # in seconds            
            
function Show-notification {            
            
param($type,$text,$title)            
            
#load Windows Forms and drawing assemblies            
[reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null[reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null            
#define an icon image pulled from PowerShell.exe            
$icon=[system.drawing.icon]::ExtractAssociatedIcon((join-path $pshome powershell.exe))            
$notify = new-object system.windows.forms.notifyicon            
$notify.icon = $icon            
$notify.visible = $True            
#define the tool tip icon based on the message type            
switch ($messagetype) {            
 "Error" { $messageIcon=[system.windows.forms.tooltipicon]::Error}            
 "Info" {$messageIcon=[system.windows.forms.tooltipicon]::Info}            
 "Warning" {$messageIcon=[system.windows.forms.tooltipicon]::Warning}            
 Default {$messageIcon=[system.windows.forms.tooltipicon]::None}            
}            
            
#display the balloon tipe            
$notify.showballoontip($Notification_timeout,$title,$text,$type)            
}            
            
function ping-host {            
param($pc)            
$status = Get-WmiObject -Class Win32_PingStatus -Filter "Address='$pc'"            
if( $status.statuscode -eq 0) {            
   return 1            
} else {            
 return 0            
}            
}            
            
if(ping-host -pc $computer) {            
 Write-Host "$computer is online; Waiting for it to go offline"            
 $status = "online"            
 for ($i=0; $i -le $max_iterations; $i++) {            
  if (!(ping-host -pc $computer )) {            
   break            
  }            
  Start-Sleep -Seconds 5            
  if($i -eq $max_iterations) {            
   Write-Host "$computer never went down in last $timeout minutes"            
   Write-Host "Check that reboot is initiated properly"            
   show-notification -type "error" -text "$computer is still ONLINE; Check that reboot is initiated properly" -title "Computer is not rebooting"            
   exit            
  }            
    }            
            
    Write-Host "$computer is offline now; monitoring for online status"            
            
} else {            
    Write-Host "$computer is offline; Monitoring for online status"            
    $status = "offline"            
}            
            
for ($i=0; $i -le $max_iterations; $i++) {            
 if ((ping-host -pc $computer )) {            
  break            
 }            
            
 Start-Sleep -Seconds 5            
 if($i -eq $max_iterations) {            
  Write-Host "Your computer never came back online in last $MAX_PINGTIME seconds"            
  Write-Host "Check that nothing is preventing starup"            
  show-notification -type "error" -text "$Computer is NOT coming online; Something is preventing its startup" -title "Computer failed to start"            
  exit            
 }            
}            
            
Write-Host "Your computer is Online Now; Task done; exiting"            
show-notification -type "info" -text "$Computer is online" -title "$Computer successfully restarted"