# Script which uses a local GPO dll to modify a registry setting
Add-Type -Path "C:\Users\Kurt\Downloads\LocalPolicy.1.0.0.1\LocalPolicy.dll" -PassThru

[LocalPolicy.ComputerGroupPolicyObject].GetConstructors() |
ForEach-Object {
($_.GetParameters() |
ForEach-Object {
‘{0} {1}’ -f $_.Name, $_.ParameterType.FullName
}) -join ‘,’
}

[LocalPolicy.GroupPolicyObjectSettings].GetConstructors() |
ForEach-Object {
($_.GetParameters() |
ForEach-Object {
‘{0} {1}’ -f $_.Name, $_.ParameterType.FullName
}) -join ‘,’
}

[Microsoft.Win32.RegistryValueKind]::DWord

#$computername = $env:COMPUTERNAME
$GPOSettings = New-Object  -TypeName LocalPolicy.GroupPolicyObjectSettings($true,$true)
$GPO = New-Object -TypeName LocalPolicy.ComputerGroupPolicyObject($GPOSettings)
#$GPO.GetPathTo([LocalPolicy.GroupPolicySection]::Machine)
#$GPO.GetPathTo([LocalPolicy.GroupPolicySection]::user)
#$GPO.GetPathTo([LocalPolicy.GroupPolicySection]::root)

$keyPath = "SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"
#$machine = $GPO.GetRootRegistryKey([LocalPolicy.GroupPolicySection]::Machine) #Microsoft.Win32.RegistryKey
#$terminalServicesKey = $machine.CreateSubKey($keyPath)

$RegHKLM = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine,[microsoft.Win32.RegistryView]::Default)
$terminalServicesKey = $RegHKLM.CreateSubKey($keyPath)
$terminalServicesKey.SetValue("SecurityLayer", 0)#, [Microsoft.Win32.RegistryValueKind]::DWord)
#$GPO.Delete()
#$GPO.Save() # save not always needed, is saved without save method

