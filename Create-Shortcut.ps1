$wshshell = New-Object -com wscript.shell
$path = $wshshell. SpecialFolders.Item( "sendto")
$shortcutPath = Join-Path -Path $path -ChildPath "Chrome.lnk"
$shortcut = $wshshell. CreateShortcut($shortcutPath)
$shortcut.TargetPath = "C:\Users\Kurt\AppData\Local\Google\Chrome\Application\chrome.exe"
$shortcut.Description = "Chrome by Powershell 3.0"
$shortcut.Save() 


$shell = New-Object -ComObject WScript.Shell
$desktop = [System.Environment]::GetFolderPath(‘Desktop’)
$shortcut = $shell.CreateShortcut(“$desktop\clickme.lnk”)
$shortcut.TargetPath = ”notepad.exe”
$shortcut.IconLocation = ”shell32.dll,23”
$shortcut.Save()

function Get-Shortcut {
$obj = New-Object -ComObject WScript.Shell
$pathUser = [System.Environment]::GetFolderPath('StartMenu')
$pathCommon = $obj.SpecialFolders.Item('AllUsersStartMenu')
dir $pathUser, $pathCommon -Filter *.lnk -Recurse |
ForEach-Object {
$link = $obj.CreateShortcut($_.FullName)

$info = @{}
$info.Hotkey = $link.Hotkey
$info.TargetPath = $link.TargetPath
$info.LinkPath = $link.FullName
$info.Arguments = $link.Arguments
$info.Target = try {Split-Path $info.TargetPath -Leaf } catch { 'n/a'}
$info.Link = try { Split-Path $info.LinkPath -Leaf } catch { 'n/a'}
$info.WindowStyle = $link.WindowStyle
$info.IconLocation = $link.IconLocation

New-Object PSObject -Property $info
}
}

dir $wshell.specialfolders.item("desktop") | del -whatif

[System.Environment]::GetFolderPath("Desktop")
#put link on the desktop
$path=[environment]::GetFolderPath("Desktop") + "\editorStart.lnk"
$comobject = New-Object -ComObject Wscript.shell
$link = $comobject.createShortcut($path)
$link.targetpath = "notepad.exe"
$link.IconLocation = "notepad.exe,0"
$link.Save()

[System.Environment+SpecialFolder] | Get-Member -static -memberType Property