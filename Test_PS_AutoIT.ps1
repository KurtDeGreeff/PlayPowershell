Get-WmiObject -Class Win32_NetworkAdapter
$AutoIt = New-Object -ComObject AutoItX3.Control
	$result = $AutoIt.Run("notepad.exe")
 
	$wintitle = "Untitled - Notepad"
	$AutoIt.WinWaitActive($wintitle) | Out-Null
	$AutoIt.Send("This is a test")
    $AutoIt.Sleep(3)
    $AutoIt.WinClose("Untitled - Notepad")
    $AutoIt.Send("{ENTER}")
    if ($wintitle = "Save As")
    {
    $AutoIt.WinWaitActive($wintitle) | Out-Null
    $AutoIt.Send("test.txt")
    $AutoIt.Send("{ENTER}")    
    }
    if ($wintitle = "Confirm Save As")
    {
    $AutoIt.WinWaitActive($wintitle) | Out-Null
    $AutoIt.Send("!y") 
    }