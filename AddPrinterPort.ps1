# ------------------------------------------------------------------------ 
# NAME: AddPrinterPort.ps1 

# 
# KEYWORDS: wmi, printing, printer ports and printer drivers 
# 
# COMMENTS: This script uses the wmi class accelerator 
# to create a new tcp / ip printer port on a local comptuer. 
# To use you will need to modify the ip address of the port 
# 
# ------------------------------------------------------------------------ 
$ip = "10.0.0.10" 
$port = [wmiclass]"Win32_TcpIpPrinterPort" 
$port.psbase.scope.options.EnablePrivileges = $true 
$newPort = $port.CreateInstance() 
$newport.name = "IP_$ip" 
$newport.Protocol = 1 
$newport.HostAddress = $ip 
$newport.PortNumber = "9100" 
$newport.SnmpEnabled = $false 
$newport.Put()