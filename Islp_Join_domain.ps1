# Add 2 reg entries for Win7/Samba domain compatibility
$LM= 'HKLM:\SYSTEM\CurrentControlSet\services\LanmanWorkstation\Parameters'
New-ItemProperty -Path $LM  -Name DomainCompatibilityMode -PropertyType DWord -Value 1 -ErrorAction:SilentlyContinue | Out-Null
New-ItemProperty -Path $LM  -Name DNSNameResolutionRequired -PropertyType DWord -Value 0 -ErrorAction:SilentlyContinue | Out-Null
Restart-Service Workstation -force

# Samba Domain joining
 function JoinDomain ([string]$Domain, [string]$user, [string]$Password) {
 $domainUser= $Domain + "\" + $User
 $OU= $null
 $computersystem= gwmi Win32_Computersystem
 $computerSystem.JoinDomainOrWorkgroup($Domain,$Password,$DomainUser,$OU,3)
 }
write-host -ForegroundColor blue -BackgroundColor white "Joining domain $dom..."
 
#if join succeeds, restart computer
 if (JoinDomain ctislp_dom admin ctislp) {Write-host -ForegroundColor blue -BackgroundColor white "Successfully joined $dom domain!"}
 Start-sleep 3
 Pause