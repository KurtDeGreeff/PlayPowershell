if($Args) { 
	[string]$script:LocalStorageModuleName = $Args[0] 
} elseif($LocalStorageModuleName) { 
	[string]$script:LocalStorageModuleName = $LocalStorageModuleName
} else {
	[string]$script:LocalStorageModuleName = "LocalStorage" 
}

function Get-LocalStoragePath {
	#.Synopsis
	#   Gets the LocalApplicationData path for the specified company\module 
	#.Description
	#   Appends Company\Module to the LocalApplicationData, and ensures that the folder exists.
	param(
		# The name of the module you want to access storage for
		[Parameter(Position=0)]
		[ValidateScript({ 
			$invalid = $_.IndexOfAny([IO.Path]::GetInvalidFileNameChars())			
			if($invalid -eq -1){ 
				return $true
			} else {
				throw "Invalid character in Module Name '$_' at $invalid"
			}
		})]			
		[string]$Module = $LocalStorageModuleName,

		# The name of a "company" to use in the storage path (defaults to "Huddled")
		[Parameter(Position=1)]
		[ValidateScript({ 
			$invalid = $_.IndexOfAny([IO.Path]::GetInvalidFileNameChars())			
			if($invalid -eq -1){ 
				return $true
			} else {
				throw "Invalid character in Company Name '$_' at $invalid"
			}
		})]			
		[string]$Company = "Huddled"		

	)
	end {
		
		$path = Join-Path ([Environment]::GetFolderPath("LocalApplicationData")) $Company
		$path  = Join-Path $path $Module

		if(!(Test-Path $path -PathType Container)) {
			$null = New-Item $path -Type Directory -Force
		}
		$script:LocalStorageModuleName = $Module
		Write-Output $path
	}
}

function Export-LocalStorage {
	#.Synopsis
	#   Saves the object to local storage with the specified name
	#.Description
	#   Persists objects to disk using Get-LocalStoragePath and Export-CliXml
	param(
		# A unique valid file name to use when persisting the object to disk
		[Parameter(Mandatory=$true, Position=0)]
		[ValidateScript({ 
			$invalid = $_.IndexOfAny([IO.Path]::GetInvalidFileNameChars())			
			if($invalid -eq -1){ 
				return $true
			} else {
				throw "Invalid character in Object Name '$_' at $invalid"
			}
		})]		
		[string]$name,

		# The object to persist to disk
		[Parameter(Mandatory=$true, Position=1, ValueFromPipeline=$true)]
		$InputObject,

		# A unique valid module name to use when persisting the object to disk
		[Parameter(Position=2)]
		[ValidateScript({ 
			$invalid = $_.IndexOfAny([IO.Path]::GetInvalidFileNameChars())			
			if($invalid -eq -1){ 
				return $true
			} else {
				throw "Invalid character in Module Name '$_' at $invalid"
			}
		})]		
		[string]$Module = $LocalStorageModuleName
	)
	begin {
		$path = Join-Path (Get-LocalStoragePath $Module) $Name
		if($PSBoundParameters.ContainsKey("InputObject")) {
			Write-Verbose "Clean Export"
			Export-CliXml -Path $Path -InputObject $InputObject
		} else {
			$Output = @()
		}
	}
	process {
		$Output += $InputObject
	}
	end {
		if($PSBoundParameters.ContainsKey("InputObject")) {
			Write-Verbose "Tail Export"
			# Avoid arrays when they're not needed:
			if($Output.Count -eq 1) { $Output = $Output[0] }
			Export-CliXml -Path $Path -InputObject $Output
		}
	}
}

function Import-LocalStorage {
	#.Synopsis
	#   Loads an object with the specified name from local storage 
	#.Description
	#   Retrieves objects from disk using Get-LocalStoragePath and Import-CliXml
	param(
		# A unique valid file name to use when persisting the object to disk
		[Parameter(Mandatory=$true, Position=0)]
		[ValidateScript({ 
			$invalid = $_.IndexOfAny([IO.Path]::GetInvalidFileNameChars())			
			if($invalid -eq -1){ 
				return $true
			} else {
				throw "Invalid character in Object Name '$_' at $invalid"
			}
		})]		
		[string]$name,

		# A unique valid module name to use when persisting the object to disk
		[Parameter(Position=1)]
		[ValidateScript({ 
			$invalid = $_.IndexOfAny([IO.Path]::GetInvalidFileNameChars())			
			if($invalid -eq -1){ 
				return $true
			} else {
				throw "Invalid character in Module name '$_' at $invalid"
			}
		})]		
		[string]$Module = $LocalStorageModuleName,

		# A default value (used in case there's an error importing):
		[Parameter(Position=2)]
		[Object]$DefaultValue
	)
	begin {
		if($PSBoundParameters.ContainsKey("Module")) {
			$script:LocalStorageModuleName = $Module
		}
	}
	end {
		try {
			$path = Join-Path (Get-LocalStoragePath $Module) $Name
			Import-CliXml -Path $Path
		} catch {
			if($PSBoundParameters.ContainsKey("DefaultValue")) {
				Write-Output $DefaultValue
			} else {
				throw
			}
		}
	}
}

Export-ModuleMember -Function Import-LocalStorage, Export-LocalStorage, Get-LocalStoragePath -Variable LocalStorageModuleName