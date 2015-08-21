
<#
.SYNOPSIS
   <A brief description of the script>
.DESCRIPTION
   <A detailed description of the script>
.PARAMETER <paramName>
   <Description of script parameter>
.EXAMPLE
   <An example of using the script>
#>

function Add-FileDetails {
 param(
 [Parameter(ValueFromPipeline=$true)]
 $fileobject,
 $hash = @{Artists = 13; Album = 14; Year = 15; Genre = 16; Title = 21; Length = 27; Bitrate = 28}
 )
 begin { 
  $shell = New-Object -COMObject Shell.Application 


 }
 process {
  if ($_.PSIsContainer -eq $false) {
   $folder = Split-Path $fileobject.FullName
   $file = Split-Path $fileobject.FullName -Leaf
   $shellfolder = $shell.Namespace($folder)
   $shellfile = $shellfolder.ParseName($file)
   Write-Progress 'Adding Properties' $fileobject.FullName
   $hash.Keys | 
   ForEach-Object {
    $property = $_
    $value = $shellfolder.GetDetailsOf($shellfile, $hash.$property)
    if ($value -as [Double]) { $value = [Double]$value }
    $fileobject | Add-Member NoteProperty "Extended_$property" $value -force
   }
  }



  $fileobject
 }
}

#Sample call:
#$music = [system.Environment]::GetFolderPath('MyMusic')
#$list = dir $music -Recurse | Add-FileDetails 
#$list | Where-Object { $_.Extended_Year } | Sort-Object Extended_Year | Select-Object Name, Extended_Year, Extended_Album, Extended_Artists
$new2 | where {$_.Extended_Album} | select Name,Extended_Album | sort Extended_Album 
