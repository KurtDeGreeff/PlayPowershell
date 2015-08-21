import-module showui
Function Get-NetworkAdapterConfig 
{
param(
$ComputerName = $env:COMPUTERNAME,
$Credential
)
Begin {
    $WMIParam = @{
        ComputerName = $ComputerName
        Class = 'Win32_NetworkAdapterConfiguration'
        Namespace = 'Root\CIMV2'
        Filter = "IPEnabled=$true"
        ErrorAction = 'Stop'
    }
    If ($PSBoundParameters['Credential']) {
        $WMIParam.Credential = $Credential
    }
}
 
Process {
    Try {
        ($net = Get-WmiObject @WMIParam)
        $script:desc = $net | % description
    } Catch {
        Write-Warning ("{0}: {1}" -f $ComputerName,$_.Exception.Message)
    }
}
}

New-Window -Width 500 -Height 350 -Name "Network Config" -ControlName NetworkConfig -Content {
New-ComboBox -Name TestCombo {            
$b = Get-Content "C:\Users\Kurt\Documents\beatit.txt"
foreach ($item in $b)
        {
        New-ComboBoxItem -Content $item
        }
New-Label -Content "This is a test label"            
#        New-ComboBoxItem -Content $desc -Name nic
#        }
}
} -Show