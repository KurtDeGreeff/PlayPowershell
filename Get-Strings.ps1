#requires -version 2.0
function Get-Strings {
  <#
    .SYNOPSIS
        Searches strings in a file.
    .EXAMPLE
        PS C:\> Get-Strings app.exe -b 100 -f 20
        !This program cannot be run in DOS mode.
    .EXAMPLE
        PS C:\> Get-String app.exe -n 7 -u -o
        36270:License Agreement
        36288:MS Shell Dlg
        ...
    .OUTPUTS
        Array <Object[]>
    .NOTES
        Author: greg zakharov
  #>
  param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
    [ValidateScript({Test-Path $_})]
    [String]$FileName,
    
    [Alias('b')]
    [UInt32]$BytesToProcess = 0,
    
    [Alias('f')]
    [UInt32]$BytesOffset = 0,
    
    [Alias('n')]
    [UInt32]$StringLength = 3,
    
    [Alias('o')]
    [Switch]$StringOffset,
    
    [Alias('u')]
    [Switch]$Unicode
  )
  
  begin {
    $FileName = Convert-Path $FileName
    
    $enc = switch ($Unicode) {
      $true  {[Text.Encoding]::Unicode}
      $false {[Text.Encoding]::UTF7}
    }
    
    function Read-Buffer([Byte[]]$Bytes) {
      ([Regex]"[\x20-\x7E]{$StringLength,}").Matches(
        $enc.GetString($Bytes)
      ) | % {if($StringOffset){'{0}:{1}' -f $_.Index, $_.Value}else{$_.Value}}
    }
  }
  process {
    try {
      $fs = [IO.File]::OpenRead($FileName)
      #throw condition
      if ($BytesToProcess -ge $fs.Length -or $BytesOffset -ge $fs.Length) {
        throw (New-Object IO.IOException('Out of stream.'))
      }
      #offset condition
      if ($BytesOffset -gt 0) {[void]$fs.Seek($BytesOffset, [IO.SeekOrigin]::Begin)}
      #bytes to process
      $buf = switch ($BytesToProcess -gt 0) {
        $true  {New-Object "Byte[]" ($fs.Length - ($fs.Length - $BytesToProcess))}
        $false {New-Object "Byte[]" $fs.Length}
      }
      [void]$fs.Read($buf, 0, $buf.Length)
      Read-Buffer $buf
    }
    catch { $_.Exception }
    finally {
      if ($fs -ne $null) { $fs.Close() }
    }
  }
  end {''}
}
