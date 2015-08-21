function Get-InstalledSoftware {
    param (
        [parameter(mandatory=$true)][array]$ComputerName
    )
    foreach ($Computer in $ComputerName) {
        $OSArchitecture = (Get-WMIObject -ComputerName $Computer win32_operatingSystem -ErrorAction Stop).OSArchitecture
        if ($OSArchitecture -like '*64*') {
            $RegistryPath = 'SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
        } else {
            $RegistryPath = 'Software\Microsoft\Windows\CurrentVersion\Uninstall'           
        }
        $Registry = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $Computer)
        $RegistryKey = $Registry.OpenSubKey("$RegistryPath")
        $RegistryKey.GetSubKeyNames() | foreach {
            $Registry.OpenSubKey("$RegistryPath\$_") | Where-Object {($_.GetValue("DisplayName") -notmatch '(KB[0-9]{6,7})') -and ($_.GetValue("DisplayName") -ne $null)} | foreach {
                $Object = New-Object -TypeName PSObject
                $Object | Add-Member -MemberType noteproperty -Name 'Name' -Value $($_.GetValue("DisplayName"))
                $Object | Add-Member -MemberType noteproperty -name 'ComputerName' -value $Computer
                $Object
            }
        }
    }   
}