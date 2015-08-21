#Requires -version 3.0
whoami /groups /fo list | Select -Skip 4 | Where {$_} |
foreach-object -Begin {$i=0; $hash=@{}} -Process {
if ($i -ge 4) {
#turn the hash table into an object
[PSCustomObject]$hash
$hash.Clear()
$i=0
}
else {
$data=$_ -split ":"
$hash.Add($data[0].Replace(" ",""),$data[1].Trim())
$i++
}
}