# Get-FileHash.ps1 

 
#requires -version 2 
 
<# 
.SYNOPSIS 
Outputs the MD5 or SHA1 hash for one or more files. 
 
.DESCRIPTION 
Outputs the MD5 or SHA1 hash for one or more files. 
 
.PARAMETER Path 
Specifies the path to one or more files. Wildcards are permitted. 
 
.PARAMETER LiteralPath 
Specifies a path to the file. Unlike Path, the value of LiteralPath is used exactly as it is typed. No 
characters are interpreted as wildcards. If the path includes escape characters, enclose it in single 
quotation marks. 
 
.PARAMETER HashType 
The hash type to compute; either MD5 or SHA1. The default is MD5. 
 
.INPUTS 
System.String, System.IO.FileInfo 
 
.OUTPUTS 
PSObjects containing the file paths and hash values 
 
.EXAMPLE 
PS C:\> Get-FileHash C:\Windows\Notepad.exe 
Outputs the MD5 hash for the specified file. 
 
.EXAMPLE 
PS C:\> Get-FileHash C:\Windows\Explorer.exe,C:\Windows\Notepad.exe -HashType SHA1 
Outputs the SHA1 hash for the specified files. 
 
.EXAMPLE 
PS C:\> Get-ChildItem C:\Scripts\*.ps1 | Get-FileHash 
Outputs the MD5 hash for the specified files. 
 
.EXAMPLE 
PS C:\> Get-FileHash Download1.exe,Download2.exe -HashType SHA1 
Outputs the SHA1 hash for two files. You can compare the hash values to determine if the files are 
identical. 
#> 
 
[CmdletBinding(DefaultParameterSetName="Path")] 
param( 
  [Parameter(ParameterSetName="Path",Position=0,Mandatory=$TRUE,ValueFromPipeline=$TRUE)] 
    [String[]] $Path, 
  [Parameter(ParameterSetName="LiteralPath",Position=0,Mandatory=$TRUE)] 
    [String[]] $LiteralPath, 
  [Parameter(Position=1)] 
    [String] $HashType="MD5" 
) 
 
begin { 
  switch ($HashType) { 
    "MD5" { 
      $Provider = new-object System.Security.Cryptography.MD5CryptoServiceProvider 
      break 
    } 
    "SHA1" { 
      $Provider = new-object System.Security.Cryptography.SHA1CryptoServiceProvider 
      break 
    } 
    default { 
      throw "HashType must be one of the following: MD5 SHA1" 
    } 
  } 
 
  # If the Path parameter is not bound, assume input comes from the pipeline. 
  if ($PSCMDLET.ParameterSetName -eq "Path") { 
    $PIPELINEINPUT = -not $PSBOUNDPARAMETERS.ContainsKey("Path") 
  } 
 
  # Returns an object containing the file's path and its hash as a hexadecimal string. 
  # The Provider object must have a ComputeHash method that returns an array of bytes. 
  function get-filehash2($file) { 
    if ($file -isnot [System.IO.FileInfo]) { 
      write-error "'$($file)' is not a file." 
      return 
    } 
    $hashstring = new-object System.Text.StringBuilder 
    $stream = $file.OpenRead() 
    if ($stream) { 
      foreach ($byte in $Provider.ComputeHash($stream)) {
        [Void] $hashstring.Append($byte.ToString("X2"))
      } 
      $stream.Close() 
    } 
    "" | select-object @{Name="Path"; Expression={$file.FullName}}, 
      @{Name="$($Provider.GetType().BaseType.Name) Hash"; Expression={$hashstring.ToString()}} 
  } 
} 
 
process { 
  if ($PSCMDLET.ParameterSetName -eq "Path") { 
    if ($PIPELINEINPUT) { 
      get-filehash2 $_ 
    } 
    else { 
      get-item $Path -force | foreach-object { 
        get-filehash2 $_ 
      } 
    } 
  } 
  else {
    $file = get-item -literalpath $LiteralPath 
    if ($file) {
      get-filehash2 $file
    } 
  } 
} 

