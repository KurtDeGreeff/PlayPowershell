function Update-FakeWindow8Startmenu
{
    $StartMenu = "C:\Startmenu"
    remove-item $StartMenu -Recurse -Force
    $path1 = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs"
    gci $path1 -rec | % {
        cp $_.fullname     "$StartMenu\$($_.fullname.substring($path1.Length + 1))"
    }

    $path2 = "$env:AppData\Microsoft\Windows\Start Menu\Programs"
    gci "$env:AppData\Microsoft\Windows\Start Menu\Programs" -Recurse | % {
        cp $_.fullname  "$StartMenu\$($_.fullname.substring($path2.Length + 1))" -ea SilentlyContinue
    }

}