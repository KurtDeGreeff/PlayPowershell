##############################################################################
#  Script: Show-SecureString.ps1
#    Date: 29.May.2007
# Version: 1.0
# Purpose: "Decrypt" so-called secure strings.
#   Notes: Credit for this idea goes to MoW, The PowerShell Guy:
#          http://thepowershellguy.com/blogs/posh/archive/2007/02/21/scrip
#                 ting-games-2007-advanced-powershell-event-7.aspx
#   Legal: Script provided "AS IS" without warranties or guarantees of any
#          kind.  USE AT YOUR OWN RISK.  Public domain, no rights reserved.
##############################################################################



$cred = get-credential   # Dialog box appears.

$cred.username           # Works.
$cred.password           # Doesn't work, it's stored as "secure string", but...

$bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($cred.password)
[System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)






