filter Find-Function
{
   $path = $_.FullName
   $lastwrite = $_.LastWriteTime
   $text = Get-Content -Path $path
  
   if ($text.Length -gt 0)
   {
     
      $token = $null
      $errors = $null
      $ast = [System.Management.Automation.Language.Parser]::ParseInput($text, [ref] $token, [ref] $errors)
      $ast.FindAll({ $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true) |
      Select-Object -Property Name, Path, LastWriteTime |
      ForEach-Object {
         $_.Path = $path
         $_.LastWriteTime = $lastwrite
         $_
      }
   }
}

# Scan userprofile to find scripts with all functions
# dir $home -Filter *.ps1 -Recurse -Exclude *.ps1xml | Find-Function