#
# Windows PowerShell in Action Second Edition
#
# Chapter 20 Eventing
#
# Handling synchronous and asynchronous .NET events
#

# Synchronous event examples - using scriptblocks
# the regular expression Replace() method

[System.Text.RegularExpressions.MatchEvaluator] |
    Format-List Name,FullName,BaseType

[System.Text.RegularExpressions.MatchEvaluator] |
  foreach {
    [string] ($_.GetMembers() -match ' Invoke')
  }
  
$inputString = "abcd"
[regex]::replace($inputString, ".",
    [System.Text.RegularExpressions.MatchEvaluator] {
        param($match)
            "{0:x4}" -f [int] [char]$match.value })


#######################################
#
# Asynchronous event examples 

# Starting with a timer

$timer = New-Object System.Timers.Timer
$timer | Get-Member -MemberType event
$timer | Get-Member
Register-ObjectEvent -InputObject $timer -EventName Elapsed -Action { Write-Host "<TIMER>" }
$timer.Interval = 500
$timer.Enabled = $true
$timer.AutoReset = $true
$timer.Start()

$timer.Stop()

$timer.Start()

$timer.Stop()

Get-EventSubscriber | Unregister-Event

#######################################

$timer = New-Object System.Timers.Timer -Property @{
    Interval = 5000
    Enabled = $true
    AutoReset = $false
  }

Register-ObjectEvent -InputObject $timer `
  -MessageData "Nee!" `
  -EventName Elapsed

Wait-Event| Format-List Sender, MessageData
@(Get-Event).Count
Get-Event | Format-List Sender, MessageData
@(Get-Event).Count
Get-Event | Remove-Event
@(Get-Event).Count

Get-EventSubscriber | Unregister-Event

#######################################


$timer = New-Object System.Timers.Timer -Property @{
  Interval = 2000; Enabled = $true; AutoReset = $false }
  
Register-ObjectEvent $timer Elapsed -action {
  $Event | Out-Host
}

$timer.Start() > $null

Get-EventSubscriber | Unregister-Event

#######################################

Get-EventSubscriber | Unregister-Event
Get-Event | Remove-Event

$timer = New-Object System.Timers.Timer -Property @{
  Interval = 5000; Enabled = $true; AutoReset = $false }
  
Register-ObjectEvent $timer Elapsed -action {
  Write-Host '<TIMER>'
    New-Event -SourceIdentifier generatedEvent -Sender 3.14
} > $null

$timer.Start() > $null

Wait-Event -SourceIdentifier generatedEvent |
  foreach {
    "Received generated event"
    $_ |
      Format-Table -AutoSize SourceIdentifier, EventIdentifier, Sender
    $_ | Remove-Event
  }

Get-EventSubscriber | Unregister-Event

#######################################
#
# Looking at the variables available inside the
# event handler scriptblock

$timer = New-Object System.Timers.Timer
Register-ObjectEvent -InputObject $timer `
-EventName Elapsed -Action {
    Write-Host "<TIMER>" 
    Get-Variable |
        where {$_.name -match 'event|arg|sourc|sender' } |
            fl | Out-String | Write-Host -foreground yellow
            
    $args | fl | Out-String | Write-Host -foreground green
    "Done" | out-host
}
$timer.Interval = 500
$timer.AutoReset = $false
$timer.Enabled = $true

Get-EventSubscriber | Unregister-Event

#######################################


Get-Event | Remove-Event

$timer = New-Object System.Timers.Timer -Property @{
  Interval = 500; AutoReset = $true }

Register-ObjectEvent -InputObject $timer `
   -MessageData 5 `
  -SourceIdentifier Stateful -EventName Elapsed -Action {
    $script:counter += 1
    Write-Host "Event counter is $counter"
    if ($counter -ge $Event.MessageData)
    {
       Write-Host "Stopping timer"
       $timer.Stop()
    }
  } > $null
  
$timer.Start()

#####################################
#
# Using the Wait-Event cmdlet to wait for
# an asynchronous event
#

[System.IO.FileSystemWatcher].GetEvents() |
  Select-String .
  
$path = (Resolve-Path ~/desktop).Path
$fsw = [System.IO.FileSystemWatcher] $path
$fsw.EnableRaisingEvents = $true
Register-ObjectEvent $fsw Created -SourceIdentifier fsw1
Register-ObjectEvent $fsw Changed -SourceIdentifier fsw2
Get-Event
Get-Date > ~/desktop/date.txt
Get-Event | select SourceIdentifier
Get-Event | Remove-Event
Wait-Event
Get-Event | Remove-Event
Wait-Event -Timeout 2

################################################################################################


# Combining remoting and eventing to handle events being
# generated on a remote computer.
#

$s = New-PSSession -computer brucepayquad
Invoke-Command $s {
    $myLog = New-Object System.Diagnostics.EventLog application
    Register-ObjectEvent `
        -InputObject $myLog  `
        -SourceIdentifier EventWatcher1 `
        -EventName EntryWritten `
        -forward
        
    $myLog.EnableRaisingEvents = $true
}

Register-EngineEvent -SourceIdentifier EventWatcher1 -action {
   param($sender, $event)
            
   Write-Host "Got an event: $($event.entry.message)"
}

powershell "[System.Environment]::FailFast('An event')"




$typeSpec = @'
    <Types>
       <Type>
           <Name>System.Diagnostics.EntryWrittenEventArgs</Name>
            <Members>
                <MemberSet>
                    <Name>PSStandardMembers</Name>
                    <Members>
                        <NoteProperty>
                            <Name>SerializationDepth</Name>
                            <Value>2</Value>
                        </NoteProperty>
                    </Members>
                </MemberSet>
            </Members>
       </Type>
    </Types>
'@
Invoke-Command $s { Unregister-Event EventWatcher1 }
Unregister-Event EventWatcher1

Invoke-Command  -ArgumentList $typeSpec $s {
    param ($typeSpec)
    
    $tempFile = [System.IO.Path]::GetTempFileName()
    $tempFile = $tempFile -replace '\.tmp$', '.ps1xml'
    $typeSpec > $tempFile
    Update-TypeData $tempFile
    Remove-Item $tempFile
}

Invoke-Command $s {
    $myLog = New-Object System.Diagnostics.EventLog application
    Register-ObjectEvent `
        -InputObject $myLog  `
        -SourceIdentifier EventWatcher1 `
        -EventName EntryWritten `
        -forward
        
    $myLog.EnableRaisingEvents = $true
}

Register-EngineEvent -SourceIdentifier EventWatcher1 -action {
   param($sender, $event)
            
   Write-Host "Got an event: $($event.entry.message)"
}

powershell "[System.Environment]::FailFast('An event')"


#############################################################################################################


#
# Handling WMI events
#

# Class-based queries...
Get-WmiObject -List win32_*trace |
  Format-List Name,__SUPERCLASS
  
Register-WmiEvent -Class  Win32_ProcessStartTrace `
  -action {
    "Process Start: " +
      $event.SourceEventArgs.NewEvent.ProcessName |
        Out-Host
  }

Register-WmiEvent -Class  Win32_ProcessStopTrace `
  -action {
    "Process Stop: " + 
      $event.SourceEventArgs.NewEvent.ProcessName |
        Out-Host
  }

Register-WmiEvent -Class  Win32_ProcessTrace `
  -action {
    "Process Any: " +
      $event.SourceEventArgs.NewEvent.ProcessName |
        Out-Host
  }

& { 
$p = Start-Process calc -PassThru
Start-Sleep 3
$p | Stop-Process
Start-Sleep 3
$p = Start-Process calc -PassThru
Start-Sleep 3
$p | Stop-Process
Start-Sleep 3
}

Get-EventSubscriber | Unregister-Event



# Query based event registrations...

$queryString = @"
  SELECT * FROM __InstanceCreationEvent WITHIN 10
  WHERE Targetinstance ISA 'Win32_PNPEntity' and
  TargetInstance.DeviceId LIKE '%USBStor%'
"@

$usbEvent = Register-WmiEvent -Query $queryString `
  -Action {
    Write-Host "USB EVENT OCCURRED"
  }

$query = New-Object System.Management.EventQuery
$query.QueryString = 
$watcher = New-Object `
  System.Management.ManagementEventWatcher `
    $query
$result = $watcher.WaitForNextEvent()

Register-WmiEvent `
 -SourceIdentifier "ProcessCreationEvent" `
 -Action {
   Write-Host "Got process started event"
   $event | format-list * | out-host
} -Query @"
  SELECT * from __instancecreationevent 
  WITHIN 5
  WHERE targetinstance ISA 'win32_process'
"@

$query = @'
SELECT * FROM __InstanceCreationEvent
WITHIN 10
WHERE TargetInstance ISA 'CIM_DirectoryContainsFile' 
  and TargetInstance.GroupComponent='Win32_Directory.Name="C:\temp\"'
'@
Register-WmiEvent -Query $query


$query2 = @'
Select * From __InstanceCreationEvent
Within 5
Where Targetinstance Isa 'CIM_DirectoryContainsFile' and
    TargetInstance.GroupComponent='Win32_Directory.Name="c:\temp"'
'@

$query2 = @'
Select * From __InstanceCreationEvent Within 5
Where Targetinstance Isa 'CIM_DirectoryContainsFile' and
   TargetInstance.GroupComponent="Win32_Directory.Name='c:\\temp"'
'@
Register-WmiEvent -Query $query2


gwmi Win32_Directory -filter "name='c:\\temp'"
$tempPath =  "\\.\root\cimv2:Win32_Directory.name='c:\\temp'"
[wmi] $tempPath

# telnet service
$tempPath =  "\\.\root\cimv2:Win32_Service.name='TlntSvr'"
[wmi] $tempPath

$query3 = @"
Select * From __InstanceOperationEvent Within 1
Where Targetinstance Isa 'Win32_Service'
"@
Register-WmiEvent -Query $query3 -action {
   Write-Host "Got instance operation event on Win32_Service"
   $Event | Format-List * | Out-Host
}

$svcQuery = @"
Select * From __InstanceOperationEvent Within 1
Where (Targetinstance Isa 'Win32_Service'
  and
   TargetInstance.Name='TlntSvr')
"@

Register-WmiEvent -Query $svcQuery -action {
   Write-Host "Got specific instance operation event on Win32_Service"
   $Event | Format-List * | Out-Host
}


Start-Sleep 5; Start-Service TlntSvr
Start-Sleep 5
Stop-Service TlntSvr

# SELECT * FROM EventClass [WHERE property = value] 
#    GROUP WITHIN interval [BY property_list]
#    [HAVING NumberOfEvents operator integer]

<#
EVENT-WQL = "SELECT" <PROPERTY-LIST> "FROM" / 
              <EVENT-CLASS-NAME> <OPTIONAL-WITHIN> <EVENT-WHERE>

OPTIONAL-WITHIN = ["WITHIN" <INTERVAL>]
INTERVAL = 1*DIGIT
EVENT-WHERE = ["WHERE" <EVENT-EXPR>]

EVENT-EXPR = ( (<INSTANCE-STATE> "ISA" <CLASS-NAME> <EXPR2>) /
              <EXPR> )
              ["GROUP WITHIN" <INTERVAL> 
                    ( ["BY" [<INSTANCE-STATE> DOT] <PROPERTY-NAME>] 
                      ["HAVING" <EXPR>]] )
INSTANCE-STATE = "TARGETINSTANCE" / "PREVIOUSINSTANCE"

SELECT * FROM EventClass [WHERE property = value] 
    GROUP WITHIN interval [BY property_list]
    [HAVING NumberOfEvents operator integer]

#>


$GroupQuery = @"
Select * From __InstanceOperationEvent
Where TargetInstance.Name='TlntSvr'
Group Within 5
Having NumberOfEvents > 3
"@

Get-EventSubscriber | Unregister-Event

$GroupQuery = @"
Select * From __InstanceOperationEvent Within .5
Where Targetinstance Isa 'Win32_Service'
and TargetInstance.Name='TlntSvr'
Group Within 20
"@

$global:TotalEvents = 0
Register-WmiEvent -Query $GroupQuery -action {
   Write-Host "Got grouped event"
   $ne = $Event.SourceEventArgs.NewEvent
   $ti = $ne.Representative.TargetInstance
   $global:TotalEvents += $ne.NumberOfEvents
   $msg = "Type: " + $ne.__CLASS +
     " Num Evnts: " + $ne.NumberOfEvents + 
       " Name: " + $ti.Name +
         " (" + $ti.DisplayName + ')' |
           Out-Host
}

foreach ($i in 1..3)
{
  Start-Service TlntSvr
  Start-Sleep 2
  Stop-Service TlntSvr
  Start-Sleep 2
}

start-sleep 10
"Total events: $TotalEvents"

Get-EventSubscriber | Unregister-Event


$v2Path = 
'\\.\root\cimv2:Win32_Environment.Name="tp2",UserName="<SYSTEM>"'

#################################
# Engine Events

powershell {
    Register-EngineEvent `
      -SourceIdentifier PowerShell.Exiting `
      -Action {
        "@{Directory='$PWD'}" > ~/pshState.ps1
        } | Format-List Id,Name
     cd ~/desktop
     exit
  }

Get-Content ~/pshState.ps1


#####################################################################################################################