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
Get-Shortcut | Out-GridView