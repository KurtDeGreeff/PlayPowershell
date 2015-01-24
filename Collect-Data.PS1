# ========================================================
#
# 	Script Information
#
#	Title:				Collect Computer Inentory Data
#	Author:				Assaf Miron
#	Originally created:	21/06/2008
#	Updated:			08/02/2009 
#	Original path:		Collect-Data.PS1
#	Description:		Collects Remote Computer Data Using WMI and Registry Access						
#	
# ========================================================
# Get Script Location 
$ScriptLocation = Split-Path -Parent $MyInvocation.MyCommand.Path
# Set Registry Keys
$REG_COMPUTER_NAME = "SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName" # \ComputerName
$REG_PROCESSOR_NAME = "HARDWARE\DESCRIPTION\System\CentralProcessor\0" # \ProcessorNameString
$REG_HKLM_ENIVORNMENT = "SYSTEM\CurrentControlSet\Control\Session Manager\Environment" # \NUM_OF_PROCESSOR, \PROCESSOR_ARCHITECTURE
$REG_USER_NAME = "Software\Microsoft\Windows\CurrentVersion\Explorer" # HKCU \Logon User Name
$REG_USER_DOMAIN = "SOFTWARE\Policies\Microsoft\System\DNSClient" # PrimaryDnsSuffix
$REG_HKCU_ENIVORNMENT = "Volatile Environment" # \USERDNSDOMAIN
$REG_HKLM_NET_PARAMS = "SYSTEM\CurrentControlSet\Control\Network\{4D36E972-E325-11CE-BFC1-08002BE10318}"
$REG_HKLM_BIOS = "HARDWARE\DESCRIPTION\System\SystemBiosVersion"


function Join-Data($objName="")
{
	# Function Joins arrays and Strings to a Single Object with Members
	# I Used the same principle of the Out-DataTable and converted it to Join Objects into one
	# Using the Add-Member cmdlet. the Function writes to a predefiend object named $DataObject
	# $objName is used for objects that don't have member other than Length like Strings
	foreach ($item in $Input)
	{
		$Item.PsObject.get_properties() | foreach{
			if ($_.value -eq $null)
			{
				$DataObject | Add-Member noteproperty $_.Name "[empty]"
			}
			elseif ($_.IsArray) {
				$DataObject | Add-Member noteproperty $_.Name [string]::Join($_.value, ";")
			}
			elseif ($objName -ne "") {
				$DataObject | Add-Member noteproperty $objName $Item
			}
			else
			{
				$DataObject | Add-Member noteproperty $_.Name $_.value -Force
			}
		}
	}
	
	return @(,$DataObject)
}

function Get-Reg {
# Function Connects to a remote computer Registry using the Parameters it recievs
	param(
		$Hive,
		$Key,
		$Value,
		$RemoteComputer="." # If not enterd Local Computer is Selected
	)
	# Connect to Remote Computer Registry
	$reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($Hive, $RemoteComputer)
	# Open Remote Sub Key
	$regKey= $reg.OpenSubKey($Key)
	if($Value -eq $null) # Enumarate Keys
	{ return $regKey.GetSubKeyNames() } # Return Sub Key Names
	if($regKey.ValueCount -gt 0) # check if there are Values 
	{ return $regKey.GetValue($Value) } # Return Value
}

function Get-WMIItem {
# Function Retreives a specific Item from a remote computer's WMI
	param(
		$Class,
		$RemoteComputer=".", # If not enterd Local Computer is Selected
		$Item,
		$Query="", # If not enterd an empty WMI SQL Query is Entered
		$Filter="" # If not enterd an empty Filter is Entered
	)
	$ErrorActionPreference="SilentlyContinue"
	trap [Exception] { return "WMI Error";continue }
	if ($Query -eq "") # No Specific WMI SQL Query
	{
		# Execute WMI Query, Return only the Requsted Items
		gwmi -Class $Class -ComputerName $RemoteComputer -Filter $Filter -Property $Item | Select $Item
	}
	else # User Entered a WMI SQL Query
	{gwmi -ComputerName $RemoteComputer -Query $Query | select $Item}
	$ErrorActionPreference="Continue"
}

function Collect-Data($strComputer)
{
		# Collect Computer Details from Win32_computersystem Using WMI
		$ComputerDet = Get-WMIItem -Class "Win32_computersystem" -RemoteComputer $strComputer -Item Caption,Domain,SystemType,Manufacturer,Model,NumberOfProcessors,TotalPhysicalMemory,UserName
		$scanWMI = $true
		# if($ComputerDet.Caption.Length -gt 1) # Check to See if Any data was Collected at all
		if(($ComputerDet -eq "WMI Error") -or ($ComputerDet -eq $Null)) { $scanWMI = $false } # Disable WMI Scanning
		else { $ComputerDet.Manufacturer = $ComputerDet.Manufacturer.Replace(","," ") }

#region ComputerDet - No WMI
		if($scanWMI -eq $false)
		{
			$compCaption = Get-Reg -RemoteComputer $strComputer -Hive LocalMachine -Key $REG_COMPUTER_NAME -Value "ComputerName"
			$compNumProcessor = Get-Reg -RemoteComputer $strComputer -Hive LocalMachine -Key $REG_HKLM_ENIVORNMENT -Value "NUMBER_OF_PROCESSORS"
			$compUserName = Get-Reg -RemoteComputer $strComputer -Hive CurrentUser -Key $REG_USER_NAME -Value "Logon User Name"
			$compDomainName = Get-Reg -RemoteComputer $strComputer -Hive CurrentUser -Key $REG_USER_DOMAIN -Value "PrimaryDnsSuffix"
			if($compDomainName -ne $Null -and $compUserName -ne $Null)
			{
				$compUserName = $compDomainName.split(".")[0]+"\"+$compUserName
			}
			$compSysType = Get-Reg -RemoteComputer $strComputer -Hive LocalMachine -Key $REG_HKLM_ENIVORNMENT -Value "PROCESSOR_ARCHITECTURE"
			if($compSysType -like "x86") { $compSysType = "X86-based PC" }
			elseif($compSysType -like "x64") { $compSysType = "x64-based PC" }
			else { $compSysType = "Unknown" }
		}
#endregion

#region Total Memory Formating - WMI Only
		if($scanWMI)
		{
			# Check Total Physical Memory Size and Format it acourdingly
			if($ComputerDet.TotalPhysicalMemory -ge 1GB){
			$ComputerDet.TotalPhysicalMemory = ($ComputerDet.TotalPhysicalMemory/1GB).Tostring("# GB")} # Format to GB
			else {$ComputerDet.TotalPhysicalMemory = ($ComputerDet.TotalPhysicalMemory/1MB).Tostring("# MB")} # Format to MB
		}
#endregion

#region Memory Slots
		if($scanWMI)
		{
			$MemSlotCount = Get-WMIItem -Class "Win32_PhysicalMemoryArray" -RemoteComputer $strComputer -Item MemoryDevices
			$MemSlotProperties = Get-WMIItem -Class "Win32_PhysicalMemory" -RemoteComputer $strComputer -Item Capacity
			$arrMemSlots = @()
			foreach($slot in $MemSlotProperties)
			{
				if($slot.Capacity -gt 1GB)
				{$arrMemSlots = ($slot.Capacity/1GB).ToString("# GB") + ";" + $arrMemSlots } # Format to GB
				else{$arrMemSlots = ($slot.Capacity/1MB).ToString("# MB") + ";" + $arrMemSlots } # Format to MB
			}
		}
#endregion

#region CPU Name
		if($scanWMI) # Scan WMI
		{
			# Collect CPU Name Using WMI
			$CPUName = Get-WMIItem -Class "Win32_Processor" -RemoteComputer $strComputer -Item Name
			# CPU Names Can Contain Multiple Values, in Order to Insert Them into the DataGridView I Divde them to String with ";" Seperators
			$arrCPUNames = @() 
			foreach($CPU in $CPUName){
				$arrCPUNames = $CPU.Name.Trim()+";"+$arrCPUNames # the String of the CPU Name has White Space in The Begining - Trim It
				}
		}
		else # Scan Registry - WMI not working
		{
			$CPUName = Get-Reg -RemoteComputer $strComputer -Hive LocalMachine -Key $REG_PROCESSOR_NAME -Value "ProcessorNameString"
			$arrCPUNames = $CPUName.Trim()+";"
		}
#endregion	

#region Operating System Data
		if($scanWMI) # Scan WMI
		{
			# Collect Operating System and Service Pack Information Usin WMI
			$OS = Get-WMIItem -Class "win32_operatingsystem" -RemoteComputer $strComputer -Item Caption,csdversion,LastBootUpTime
			$OS.Caption = $OS.Caption.Replace(","," ")
			$OS.LastBootUpTime = Get-Date($OS.LastBootUpTime)
		}
		else
		{
			$OSCaption = Get-Reg -RemoteComputer $strComputer -Hive LocalMachine -Key "SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Value "ProductName"
			$OSSP = Get-Reg -RemoteComputer $strComputer -Hive LocalMachine -Key "SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Value "CSDVersion"
		}
#endregion

#region Chassis Type - WMI Only
		if($scanWMI) # Scan WMI
		{
			# Collect Machine Chassis Using WMI
			$ChassisType = Get-WMIItem -Class Win32_SystemEnclosure -RemoteComputer $strComputer -Item ChassisTypes 
			# Select Machine Chassis
			switch ($ChassisType.ChassisTypes) 
			{
					1 {$ChassisType = "Other"}
					2 {$ChassisType = "Unknown"}
					3 {$ChassisType = "Desktop"}
					4 {$ChassisType = "Low Profile Desktop"}
					5 {$ChassisType = "Pizza Box"}
					6 {$ChassisType = "Mini Tower"}
					7 {$ChassisType = "Tower"}
					8 {$ChassisType = "Portable"}
					9 {$ChassisType = "Laptop"}
					10 {$ChassisType = "Notebook"}
					11 {$ChassisType = "Handheld"}
					12 {$ChassisType = "Docking Station"}
					13 {$ChassisType = "All-in-One"}
					14 {$ChassisType = "Sub-Notebook"}
					15 {$ChassisType = "Space Saving"}
					16 {$ChassisType = "Lunch Box"}
					17 {$ChassisType = "Main System Chassis"}
					18 {$ChassisType = "Expansion Chassis"}
					19 {$ChassisType = "Sub-Chassis"}
					20 {$ChassisType = "Bus Expansion Chassis"}
					21 {$ChassisType = "Peripheral Chassis"}
					22 {$ChassisType = "Storage Chassis"}
					23 {$ChassisType = "Rack Mount Chassis"}
					24 {$ChassisType = "Sealed- PC"}
					default {$ChassisType = "Unknown"}
			}
		}
#endregion

#region Automatic Updates
			# Collect the Automatic Updates Options Using Registry Access
			$AUOptions = Get-Reg -Hive LocalMachine -RemoteComputer $strComputer -Key "SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" -Value "AUOptions"
			
			# Collect the Automatic Updates Install Day Using Registry Access
			$AUDay = Get-Reg -Hive LocalMachine  -RemoteComputer $strComputer -Key "SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" -Value "ScheduledInstallDay"
			
			# Collect the Automatic Updates Install Time Using Registry Access
			$AUTime = Get-Reg -Hive LocalMachine  -RemoteComputer $strComputer -Key "SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" -Value "ScheduledInstallTime"
			if($AUOptions -eq $null){ # Automatic Updates is defined in Group Policy
				$AUOptions = Get-Reg -Hive LocalMachine  -RemoteComputer $strComputer -Key "SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Value "AUOptions"
				$AUDay = Get-Reg -Hive LocalMachine  -RemoteComputer $strComputer -Key "SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Value "ScheduledInstallDay"
				$AUTime = Get-Reg -Hive LocalMachine  -RemoteComputer $strComputer -Key "SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Value "ScheduledInstallTime"
				}
			switch ($AUOptions){ # Check Wich Automatic Update Option is Selected
				1 {$AUClient = "Automatic Updates is Turnd off."}
				2 {$AUClient = "Notify for download and notify for install "}
				3 {$AUClient = "Auto download and notify for install "}
				4 {
					switch ($AUDay) # Check on What day the Automatic Update Installs
					{
					0 {$InstDay = "Every Day"}
					1 {$InstDay = "Sunday"}
					2 {$InstDay = "Monday"}
					3 {$InstDay = "Tuesday"}
					4 {$InstDay = "Wensday"}
					5 {$InstDay = "Thursday"}
					6 {$InstDay = "Friday"}
					7 {$InstDay = "Saturday"}
					}
					# Check on What time the Automatic Update Installs
					if ($AUTime -le 12) { $AUTime = $AUTime.ToString() + " AM" } else { $AUTime = ($AUTime -12) + " PM" }
						$AUClient = "Auto download and schedule the install - "+$InstDay+" "+$AUTime}
				Defualt {"Automatic Updates is not Set."} # No setting Collected
			}
#endregion

#region Computer Total Health
		if($scanWMI) # Scan WMI
		{
			# Collect Avialable Memory with WMI
			$AvialableMem = Get-WMIItem -Class "Win32_PerfFormattedData_PerfOS_Memory" -RemoteComputer $strComputer -Item "AvailableBytes"
			
			# Collect Disk Queue,Queue Length, Processor time Data Using WMI
			$DiskQueue = Get-WMIItem -Class "Win32_PerfFormattedData_PerfDisk_LogicalDisk" -RemoteComputer $strComputer -Item CurrentDiskQueueLength
			$QueueLength = Get-WMIItem -Class "Win32_PerfFormattedData_PerfNet_ServerWorkQueues" -RemoteComputer $strComputer -Item QueueLength
			$Processor = Get-WMIItem -Class "Win32_PerfFormattedData_PerfOS_Processor" -RemoteComputer $strComputer -Item PercentProcessorTime
			
			$intHealth = 0 # integer for Collecting Computer Total Health
			# Using the Avialable Memory to Check Computer Totla Health
			if($AvialableMem.AvailableMBytes -lt 4) { $intHealth += 1; $strHealth += "Low Free Memory;" }
			# Using Current Disk Queue Length to Check Computer Total Health
			if($DiskQueue.CurrentDiskQueueLength -gt 2) { $intHealth += 1; $strHealth += "High Disk Queue;" }
			# Using Queue Length to Check Computer Total Health
			if($QueueLength.QueueLength -gt 4) { $intHealth += 1; $strHealth += "Long Disk Queue;" }
			# Using Processor Time(%) to Check Computer Total Health
			if($Processor.PercentProcessorTime -gt 90) { $intHealth += 1; $strHealth += "Processor Usage Over 90%;" }
			# If the integer is Bigger than 1 so the computer is Unhealthy, Describe Computer Problems
			# Else The Computer is Healthy
			if($intHealth -gt 1) { $ComputerTotalHealth = "UnHealthy, " + $strHealth } else { $ComputerTotalHealth = "Healthy" }
		}
		else
		{
			$ComputerTotalHealth = "WMI Error"
		}
#endregion	

#region Avialable Memory Formating - WMI Only
		if($scanWMI) # Scan WMI
		{
			if($AvialableMem.AvailableBytes -gt 1GB)
			# Format Avialable Memory GB
			{ $AvialableMem = ($AvialableMem.AvailableBytes/1GB).ToString("# GB") }
			else
			# Format Avialable Memory MB
			{ $AvialableMem = ($AvialableMem.AvailableBytes/1MB).ToString("# MB") }
		}
#endregion

#region Disk Drive Info - WMI Only
		if($scanWMI) # Scan WMI
		{
			# Collect Disk Drive Information Using WMI
			$DriveInfo = Get-WMIItem -Class "Win32_LogicalDisk" -RemoteComputer $strComputer -Item Caption,Size,FreeSpace -Filter "DriveType=3"
			# Format Every Drive Size and Free Space
			foreach($DRSize in $DriveInfo)
				{ # Check Object Size and Format Acourdingly
					if($DRSize.Size -ne $Null)
					{
						if($DRSize.Size -ge 1GB)
							{ $DRSize.Size = ($DRSize.Size/1GB).ToString("# GB") } # Format to GB
						elseif($DRSize.Size -ge 1MB)
							{ $DRSize.Size = ($DRSize.Size/1MB).ToString("# MB") } # Format to MB
						else
							{ $DRSize.Size = ($DRSize.Size/1KB).ToString("# KB") } # Format to KB
						if($DRSize.FreeSpace -ge 1GB)
							{ $DRSize.FreeSpace = ($DRSize.FreeSpace/1GB).ToString("# GB") } # Format to GB
						elseif($DRSize.FreeSpace -ge 1MB)
							{ $DRSize.FreeSpace = ($DRSize.FreeSpace/1MB).ToString("# MB") } # Format to MB
						else
							{ $DRSize.FreeSpace = ($DRSize.FreeSpace/1KB).ToString("# KB") } # Format to KB
					}
					else
					{ 
						$DRSize.Size = "-"
						$DRSize.FreeSpace = "-"
					}
				}
			# Disk Drives Can Contain Multiple Values, in Order to Insert Them into the DataGridView I divide them to Strings with ";" Seperators
			$arrDiskDrives = @() 
			$arrDiskSize = @() 
			$arrDiskFreeSpace = @() 
			foreach($Drive in $DriveInfo){
				$arrDiskDrives = $Drive.Caption+";"+$arrDiskDrives
				$arrDiskSize = $Drive.Size+";"+$arrDiskSize
				$arrDiskFreeSpace = $Drive.FreeSpace+";"+$arrDiskFreeSpace
				}
		}
#endregion	

#region IP Addresses
		# IPAddress Can Contain Multiple Values, in Order to Insert Them into the DataGridView I divide them to Strings with ";" Seperators
		$arrIPAddress = @() 
		if($scanWMI) # Scan WMI
		{
			# Collect IPAddresses Using WMI, Filter only Enabled IPs
			$IPAddress = Get-WmiItem -Class "Win32_NetworkAdapterConfiguration" -Filter "IPEnabled = True" -RemoteComputer $strComputer -Item IPAddress
			foreach($IP in $IPAddress){
				$arrIPAddress = $IP.IPAddress[0]+";"+$arrIPAddress
				}
		}
		else
		{
			# Enumarate all the Network Devices form the Remote computer
			$arrNetDevice = Get-Reg -RemoteComputer $strComputer -Hive LocalMachine -Key $REG_HKLM_NET_PARAMS
			foreach($NetDevice in $arrNetDevice)
			{
				# Collect the IP Address Data from Each Network Device
				if($NetDevice -ne "Descriptions") # descriptions is a SubKey that has irrelevant information
				{
					# DHCP IP Address
					$IPAddress = Get-Reg -RemoteComputer $strComputer -Hive LocalMachine -Key "SYSTEM\CurrentControlSet\Services\$NetDevice\Parameters\Tcpip" -Value "DhcpIPAddress"
					if($IPAddress -eq "0.0.0.0") # No DHCP IP - Check if Static IP
					{	
						# Static IP Address
						$IPAddress = Get-Reg -RemoteComputer $strComputer -Hive LocalMachine -Key "SYSTEM\CurrentControlSet\Services\$NetDevice\Parameters\Tcpip" -Value "IPAddress"
					}
					if($IPAddress -ne "0.0.0.0" -and $IPAddress -ne $Null) # Check that IP has a value
					{
						$arrIPAddress = $IPAddress+";"+$arrIPAddress # Add all IPAddress to a single string
					}
				}
			}
		}
#endregion

#region MAC Addresses
		if($scanWMI) # Scan WMI
		{
			# Collect MACAddresses Using WMI, Filter only Enabled IPs
			$MACAddress = Get-WmiItem -Class "Win32_NetworkAdapterConfiguration" -Filter "IPEnabled = True" -RemoteComputer $strComputer -Item MACAddress
			# MACAddress Can Contain Multiple Values, in Order to Insert Them into the DataGridView I divide them to Strings with ";" Seperators
			$arrMACAddress = @() 
			foreach($MAC in $MACAddress){
				$arrMACAddress = $MAC.MACAddress+";"+$arrMACAddress
				}
		}
		else
		{
			# Does not appear for all computers
			$MACAddress = Get-Reg -RemoteComputer $strComputer -Hive LocalMachine -Key "SOFTWARE\Description\Microsoft\Rpc\UuidTemporaryData" -Value "NetworkAddress"
			$arrMACAddress = $MACAddress+";" 
		}
#endregion

#region Time Zone - WMI Only
		if($scanWMI) # Scan WMI
		{
			# Collect Time Zone Information Using WMI
			$TimeZone = Get-WMIItem -Class "Win32_TimeZone" -RemoteComputer $strComputer -Item Bias,StandardName
			$TimeZone.Bias = $TimeZone.Bias/60
		}
#endregion

#region System Restore Status			
			# Collect System Restore Information Using Remote Registry
			$SysRestoreStatus = Get-Reg -Hive LocalMachine -RemoteComputer $strComputer -Key "SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" -Value "DisableSR"
			if ($SysRestoreStatus -eq 0) { $SysRestoreStatus = "Enabled" } else { $SysRestoreStatus = "Disabled" }
#endregion

#region Offline Files Status			
			# Collect Offline Files Information Using Remote Registry
			$OfflineFolStatus = Get-Reg -Hive LocalMachine -RemoteComputer $strComputer -Key "SOFTWARE\Microsoft\Windows\CurrentVersion\NetCache" -Value "Enabled"
			if ($OfflineFolStatus -eq 1) { $OfflineFolStatus = "Enabled" } else { $OfflineFolStatus = "Disabled" }
#endregion

#region Printers - WMI Only
		if($scanWMI) # Scan WMI
		{
			# Collect Printers Information Using WMI
			$Printers = Get-WMIItem -Class "Win32_Printer" -RemoteComputer $strComputer -Item Name,PortName,Caption
			# Printers Contain Multiple Values, in Order to Insert Them into the DataGridView I divide them to Strings with ";" Seperators
			$arrPrinters = @() 
			foreach($Printer in $Printers){
				$arrPrinters = $Printer.Name+"("+$Printer.PortName+");"+$arrPrinters
				}
		}
#endregion

#region BIOS Serial Number - WMI Only
		if($scanWMI) # Scan WMI
		{
			# Collect BIOS Serial Number Using WMI
			$BIOSSN = Get-WMIItem -Class "Win32_Bios" -RemoteComputer $strComputer -Item SerialNumber
		}
#endregion

#region Network Drives - WMI Only
		if($scanWMI) # Scan WMI
		{
			# Collect Network Drives Using WMI
			$NetDrives = Get-WMIItem -Class "Win32_LogicalDisk" -RemoteComputer $strComputer -Item DeviceID,ProviderName -Filter "DriveType=4"
			# Network Drives Contain Multiple Values, in Order to Insert Them into the DataGridView I divide them to Strings with ";" Seperators
			$arrNetDrives = @() 
			foreach($NetDrive in $NetDrives){
				$arrNetDrives = $NetDrive.DeviceID+"("+$NetDrive.ProviderName+");"+$arrNetDrives
				}		
		}
#endregion

#region Anti-Virus Client Data
			# Collect Anti-Virus Info Using Remote Registry
			$AVParentServer = Get-Reg -Hive LocalMachine -RemoteComputer $strComputer -Key "SOFTWARE\Intel\LANDesk\VirusProtect6\CurrentVersion" -Value "Parent"
			# Read the Anti-Virus Virus Definition File and Format it to an actual Date
			$VirusDefFile = "C:\Program Files\Common Files\Symantec Shared\VirusDefs\definfo.dat"
			if(Test-Path $VirusDefFile){
				$AVDefs = Get-Content $VirusDefFile | where { $_ -match "CurDefs" }
				$AVDefs = $AVDefs.Substring(8)
				$AVDefs = [datetime]($AVDefs.Substring(5,1)  + "/" + $AVDefs.Substring(6,2) + "/" + $AVDefs.substring(0,4))
			}
			else { $AVDefs = "" }
#endregion

#region Operating Systems Hotfixes - WMI Only
		if($scanWMI) # Scan WMI
		{
			# Collect all Hotfix Information Using WMI
			$HotFixes = Get-WMIItem -Class "Win32_QuickFixEngineering" -RemoteComputer $strComputer -Item Description,HotFixID,ServicePackInEffect
			# HotFixes Contain Multiple Values, in Order to Insert Them into the DataGridView I divide them to Strings with ";" Seperators
			$arrHotFixes = @()
			foreach($Fix in $HotFixes){
				if($Fix.Description -eq ""){
					if($Fix.HotFixID -eq "File 1"){	$arrHotFixes = $Fix.ServicePackInEffect+";"+$arrHotFixes }
					else { $arrHotFixes =$Fix.HotFixID+";"+$arrHotFixes }
				}
				else { $arrHotFixes = $Fix.Description+";"+$arrHotFixes }
			}
		}
#endRegion			

#region OS Serial Number
			# Create command to run
			$cmdOS = "Cscript.exe -nologo '$ScriptLocation\GetOSProductKey.vbs' $strComputer"
			$OSSerial = Invoke-Expression $cmdOS
#endregion

#region Get Computer Main OU
			# Create command to run
			$cmdOU = "Cscript.exe -nologo '$ScriptLocation\SearchComputers-ReturnADSPath.vbs' $strComputer"
			$MainOU = Invoke-Expression $cmdOU
			If($MainOU.Contains(","))
			{
				# CN=ComputerName,OU=LeafOU,OU=MainOU,DC=Company,DC=COM"
				# ------ 0 ------,--- 1 ---,--- 2 ---,---- 3 ----,-- 4 --
				$MainOU = $MainOU.Split(",")[-3].Replace("OU=","")
			}
#endregion

#region Remote Desktop Status
			# Collect Remote Desktop Protocol Status Using Remote Registry
			$RDPStatus = Get-Reg -Hive LocalMachine -remoteComputer $strComputer -Key "SYSTEM\CurrentControlSet\Control\Terminal Server" -Value "fDenyTSConnections"
			if($RDPStatus -eq 0) {$RDPStatus = "Enabled" } else {$RDPStatus = "Disabled" }
#endregion

#region Remote Assistance Status			
			# Collect Remote Assistance Status Using Remote Registry
			$RAStatus = Get-Reg -Hive LocalMachine -remoteComputer $strComputer -Key "SYSTEM\CurrentControlSet\Control\Terminal Server" -Value "fAllowToGetHelp"
			if($RAStatus -eq 1) {$RAStatus = "Enabled" } else {$RAStatus = "Disabled" }
#endregion
			
#region Check the Null Valued Paramters
			# If one of the Parameters are Null, Enter Space (looks better in the Table)
			if($ComputerDet -eq $Null){ $ComputerDet = "-"  }
			if($ChassisType -eq $Null){ $ChassisType = "-"  }
			if($BIOSSN -eq $Null){ $BIOSSN = "-"  }
			if($arrCPUNames -eq $Null -or $arrCPUNames -eq "();" ){ $arrCPUNames = "-"  }
			if($AvialableMem -eq $Null){ $AvialableMem = "-" }	
			if($MemSlotCount -eq $Null){ $MemSlotCount = "-" }
			if($arrMemSlots -eq $Null -or $arrMemSlots -eq ";"){ $arrMemSlots = "-" }
			if($OS -eq $Null){ $OS = "-"  }
			if($OSCaption -eq $Null){ $OSCaption = "-"  }
			if($OSSP -eq $Null){ $OSSP = "-"  }
			if($OSSerial -eq $Null){ $OSSerial = "-"  }
			if($arrIPAddress -eq $Null -or $arrIPAddress -eq "();" ){ $arrIPAddress = "-"  }
			if($arrMACAddress -eq $Null -or $arrMACAddress -eq ";" ){ $arrMACAddress = "-"  }
			if($arrHotFixes -eq $Null -or $arrHotFixes -eq "();" ){ $arrHotFixes = "-"  }
			if($arrDiskDrives -eq $Null -or $arrDiskDrives -eq "();" ){ $arrDiskDrives="-"  }
			if($arrDiskFreeSpace -eq $Null -or $arrDiskFreeSpace -eq "();" ){ $arrDiskFreeSpace="-"  }
			if($arrDiskSize -eq $Null -or $arrDiskSize -eq "();" ){ $arrDiskSize="-"  }
			if($arrNetDrives -eq $Null -or $arrNetDrives -eq "();" ){ $arrNetDrives="-"  }
			if($RDPStatus -eq $Null){ $RDPStatus = "-" }
			if($RAStatus -eq $Null){ $RAStatus = "-" }
			if($AUClient -eq $Null){ $AUClient = "-" }
			if($AVParentServer -eq $Null){ $AVParentServer = "-" }
			if($AVDefs -eq $Null){ $AVDefs = "-" }
			if($arrPrinters -eq $Null -or $arrPrinters -eq "();" ){ $arrPrinters = "-"  }
			if($ComputerTotalHealth -eq $Null){ $ComputerTotalHealth = "-"  }
			if($MainOU -eq $Null){ $MainOU = "-" }
			if($compCaption -eq $Null){ $compCaption = "-"  }
			if($compUserName -eq $Null){ $compUserName = "-"  }
			if($compDomainName -eq $Null){ $compDomainName = "-"  }
			if($compSysType -eq $Null){ $compSysType = "-"  }
			if($compNumProcessor -eq $Null){ $compNumProcessor = "0"  }
#endregion

#region Creating the Data Object - $DataObject
			# Create an Empty psObject, $DataObjcet - Used by this Name in the Join-Data Function
			$DataObject = New-Object psobject
			
			# Join all the Data to the DataObject
		if($scanWMI)
		{
			$ComputerDet | Join-Data | Out-Null # Contians Multiple Values, No need to Define a Name
		}
		else
		{
			$compCaption | Join-Data -objName "Caption" | Out-Null # String with no Values - Define a Name
			$compDomainName | Join-Data -objName "Domain" | Out-Null # String with no Values - Define a Name
			$compSysType | Join-Data -objName "SystemType" | Out-Null # String with no Values - Define a Name
			"-" | Join-Data -objName "Manufacturer" | Out-Null # String with no Values - Define a Name
			"-" | Join-Data -objName "Model" | Out-Null # String with no Values - Define a Name
			$compNumProcessor | Join-Data -objName "NumberOfProcessors" | Out-Null # String with no Values - Define a Name
			"-" | Join-Data -objName "TotalPhysicalMemory" | Out-Null # String with no Values - Define a Name
			$compUserName | Join-Data -objName "UserName" | Out-Null # String with no Values - Define a Name
		}
			$ChassisType | Join-Data -objName "Chassis Type" | Out-Null # String with no Values - Define a Name
		if($scanWMI)
		{
			$BIOSSN | Join-Data | Out-Null # Contians Multiple Values, No need to Define a Name
		}
		else
		{
			$BIOSSN | Join-Data -objName "SerialNumber" | Out-Null # String with no Values - Define a Name
		}
			$arrCPUNames | Join-Data -objName "CPU Names" | Out-Null # String with no Values - Define a Name
			$MemSlotCount | Join-Data | Out-Null # String with no Values - Define a Name
			$arrMemSlots | Join-Data -objName "MemSlots" | Out-Null # String with no Values - Define a Name
		if($scanWMI)
		{	
			$AvialableMem | Join-Data -objName "AvailableMem" | Out-Null # Contians Multiple Values, No need to Define a Name
			$OS.Caption | Join-Data -objName "Operating System" | Out-Null # Contians Multiple Values, Caption Value canot be overwritten - Define a Name to a certian Value
			$OS.CsdVersion | Join-Data -objName "Service Pack" | Out-Null # String with no Values - Define a Name
			$OS.LastBootupTime.ToString() | Join-Data -objName "LastBootUpTime" | Out-Null # String with no Values - Define a Name
		}
		else
		{
			"-" | Join-Data -objName "AvailableMBytes" | Out-Null # String with no Values - Define a Name
			$OSCaption | Join-Data -objName "Operating System" | Out-Null # Contians Multiple Values, Caption Value canot be overwritten - Define a Name to a certian Value
			$OSSP | Join-Data -objName "Service Pack" | Out-Null # String with no Values - Define a Name
		}
			$OSSerial | Join-Data -objName "CD-Key" | Out-Null # String with no Values - Define a Name
			$arrIPAddress | Join-Data -objName "IP Addresses" | Out-Null # String with no Values - Define a Name
			$arrMACAddress | Join-Data -objName "MAC Addresses" | Out-Null # String with no Values - Define a Name
			$arrHotFixes | Join-Data -objName "HotFixes" | Out-Null # String with no Values - Define a Name
			$arrDiskDrives | Join-Data -objName "Disk Drives" | Out-Null # String with no Values - Define a Name
			$arrDiskSize | Join-Data -objName "Disk Size" | Out-Null # String with no Values - Define a Name
			$arrDiskFreeSpace | Join-Data -objName "Disk Free Space" | Out-Null # String with no Values - Define a Name
			$arrNetDrives | Join-Data -objName "Network Disks" | Out-Null # String with no Values - Define a Name
			$RDPStatus.ToString() | Join-Data -objName "Remote Desktop" | Out-Null # String with no Values - Define a Name			
			$RAStatus.ToString()  | Join-Data -objName "Remote Assistance" | Out-Null # String with no Values - Define a Name
			$AUClient | Join-Data -objName "Automatic Updates" | Out-Null # String with no Values - Define a Name			
			$AVParentServer  | Join-Data -objName "Anti-Virus Server" | Out-Null # String with no Values - Define a Name
			$AVDefs.ToString() | Join-Data -objName "Anti-Virus Defs" | Out-Null # String with no Values - Define a Name
			$arrPrinters | Join-Data  -objName "Printers" | Out-Null # String with no Values - Define a Name
			$MainOU | Join-Data -objName "MainOU" | Out-Null # String with no Values - Define a Name
			$ComputerTotalHealth | Join-Data -objName "Computer Total Health" | Out-Null # String with no Values - Define a Name
#endregion
return @(,$dataObject)
}

Collect-data $Args[0] | export-clixml $home\CompDet.xml