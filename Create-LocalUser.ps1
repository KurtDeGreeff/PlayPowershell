#Get secure password from file
$pass = Get-Content C:\Windows\mysecstr.txt | ConvertTo-SecureString

#Connect to localhost via ADSI
[ADSI]$server="WinNT://$env:COMPUTERNAME"

#Create user root and set password
$support=$server.Create("User","root")
$support.SetPassword("$pass")
$support.SetInfo()

#Set account not to expire
$flag=$support.UserFlags.value -bor 0x10000
$support.put("userflags",$flag)
$support.SetInfo()

#Add account to administrators group
[ADSI]$group="WinNT://$env:COMPUTERNAME/administrators,Group"
$group.Add($support.path)