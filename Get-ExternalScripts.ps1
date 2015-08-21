#requires -version 2
param(
	$fileName=$(throw "please specify a PowerShell file")
)

function Get-ExternalScripts($p,$t=0) {
	$content = [IO.File]::ReadAllText( ( Resolve-Path $p ))
	$tokens  =
	  [System.Management.Automation.PsParser]::Tokenize($content, [ref] $null)

	$t+=3

	$externalScripts = $tokens |
		Where {$_.type -match 'command'} |
			ForEach { Get-Command `
			  -ErrorAction silentlycontinue `
			  $_.content `
			  -CommandType ExternalScript }

	if($externalScripts) {
		$externalScripts |
			ForEach {
				write-host -no (" " * $t)
				write-host (Split-Path -Leaf $_.Definition)
				Get-ExternalScripts $_.Definition ($t)
			}
	}
}

(Split-Path -Leaf $fileName)
Get-ExternalScripts $fileName