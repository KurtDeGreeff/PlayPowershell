# Define a WMI event query, that looks for new instances of Win32_LogicalDisk where DriveType is "2" (removeable disk)
# http://msdn.microsoft.com/en-us/library/aa394173(v=vs.85).aspx
$Query = "select * from __InstanceCreationEvent within 5 where TargetInstance ISA 'Win32_LogicalDisk' and TargetInstance.DriveType = 2";

# Define a PowerShell ScriptBlock that will be executed when an event occurs
$Action = { & C:\test\script.ps1;  };

# Create the event registration
Register-WmiEvent -Query $Query -Action $Action -SourceIdentifier USBFlashDrive;

#Launch script on USB when event occurs
#$Action = { & ('{0}\ufd.ps1' -f $event.SourceEventArgs.NewEvent.TargetInstance.Name);  };

#Remove the event by removing the job it created: get-job | remove-job -force