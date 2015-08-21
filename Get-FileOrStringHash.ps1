#requires -version 2.0
Set-Alias sum Get-FileOrStringHash

function Get-FileOrStringHash {
  <#
    .EXAMPLE
        PS C:\> Get-Hash E:\src\foo
    .EXAMPLE
        PS C:\> "test string" | sum -h sha256 -en utf8
    .EXAMPLE
        PS C:\> gci . | sum -h ripemd160
  #>
  [CmdletBinding(DefaultParameterSetName="Path", SupportsShouldProcess=$true)]
  param(
    [Parameter(Mandatory=$true,
               ParameterSetName="Path",
               Position=0,
               ValueFromPipeline=$true,
               ValueFromPipelineByPropertyName=$true)]
    [String[]]$Path,
    
    [Parameter(Mandatory=$true,
               ParameterSetName="LiteralPath",
               Position=0)]
    [String[]]$LiteralPath,
    
    [Parameter(Position=1)]
    [ValidateSet("MD5", "SHA1", "SHA256", "SHA384", "SHA512", "RIPEMD160")]
    [String]$HashType = "MD5",
    
    [Parameter(Position=2)]
    [ValidateSet("Deafault", "ASCII", "UTF7", "UTF8", "UTF32", "BigEndianUnicode")]
    [String]$Encoding = "Default"
  )
  
  begin {
    if ($PSCmdlet.ParameterSetName -eq "Path") {
      $PipelineInput = -not $PSBoundParameters.ContainsKey("Path")
    }
    $ha = [Security.Cryptography.HashAlgorithm]::Create($HashType)
    
    function enc {
      switch ($Encoding) {
        "Default"          {return [Text.Encoding]::Default}
        "ASCII"            {return [Text.Encoding]::ASCII}
        "UTF7"             {return [Text.Encoding]::UTF7}
        "UTF8"             {return [Text.Encoding]::UTF8}
        "UTF32"            {return [Text.Encoding]::UTF32}
        "BigEndianUnicode" {return [Text.Encoding]::BigEndianUnicode}
      }
    }
    
    function res($itm) {
      $sb = New-Object Text.StringBuilder
      
      if ($itm -is [IO.FileInfo]) {
        if ($itm.Length -ne 0) {
          try {
            $str = [IO.File]::OpenRead($itm.FullName)
            $ha.ComputeHash($str) | % {[void]$sb.Append($_.ToString("x2"))}
          }
          finally {
            if ($str -ne $null) {$str.Close()}
          }
        }
        else {Write-Host $itm - file has null length. -no -fo Yellow}
      }
      else {
        $enc = enc
        $ha.ComputeHash(($enc.GetBytes([String]$itm))) | % {[void]$sb.Append($_.ToString("x2"))}
      }
      
      $sb.ToString()
    }
  }
  process {
    if ($PSCmdlet.ParameterSetName -eq "Path") {
      if ($PSCmdlet.ShouldProcess($Path, "Calculating $HashType hash")) {
        if ($PipelineInput) {res $_} else {gi -fo $Path | % {res $_}}
      }
    }
    else {
      if ($PSCmdlet.ShouldProcess($LiteralPath, "Calculating $HashType hash")) {
        $lp = gi -lit $LiteralPath
        if ($lp) {res $lp}
      }
    }
  }
  end {}
}