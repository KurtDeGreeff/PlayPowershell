param(
	$files,
	[switch] $recurse
)

$parser = [System.Management.Automation.PsParser]

if($recurse) {
	$files=(dir . -Recurse *.ps1)
} else {
	if(!$files) {throw "Please enter a file for scanning."}
	if($files -is [String]) {$files=(dir $files)}
}

ForEach($file in $files) {
  $parser::Tokenize((Get-Content $file.FullName), [ref] $null) |
  ForEach {
    $PSToken = $_

    if($PSToken.Type -eq  'Keyword' -and
       $PSToken.Content -eq 'Function' ) {
       $functionKeyWordFound = $true
    }

    if($functionKeyWordFound -and
       $PSToken.Type -eq  'CommandArgument') {

       '' | Select `
        @{
					Name="FunctionName"
					Expression={$PSToken.Content}
				},
				@{
					Name="Line"
					Expression={$PSToken.StartLine}
				},
				@{
					Name="File"
					Expression={$file.FullName}
				}

				$functionKeyWordFound = $false
			}
		}
}