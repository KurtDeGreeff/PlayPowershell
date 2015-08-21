#========================================================================
# Created with: SAPIEN Technologies, Inc., PowerShell Studio 2012 v3.1.19
# Created on:   6/12/2013 5:41 PM
# Created by:   Paul DeArment
# Organization:  
# Filename:     Get-PrinterInventory.ps1 V2
#========================================================================

function Get-PrinterInventory
{
	<#
	.Synopsis
	Retrieves list of printers from the provided list of print servers
	
	.Description
	Get-PrinterInventory uses System.printing and wmi to retrieve information about print ques on the print servers in VCPI.  Specify computers by name or by ip address.
	
	.Parameter ComputerName
	One or more computer names or ip addresses
	
	.Example
	Get-PrinterInventory -Computername Server1,Server2
	
	.Example
	Import-csv printers.csv | Get-PrinterInventory
	#>
	
	[CmdletBinding()]
	Param(
		[Parameter(
		Mandatory = $true,
		HelpMessage="The print server to gather information from",
		valuefrompipeline=$true,
		valuefrompipelinebypropertyname=$true,
		Position = 1)]
		[ValidateNotNullorEmpty()]
		[Alias("printserver","hostname","server")]
		[string[]]$computername
	)
	Begin{
		Add-Type -AssemblyName System.printing
	}
	Process{
		$error.clear()
		foreach($computer in $computername)
		{
			try{
				$holding_object = (New-Object system.Printing.PrintServer("\\$($computer)")).getprintqueues() | select name,location,comment,queueport,queuedriver,isshared,sharename,queueprintprocessor
				}
				catch{
					Write-Warning "Unable to retrieve data from $computer"
				}
				foreach($printer in $holding_object)
				{
					try{
						$retrieved_ports = $null
						[wmi]$retrieved_ports = "\\$computer\root\cimv2:Win32_TCPIPPrinterPort.Name='$($printer.queueport.name)'"
						$output_object = @{Name=$printer.name;
										Location=$printer.location;
										Comment=$printer.comment;
										QueuePort=$printer.queueport.name;
										IPAddress=$retrieved_ports.hostaddress;
										QueueDriver = $printer.QueueDriver.name;
										IsShared = $printer.isshared;
										sharename = $printer.sharename;
										QueuePrintProcessor = $printer.queuePrintProcessor.name;
										PrintServer = $computer;
										error=""
						}
						$obj = New-Object -TypeName PSObject -Property $output_object
						$obj.psobject.typenames.insert(0,'OE.PrinterInventory')
						Write-Output $obj
					}
					catch
					{
						$output_object_error = @{Name=$printer.name;
												Location="";
												Comment="";
												QueuePort="";
												IPAddress="";
												QueueDriver = "";
												IsShared = "";
												sharename = "";
												QueuePrintProcessor = "";
												PrintServer = $computer;
												error="Unable to retrieve information for printer $($printer.name)"
											}
						$obj_error = New-Object -TypeName PSObject -Property $output_object_error
						$obj_error.psobject.typenames.insert(0,'OE.PrinterInventory')
						Write-Output $obj_error
						
					}
				}
		}
	}
	End{}
}