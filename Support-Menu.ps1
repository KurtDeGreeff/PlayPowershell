do {
 
    Clear-Host
    Write-Host "--------------------------------------------"
    Write-Host '               SUPPORT MENU '
    Write-Host "--------------------------------------------"
    Write-Host ''
    Write-Host '  1. Check system info'
    Write-Host '  2. Check disk info'
    Write-Host ''
    Write-Host '  X. Exit menu'
    Write-Host ''
    $choice = Read-Host 'Enter selection'
 
    Write-Host ''
    Write-Host 'Enter computer names one at a time. Press'
    Write-Host 'enter on a blank prompt to begin.'
 
    switch ($choice) {
        '1' { Get-SystemInfo }
        '2' { Get-DiskInfo   }
        'X' { Clear-Host     }
    }
 
} while ($choice -ne 'x')