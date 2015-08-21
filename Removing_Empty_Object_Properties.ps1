<#Objects hold a lot of information and often, properties can also have null values. 
To reduce an object to only those properties that actually have a value, 
you can convert the object into a hash table and remove all empty properties, 
then turn the hash table back into an object. 
This also gives you the opportunity of sorting object property names.
This example will read BIOS information from the WMI 
and then return an object stripped of all empty properties. 
The code requires PowerShell 3.0:

Note the use of the System.Collections.Specialized.OrderedDictionary type: 
it creates a special ordered hash table. 
Regular hash tables do not keep a specific order in their keys.
#>
$bios = Get-WmiObject -Class Win32_BIOS
$hashtable = $bios |
Get-Member -MemberType *Property |
Select-Object -ExpandProperty Name |
Sort-Object |
ForEach-Object -Begin {
  [System.Collections.Specialized.OrderedDictionary]$rv=@{}
  } -process {
  if ($bios.$_ -eq $null)
  {
    Write-Warning "Removing empty property $_"
  }
  else
  {
    $rv.$_ = $bios.$_
  }
} -end {$rv}
$biosNew = New-Object PSObject
$biosNew | Add-Member ($hashtable) -ErrorAction SilentlyContinue
 
$biosNew