Function Get-IndexedItem{
Param ( [Alias("Where","Include")][String[]]$Filter ,
        [Alias("Sort")][String[]]$OrderBy,
        [Alias("Top")][String[]]$First,
        [String]$Path,
        [Switch]$Recurse )
 
if ($First)  {$SQL = "SELECT TOP $First "}
else         {$SQL = "SELECT "}
$SQL += " System.ItemName, System.ItemUrl " # and the other 58 fields
 
if ($Path -match "\\\\([^\\]+)\\.") {
      $SQL += "FROM $($matches[1]).SYSTEMINDEX WHERE "
}
else {$SQL += " FROM SYSTEMINDEX WHERE "}
 
if ($Filter) { $SQL += $Filter -join " AND "}
 
if ($Path)   {
    if ($Path -notmatch "\w{4}:")  {$Path = "file:" + $Path}
    $Path = $Path -replace "\\","/"
    if ($SQL -notmatch "WHERE\s*$") {$SQL += " AND " }
    if ($Recurse)                   {$SQL += " SCOPE = '$Path' "    }
    else                            {$SQL += " DIRECTORY = '$Path' "}
}
 
if ($SQL -match "WHERE\s*$")  {
   Write-Warning "You need to specify either a path or a filter."
   Return
}
if ($OrderBy) { $SQL += " ORDER BY " + ($OrderBy   -join " , " ) }
 
$Provider="Provider=Search.CollatorDSO;Extended Properties=’Application=Windows’;"
$Adapter = New-Object system.data.oledb.oleDBDataadapter -argument $SQL, $Provider
$DS      = New-Object system.data.dataset
if ($Adapter.Fill($DS)) { $DS.Tables[0] }
}
