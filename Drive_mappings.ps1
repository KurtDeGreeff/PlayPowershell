# Program/Script: C:\WINDOWS\system32\WindowsPowerShell\v1.0\powershell.exe

# Add arguments: -noexit -command "C:\Users\userID\Documents\Scripts\Drive_Mappings.ps1"

# ------Drive_Mappings.ps1-----------

#Create Object Instance of Wscript.Network
$net = new-object -ComObject WScript.Network

#Gather Collection of All Network Drive Mappings
$mappedDrives = $net.EnumNetworkDrives()

#Remove All Established Network Drive Mappings
for ($d = 0; $d -lt $mappedDrives.Count(); $d = $d + 2)
{
 #Remove Network Drive
  $net.RemoveNetworkDrive($mappedDrives.item($d).ToString(),$true,$true) 
}

#Pause the Script to Prevent Networking Confusion
Start-Sleep -Milliseconds 800

#Map Required Drives
$net.MapNetworkDrive("i:", "\\server1.mydomain.com\share1", $true)
$net.MapNetworkDrive("j:", "\\server2.mydomain.com\share2", $true)
$net.MapNetworkDrive("k:", "\\server3.mydomain.com\share3", $true)
$net.MapNetworkDrive("l:", "\\server4.mydomain.com\share4", $true)
$net.MapNetworkDrive("s:", "\\server5.mydomain.com\share5", $true)