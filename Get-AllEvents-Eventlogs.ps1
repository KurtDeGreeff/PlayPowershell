# calculate start time (one hour before now)
$Start = (Get-Date) - (New-Timespan -Hours 1)
$Computername = $env:COMPUTERNAME
 
# Getting all event logs
Get-EventLog -AsString -ComputerName $Computername |
  ForEach-Object {
    # write status info
    Write-Progress -Activity "Checking Eventlogs on \\$ComputerName" -Status $_
 
    # get event entries and add the name of the log this came from
    Get-EventLog -LogName $_ -EntryType Error, Warning -After $Start -ComputerName $ComputerName -ErrorAction SilentlyContinue |
      Add-Member NoteProperty EventLog $_ -PassThru
      
  } |
  # sort descending
  Sort-Object -Property TimeGenerated -Descending |
  # select the properties for the report
  Select-Object EventLog, TimeGenerated, EntryType, Source, Message |
  # output into grid view window
  Out-GridView -Title "All Errors & Warnings from \\$Computername" 