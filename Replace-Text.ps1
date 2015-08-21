$oldfile = "$env:windir\WindowsUpdate.log"
$newfile = "$env:temp\newfile.txt"
$text = Get-Content -Path $oldfile -Raw
$text -replace 'error', 'ALERT' | Set-Content -Path $newfile
Invoke-Item -Path $newfile