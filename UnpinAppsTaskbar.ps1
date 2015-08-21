#UnPin Apps from Taskbar
$pintotaskbar = New-Object -ComObject Shell.application
$pintotaskbar.NameSpace("$env:ProgramFiles\Internet Explorer").ParseName("iexplore.exe").InvokeVerb("Taskbarunpin")
$pintotaskbar.NameSpace("$env:ProgramFiles\Windows Media Player").ParseName("wmplayer.exe").InvokeVerb("Taskbarunpin")


