$Dom = 'FEDPOL0_DOM'
#Create secure encrypted password
$pass = '76492d1116743f0423413b16050a5345MgB8ADMAeQBzAEMASQBqAEUAawBvAHEASQBUAE0ANwBuAE8AeABUAHAAbQBZAGcAPQA9AHwAMQA1ADAANwA0AGMAYQBjAGMAOQBhAGMAMQAwADUAZABkAGUANQBkADgAZQA4AGMAMABmADQAYQAyADQAMAAwADkAMQBiAGUAZgBiADQANQBhADMANwA4ADQAOQBmADMANgA5ADAANAA1ADgAYQAwAGIANAAxADAANQBjADEAZgA0ADYAMgA3AGQANwAzADQAOAA2ADYAZQA0AGEANQAxADkAOABiADQAYgBiAGYANgAxADgAOQA1AGIAZgBkADQAMgA0ADkAZgBmADMAMgA1AGUANABjADcAYQBmADAAZAA4AGEANQBmAGIANABhADkANABjAGYAZgA0ADEANwBlAA=='
$key = '75 5 193 125 223 117 111 135 176 107 84 116 46 89 177 237 210 23 151 22 249 185 148 59 121 63 83 248 31 252 184 31'
$passSec = ConvertTo-SecureString -String $pass -Key ([Byte[]]$key.Split(' '))
$cred = New-Object system.Management.Automation.PSCredential('power',$passSec)
$passSecure = $cred.GetNetworkCredential().Password

# Samba Domain joining
  function JoinDomain  {
       param
       (
           [string]
           $Domain,

           [string]
           $user,

           [string]
           $Password
       )

   $domainUser= $Domain + '\' + $User
   $OU= $null
   $computersystem= Get-WmiObject Win32_Computersystem

$computerSystem.JoinDomainOrWorkgroup($Domain,$Password,$DomainUser,$OU,3)
   }
write-host -ForegroundColor blue -BackgroundColor white "Joining domain
$dom..."

#join domain
#Add-Computer -Credential $cred -DomainName $dom

JoinDomain $dom 'power' $passSecure | Out-Default
JoinDomain $dom 'power' $passSecure | Out-Default
if ((Get-WmiObject Win32_Computersystem).Domain -ne $dom) {JoinDomain $dom 'power' $passSecure}
if ((Get-WmiObject Win32_Computersystem).Domain -ne $dom) {JoinDomain $dom 'power' $passSecure}


#add gs_Admin to local administrators group
net localgroup administrators $dom\gs_admin /add