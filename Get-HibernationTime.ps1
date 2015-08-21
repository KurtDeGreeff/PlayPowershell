function Get-HibernationTime
{
 
  # get hibernation events
  Get-EventLog -LogName system -InstanceId 1 -Source Microsoft-Windows-Power-TroubleShooter |
  ForEach-Object {   
    # create new object for results
    $result = 'dummy' | Select-Object -Property ComputerName, SleepTime,WakeTime, Duration
   
    # store details in new object, convert datatype where appropriate
    [DateTime]$result.Sleeptime = $_.ReplacementStrings[0]
    [DateTime]$result.WakeTime = $_.ReplacementStrings[1]
    $time = $result.WakeTime - $result.SleepTime
    $result.Duration = ([int]($time.TotalHours * 100))/100
    $result.ComputerName = $_.MachineName
   
    # return result
    $result
  }
}
