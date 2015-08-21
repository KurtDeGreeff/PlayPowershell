function Get-TheAwesome {
	[CmdletBinding()]
	param ()
	DynamicParam {
		New-ValidationDynamicParam -Name 'MyParameter' -Mandatory -ValidateSetOptions (Get-ChildItem C:\TheAwesome -File | Select-Object -ExpandProperty Name)
	}
	begin {
		## Create variables for each dynamic parameter.  If this wasn't done you'd have to reference
		## any dynamic parameter as the key in the $PsBoundParameters hashtable.
		$PsBoundParameters.GetEnumerator() | foreach { New-Variable -Name $_.Key -Value $_.Value -ea 'SilentlyContinue' }
	}
	process {
		try {
			## Do stuff in here	
		} catch {
			Write-Error $_.Exception.Message
		}
	}
}

function New-ValidationDynamicParam {
	[CmdletBinding()]
	[OutputType('System.Management.Automation.RuntimeDefinedParameter')]
	param (
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$Name,
		[ValidateNotNullOrEmpty()]
		[Parameter(Mandatory)]
		[array]$ValidateSetOptions,
		[switch]$Mandatory,
		[string]$ParameterSetName = '__AllParameterSets',
		[switch]$ValueFromPipeline,
		[switch]$ValueFromPipelineByPropertyName
	)
	
	$AttribColl = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
	$ParamAttrib = New-Object System.Management.Automation.ParameterAttribute
	$ParamAttrib.Mandatory = $Mandatory.IsPresent
	$ParamAttrib.ParameterSetName = $ParameterSetName
	$ParamAttrib.ValueFromPipeline = $ValueFromPipeline.IsPresent
	$ParamAttrib.ValueFromPipelineByPropertyName = $ValueFromPipelineByPropertyName.IsPresent
	$AttribColl.Add($ParamAttrib)
	$AttribColl.Add((New-Object System.Management.Automation.ValidateSetAttribute($ValidateSetOptions)))
	$RuntimeParam = New-Object System.Management.Automation.RuntimeDefinedParameter($Name, [string], $AttribColl)
	$RuntimeParamDic = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
	$RuntimeParamDic.Add($Name, $RuntimeParam)
	$RuntimeParamDic
	
}