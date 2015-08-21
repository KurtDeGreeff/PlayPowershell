Function Show-Inputbox {
 Param([string]$message=$(Throw "You must enter a prompt message"),
       [string]$title="Input",
       [string]$default
       )
       
 [reflection.assembly]::loadwithpartialname("microsoft.visualbasic") | Out-Null
 [microsoft.visualbasic.interaction]::InputBox($message,$title,$default)

}

$Dev = Show-Inputbox -message "The New Web files location" `
-title "Path" -default "E:\DevSite\0000\"

$Prod = Show-Inputbox -message "The Prod Web files location" `
-title "Path" -default "E:\inetpub\0000\"

<#
$exe = "E:\Tools\BEYOND~1\BCompare.exe"
$p = [diagnostics.process]::Start("cmd.exe", "/c start /wait " + $exe + " @E:\Scripts\PS1\IISProject\SyncWebSite.txt $left $right")
#>