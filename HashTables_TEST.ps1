$computername=$env:computername
$prop=[ordered]@{Computername=$Computername}
$os=Get-WmiObject Win32_OperatingSystem -Property Caption,LastBootUpTime -ComputerName $computername
$boot=$os.ConvertToDateTime($os.LastBootuptime)
$prop.Add("OS",$os.Caption)
$prop.Add("Boot",$boot)
$prop.Add("Uptime",(Get-Date)-$boot)
$running=Get-Service -ComputerName $computername | 
Where status -eq "Running"
$prop.Add("RunningServices",$Running)
$cdrive=Get-WMIObject win32_logicaldisk -filter "DeviceID='c:'" -computername $computername
$prop.Add("C_SizeGB",($cdrive.Size/1GB -as [int]))
$prop.Add("C_FreeGB",($cdrive.FreeSpace/1GB))
$obj=New-Object -TypeName PSObject -Property $prop
$obj.PSObject.TypeNames.Insert(0,"MyInventory")
Write-Output $obj

Write-Host $PSScriptRoot
Write-Host "$PSCommandPath"