$PSDefaultParameterValues =  @{
"Send-MailMessage:To" = "info@beatit.nu";
"Send-MailMessage:From" = "kurt.de.greeff@outlook.com";
"Send-MailMessage:SMTPServer" = "smtp.live.com";
"Send-MailMessage:Port" = 587;
"Send-MailMessage:Subject" = "test Powershell";
"Send-MailMessage:Body" = "Testing123";
"Send-MailMessage:UseSSL" = $true;
"Send-MailMessage:Credential" = (Get-Credential kurt.de.greeff@outlook.com);
}

#Enable or Disable $PSDefaultParameterValues
$PSDefaultParameterValues["Disabled"]=$true
$PSDefaultParameterValues["Disabled"]=$false
$PSDefaultParameterValues.Add("Disabled", $true)
$PSDefaultParameterValues.Remove("Disabled")

$PSDefaultParameterValues=@{"Invoke-Command:ScriptBlock"={{Get-EventLog –Log System}}}

$PSDefaultParameterValues=@{"Format-Table:AutoSize"={if ($host.Name –eq "ConsoleHost"){
$true}}}

#Add Value to hashtable
<HashTable>.Add(Key, Value)
$PSDefaultParameterValues.Add("<CmdletName>:<ParameterName>", "<ParameterValue>")
$PSDefaultParameterValues.Add("Get-Process:Name", "PowerShell")

#Remove Value
<HashTable>.Remove(Key)
$PSDefaultParameterValues.Remove("<CmdletName>:<ParameterName>")

#Change Value
$PSDefaultParameterValues["CmdletName:ParameterName"]="<NewValue>"

#SIMPLIFIED DELEGATED ADMINISTRATION in Win2012
#Remote Endpoints
Get-PSSessionConfiguration
$PSSessionConfigurationName

$junioradmin = Get-Credential vaio8\test
$s = New-PSSession -ComputerName Localhost -Credential $junioradmin

$junioradmin = Get-Credential vaio8\test  #password is testtest
Register-PSSessionConfiguration -Name JuniorEndpoint -ShowSecurityDescriptorUI -Force
$s = New-PSSession -ComputerName Localhost -Credential $junioradmin -ConfigurationName JuniorEndpoint
Invoke-Command -Session $s -ScriptBlock {gcm}

#Give # set if credentials : RunAs
Set-PSSessionConfiguration -Name JuniorEndpoint -RunAsCredential vaio8\kurt -Force

Invoke-Command $s {Get-Service }
Invoke-Command $s {$pssenderinfo }

Unregister-PSSessionConfiguration -Name JuniorEndpoint

#Use PsSessionConfigurationFiles to limit what junioradmin can do
#After that use Register-PSSessionConfiguration and point to the file created above
New-PSSessionConfigurationFile -Path c:\test.pssc -ModulesToImport Microsoft.Powershell.Management -VisibleCmdlets get-service -SessionType RestrictedRemoteServer
Register-PSSessionConfiguration -Name JuniorEndpoint -Path c:\test.pssc -RunAsCredential vaio8\kurt -ShowSecurityDescriptorUI -Force
$s = New-PSSession -ComputerName Localhost -Credential $junioradmin -ConfigurationName JuniorEndpoint

#Junior Admin will now only see the limited commands available
Invoke-Command $s {Get-Service }
Invoke-Command -Session $s -ScriptBlock {Get-Command}

#POWERSHELL WORKFLOWS
#Multi-Machine Orchestration Engine built on Windows Workflow Foundation and .NET 4.0
# to reliably execute long-running tasks across multiple processes or machines
# you can use *-job cmdlets to handle workflows

#Simple workflow
workflow verb-noun
{
    "Hello Wordl"
}

Get-Command verb-noun
Get-Command verb-noun -Syntax
(Get-Command verb-noun).Parameters.Count

$wfjob = verb-noun -AsJob
Receive-Job $wfjob

#Use new cmdlets to suspend/resume workflow
Suspend-Job $wfjob -Force -Wait
$wfjob
Receive-job $wfjob
Resume-Job $wfjob -Wait
Get-Job | Remove-Job -Force

#Job Scheduling
gcm -Module PSScheduledJob 
gcm New-JobTrigger -Syntax
$dailytrigger = New-JobTrigger -Daily -At 3am
$OneTimeTrigger = New-JobTrigger -Once -At (Get-Date).AddHours(1)
$weeklyTrigger = New-JobTrigger -Weekly -DaysOfWeek Friday -At 6pm

Register-ScheduledJob -Name DailyBackup -Trigger $dailytrigger -ScriptBlock { Copy-Item c:\tobackup d:\backup$((Get-date).ToFileTime()) -Recurse -Force}
Register-ScheduledJob -Name GenerateReport -Trigger $weeklytrigger -FilePath c:\scripts\weekly.ps1

Get-ScheduledJob   #per user
Get-ScheduledJob DailyBackup | Get-JobTrigger

Get-ScheduledJobOption -Name DailyBackup
Get-ScheduledJobOption -Name DailyBackup | Set-ScheduledJobOption -MultipleInstancePolicy Queue -RequireNetwork

#Results across sessions
Get-Job
Receive-Job <id>


#Robust Session Connectivity
#Trying reconnect during 4 min

#Disconnected sessions
$s = New-PSSession -Name DeploySession
Invoke-Command -Session $s -ScriptBlock {
    1..1000000 | % { "Output $_"; sleep 1}
}

#During disconnection all data is kept in memory on the server
# with a limit of 2GB (configurable), and becomes available to client when reconnect
$s = New-PSSession -Name DeploySession
Invoke-Command -Session $s -ScriptBlock {
    1..1000000 | % { "Output $_"; sleep 1}
} -AsJob -JobName LongJob

Get-Job -Name LongJob | Receive-Job -Keep

Disconnect-PSSession $s

#Reconnect
Get-PSSession -ComputerName localhost
$s = Get-PSSession -ComputerName . -Name DeploySession | Connect-PSSession
$s

Receive-PSSession -Session $s -OutTarget Job -JobName LongJob

Get-Job LongJob | Receive-Job -Keep

#Go immediately into disconnected mode
Invoke-Command -ComputerName localhost -ScriptBlock {
    1..1000000 | % {"Output $_"; sleep 1}
} -InDisconnectedSession -SessionName DeploySession2


#Powershell Web Access
#Any browser with html/javascript support on tablet/iphone/...


#2321 cmdlets
