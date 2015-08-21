#Pin Apps to Taskbar
$pintotaskbar = New-Object -ComObject Shell.application
$pintotaskbar.NameSpace("${env:ProgramFiles(x86)}\Kaspersky Lab\Kaspersky Endpoint Security 10 for Windows").ParseName("avp.exe").InvokeVerb("Taskbarpin")
