ipmo PSScheduledJob
$t = New-JobTrigger -Weekly -DaysOfWeek "Monday", "Thursday" -At "5:00 AM"

#Each job can have zero, one, or multiple job triggers
Register-ScheduledJob -Name Pip -ScriptBlock {Start-process notepad} -Trigger @{Frequency="AtLogon"}


$o = New-ScheduledJobOption -WakeToRun
Get-ScheduledJobOption -Name ProcessJob



@{Frequency="AtStartup"}

@{Frequency="AtLogon"}

powershell -NoProfile -NonInteractive -Command "& {Register-ScheduledJob -Name Pip -ScriptBlock {Start-process <BATCHFILE>} -Trigger @{Frequency='AtLogon'}}"