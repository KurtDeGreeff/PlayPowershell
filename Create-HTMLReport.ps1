$computername = 'Kurtdg'

$b = Get-WmiObject -class Win32_ComputerSystem -Computer $computername |
Select-Object -Property Manufacturer,Model,
@{name='Memory(GB)';expression={$_.TotalPhysicalMemory / 1GB -as [int]}},
@{name='Architecture';expression={$_.SystemType}}, 
@{name='Processors';expression={$_.NumberOfProcessors}} |
ConvertTo-HTML -Fragment -As LIST -PreContent "<h2>Computer Hardware:</h2>" | Out-String

$b += Get-WmiObject -class Win32_LogicalDisk -Computer $computername |
Select-Object -Property @{n='DriveLetter';e={$_.DeviceID}},
@{name='Size(GB)';expression={$_.Size / 1GB -as [int]}},
@{name='FreeSpace(GB)';expression={$_.FreeSpace / 1GB -as [int]}} |
ConvertTo-Html -Fragment -PreContent "<h2>Disks:</h2>" | Out-String

$b += Get-WmiObject -class Win32_NetworkAdapter -Computer $computername | 
Where { $_.PhysicalAdapter } |
Select-Object -Property MACAddress,AdapterType,DeviceID,Name |
ConvertTo-Html -Fragment -PreContent "<h2>Physical Network Adapters:</h2>" | Out-String

$head = @'
<style>
body { background-color:#dddddd;
font-family:Tahoma;
font-size:12pt; }
td, th { border:1px solid black; 
border-collapse:collapse; }
th { color:white;
background-color:black; }
table, tr, td, th { padding: 2px; margin: 0px }
table { margin-left:50px; }
</style>
'@

ConvertTo-HTML -head $head -PostContent $b -Body "<h1>Hardware Inventory for $ComputerName</h1>" |
Out-File -FilePath "$computername.html"
Invoke-Item -Path "$computername.html"