[ordered]@{a=1;b=2;c=3}
# Can use wildcards too for defaultparametervalues
$PSDefaultParameterValues = @{
"Send-MailMessage:From" = "kurt.de.greeff@outlook.com";
"Send-MailMessage:SmtpServer" = "smtp.live.com";
"Send-MailMessage:UseSSL" = $true;
"Send-MailMessage:Port" = 587;
"Send-MailMessage:Credential" = (Get-Credential kurt.de.greeff@outlook.com)
}
Send-MailMessage -to gyzmos@gmail.com -subject "Test" -Body "Sent mail message"

#Turn off all default parameter values
$PSDefaultParameterValues["Disabled"] = $true

#PS Session Configuration
Get-PSSessionConfiguration

#By default you connect to microsoft.powershell
$s = New-PSSession -ComputerName Localhost # acces denied because no permissions
$PSSessionConfigurationName
Register-PSSessionConfiguration -Name JuniorEndpoint -ShowSecurityDescriptorUI -Force
$s = New-PSSession -ComputerName localhost -ConfigurationName JuniorEndpoint -Credential $junioradmin
Invoke-Command $s {get-command}

#Change permissions so junioradmin can now run commands with different set of credentials
Set-PSSessionConfiguration -Name JuniorEndpoint -RunAsCredential administrator -Force

Invoke-Command $s {Get-service} # now works
Invoke-Command $s { $PsSenderInfo } # show connected user and the runas user

Unregister-PSSessionConfiguration -Name JuniorEndpoint -Force

#Constrain more with session configuration files
New-PSSessionConfigurationFile -Path c:\endpoint.pssc -ModulesToImport Microsoft.powershell.management -VisibleCmdlets Get-service -SessionType RestrictedRemoteServer #latest parameter specifies that the user gets a interactive remote session

ise c:\endpoint.pssc

Register-PSSessionConfiguration -Name JuniorEndpoint -path c:\endpoint.pscc -RunAsCredential administrator -ShowSecurityDescriptorUI -Force
$s = New-PSSession -ComputerName localhost -ConfigurationName JuniorEndpoint -Credential $junioradmincreds
Invoke-Command $s {get-service}
Invoke-Command $s {Get-Command}

#Job Scheduling
Get-command -Module PSscheduledjob | sort noun
Get-command New-JobTrigger -Syntax

$dailytrigger = New-JobTrigger -Daily -At 3am

$onetimetrigger = New-JobTrigger -Once -At (Get-Date).AddHours(1)

$weeklytrigger = New-jobtrigger -Weekly -DaysOfWeek Friday -At 6pm

Register-ScheduledJob -Name DailyBackup -trigger $dailytrigger -ScriptBlock { copy-item c:\importantfiles d:\backup$((Get-date).ToFileTime()) -Recurse -Force}

Register-ScheduledJob -Name GenerateWeeklyReport -Trigger $weeklytrigger -FilePath C:\scripts\weeklyreport.ps1

#see which jobs are scheduled per user
Get-ScheduledJob

#see when the job run
Get-ScheduledJob Dailybackup | Get-JobTrigger

Get-ScheduledJobOption -Name Dailybackup

#Only run backup at a time, and we need network connectivity
Get-ScheduledJobOption -Name DailyBackup | Set-ScheduledJobOption -MultipleInstancePolicy Queue -RequireNetwork

# results are across sessions: open another ps session and launch get-scheduledjob, get-job, receive-job
