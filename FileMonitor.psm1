function Remove-FileMonitor {
	<#
	.SYNOPSIS
		This function removes a file monitor (permanent WMI event consumer)
	.PARAMETER InputObject
    	An object with Filter, Binding and Consumer properties
		that represents a file monitor retrieved from Get-FileMonitor
	.EXAMPLE
		PS> Get-FileMonitor 'CopyMyFile' | Remove-FileMonitor
	
		This example removes the file monitor called CopyMyFile.
	#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory,ValueFromPipeline)]
		[System.Object]$InputObject
	)
	process {
		try {
			$InputObject.Filter | Remove-WmiObject
			$InputObject.Consumer | Remove-WmiObject
			Get-WmiObject -Class '__filtertoconsumerbinding' -Namespace 'root\subscription' -Filter "Filter = ""__eventfilter.name='$($InputObject.Filter.Name)'""" | Remove-WmiObject
		} catch {
			Write-Error $_.Exception.Message
		}
	}
}

function New-FileMonitor {
	<#
	.SYNOPSIS
		This function creates a file monitor (permanent WMI event consumer)
	.PARAMETER Name
    	The name of the file monitor.  This will be the name of both the WMI event filter
		and the event consumer.
	.PARAMETER MonitorInterval
		The number of seconds between checks
	.PARAMETER FolderPath
		The complete path of the folder you'd like to monitor
	.PARAMETER ScriptFilePath
		The VBS script that will execute if a file is detected in the folder
	#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory)]
		[string]$Name,
		[Parameter(Mandatory)]
		[string]$MonitorInterval,
		[Parameter(Mandatory)]
		[string]$FolderPath,
		[Parameter(Mandatory)]
		[ValidateScript({ Test-Path -Path $_ -PathType 'Leaf' })]
		[ValidatePattern('.*\.vbs')]
		[string]$ScriptFilePath
	)
	process {
		try {
			## Break apart the drive and path to meet WMI specs
			$Drive = $FolderPath | Split-Path -Qualifier
			$FolderPath = "$($FolderPath | Split-Path -NoQualifier)\".Replace('\', '\\')
			
			$WmiEventFilterQuery = "
	 			SELECT * FROM __InstanceCreationEvent WITHIN $MonitorInterval
	 			WHERE targetInstance ISA 'CIM_DataFile' 
	 			AND targetInstance.Drive = `"$Drive`"
				AND targetInstance.Path = `"$FolderPath`""
			
			$WmiFilterParams = @{
				'Class' = '__EventFilter'
				'Namespace' = 'root\subscription'
				'Arguments' = @{ Name = $Name; EventNameSpace = 'root\cimv2'; QueryLanguage = 'WQL'; Query = $WmiEventFilterQuery }
			}
			Write-Verbose -Message "Creating WMI event filter using query '$WmiEventFilterQuery'"
			$WmiEventFilterPath = Set-WmiInstance @WmiFilterParams
			
			$WmiConsumerParams = @{
				'Class' = 'ActiveScriptEventConsumer'
				'Namespace' = 'root\subscription'
				'Arguments' = @{ Name = $Name; ScriptFileName = $ScriptFilePath; ScriptingEngine = 'VBscript' }
			}
			Write-Verbose -Message "Creating WMI consumer using script file name $ScriptFilePath"
			$WmiConsumer = Set-WmiInstance @WmiConsumerParams
			
			$WmiFilterConsumerParams = @{
				'Class' = '__FilterToConsumerBinding'
				'Namespace' = 'root\subscription'
				'Arguments' = @{ Filter = $WmiEventFilterPath; Consumer = $WmiConsumer }
			}
			Write-Verbose -Message "Creating WMI filter consumer using filter $WmiEventFilterPath"
			Set-WmiInstance @WmiFilterConsumerParams | Out-Null
		} catch {
			Write-Error $_.Exception.Message	
		}
	}
}

function Get-FileMonitor {
	<#
	.SYNOPSIS
		This function gets a file monitor (permanent WMI event consumer)
	.PARAMETER Name
    	The name of the file monitor.  This will be the name of both the WMI event filter
		and the event consumer.
	#>
	[CmdletBinding()]
	param (
		[string]$Name
	)
	process {
		try {
			$Monitor = @{ }
			$BindingParams = @{ 'Namespace' = 'root\subscription'; 'Class' = '__FilterToConsumerBinding' }
			$FilterParams = @{ 'Namespace' = 'root\subscription'; 'Class' = '__EventFilter' }
			$ConsumerParams = @{ 'Namespace' = 'root\subscription'; 'Class' = 'ActiveScriptEventConsumer' }
			if ($Name) {
				$BindingParams.Filter = "Consumer = 'ActiveScriptEventConsumer.Name=`"$Name`"'"
				$FilterParams.Filter = "Name = '$Name'"
				$ConsumerParams.Filter = "Name = '$Name'"
			}
			$Monitor.Binding = Get-WmiObject @BindingParams
			$Monitor.Filter = Get-WmiObject @FilterParams
			$Monitor.Consumer = Get-WmiObject @ConsumerParams
			if (($Monitor.Values | where { $_ }).Count -eq $Monitor.Keys.Count) {
				[pscustomobject]$Monitor
			} elseif (($Monitor.Values | where { !$_ }).Count -eq $Monitor.Keys.Count) {
				$null
			} else {
				throw 'Mismatch between binding, filter and consumer names exists'	
			}
		} catch {
			Write-Error $_.Exception.Message
		}
	}
}