Function Invoke-ElevatedCommand {
	<#
		.DESCRIPTION
			Invokes the provided script block in a new elevated (Administrator) powershell process, 
			while retaining access to the pipeline (pipe in and out). Please note, "Write-Host" output
			will be LOST - only the object pipeline and errors are handled. In general, prefer 
			"Write-Output" over "Write-Host" unless UI output is the only possible use of the information.
			Also see Community Extensions "Invoke-Elevated"/"su"

		.EXAMPLE
			Invoke-ElevatedCommand {"Hello World"}

		.EXAMPLE
			"test" | Invoke-ElevatedCommand {$input | Out-File -filepath c:\test.txt}

		.EXAMPLE
			Invoke-ElevatedCommand {$one = 1; $zero = 0; $throwanerror = $one / $zero}

		.PARAMETER Scriptblock
			A script block to be executed with elevated priviledges.

		.PARAMETER InputObject
			An optional object (of any type) to be passed in to the scriptblock (available as $input)

		.PARAMETER EnableProfile
			A switch that enables powershell profile loading for the elevated command/block

		.PARAMETER DisplayWindow
			A switch that enables the display of the spawned process (for potential interaction)

		.SYNOPSIS
			Invoke a powershell script block as Administrator

		.NOTES
			Originally from "Windows PowerShell Cookbook" (O'Reilly), by Lee Holmes, September 2010
				at http://poshcode.org/2179
			Modified by obsidience for enhanced error-reporting, October 2010
				at http://poshcode.org/2297
			Modified by Tao Klerks for code formatting, enhanced/fixed error-reporting, and interaction/hanging options, January 2012
				at https://gist.github.com/gists/1582185
				and at http://poshcode.org/, followup to http://poshcode.org/2297
			SEE ALSO: "Invoke-Elevated" (alias "su") in PSCX 2.0 - simpler "just fire" elevated process runner.
	#>

	param
	(
		## The script block to invoke elevated. NOTE: to access the InputObject/pipeline data from the script block, use "$input"!
		[Parameter(Mandatory = $true)]
		[ScriptBlock] $Scriptblock,
	 
		## Any input to give the elevated process
		[Parameter(ValueFromPipeline = $true)]
		$InputObject,
	 
		## Switch to enable the user profile
		[switch] $EnableProfile,
	 
		## Switch to display the spawned window (as interactive)
		[switch] $DisplayWindow
	)
	 
	begin
	{
		Set-StrictMode -Version Latest
		$inputItems = New-Object System.Collections.ArrayList
	}
	 
	process
	{
		$null = $inputItems.Add($inputObject)
	}
	 
	end
	{

		## Create some temporary files for streaming input and output
		$outputFile = [IO.Path]::GetTempFileName()	
		$inputFile = [IO.Path]::GetTempFileName()
		$errorFile = [IO.Path]::GetTempFileName()

		## Stream the input into the input file
		$inputItems.ToArray() | Export-CliXml -Depth 1 $inputFile
	 
		## Start creating the command line for the elevated PowerShell session
		$commandLine = ""
		if(-not $EnableProfile) { $commandLine += "-NoProfile " }

		if(-not $DisplayWindow) { 
			$commandLine += "-Noninteractive " 
			$processWindowStyle = "Hidden" 
		}
		else {
			$processWindowStyle = "Normal" 
		}
	 
		## Convert the command into an encoded command for PowerShell
		$commandString = "Set-Location '$($pwd.Path)'; " +
			"`$output = Import-CliXml '$inputFile' | " +
			"& {" + $scriptblock.ToString() + "} 2>&1 ; " +
			"Out-File -filepath '$errorFile' -inputobject `$error;" +
			"Export-CliXml -Depth 1 -In `$output '$outputFile';"
	 
		$commandBytes = [System.Text.Encoding]::Unicode.GetBytes($commandString)
		$encodedCommand = [Convert]::ToBase64String($commandBytes)
		$commandLine += "-EncodedCommand $encodedCommand"

		## Start the new PowerShell process
		$process = Start-Process -FilePath (Get-Command powershell).Definition `
			-ArgumentList $commandLine `
			-Passthru `
			-Verb RunAs `
			-WindowStyle $processWindowStyle

		$process.WaitForExit()

		$errorMessage = $(gc $errorFile | Out-String)
		if($errorMessage) {
			Write-Error -Message $errorMessage
		}
		else {
			## Return the output to the user
			if((Get-Item $outputFile).Length -gt 0)
			{
				Import-CliXml $outputFile
			}
		}

		## Clean up
		Remove-Item $outputFile
		Remove-Item $inputFile
		Remove-Item $errorFile
	}
}