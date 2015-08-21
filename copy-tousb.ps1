$m = Get-Content -Path "X:\Users\Kurt\Documents\VirtualDJ\Playlists\LOUNGE-EASYLISTEN.m3u" | select -Skip 2
$m | foreach { Copy-Item $_ C:\ }