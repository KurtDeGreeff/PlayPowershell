$pinToStart = "Pin to Start"
$pinToTaskbar = "Pin to Taskbar"
$file = @((Join-Path -Path $PSHOME -ChildPath "powershell.exe"),
          (Join-Path -Path $PSHOME -ChildPath "Powershell_ise.exe"))
<#$file = "$home\Downloads\adksetup.exe"#>
foreach ($f in $file){
  $path = Split-Path $f
  $shell = New-Object -ComObject "Shell.application"
  $folder = $shell.Namespace($path)
  $item = $folder.parsename((Split-Path $f -Leaf))
  $verbs = $item.verbs()
  foreach($v in $verbs)
    {if($v.Name.Replace("&","") -match $pinToStart) {$v.DoIt()}}
    {if($v.Name.Replace("&","") -match $pinToTaskBar) {$v.DoIt()}}
}

