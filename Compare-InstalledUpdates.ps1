function Compare-InstalledUpdates {
    param (
        [parameter(mandatory=$true)][array]$ComputerName
    )
    $AllUpdates = Get-InstalledUpdates -All -ComputerName $ComputerName | Select-Object KB,Type,@{Name="ComputerName";Expression={$_.PSComputerName}}
    $AllUpdateNames = $AllUpdates | select -ExpandProperty kb -Unique
    foreach ($Computer in $ComputerName) {
        $ComputerUpdates = $AllUpdates | Where-Object {$_.ComputerName -eq "$Computer"} | select -ExpandProperty KB -Unique
        $Results = Compare-Object $AllUpdateNames $ComputerUpdates | select -ExpandProperty InputObject -Unique
        $Results | foreach {
                $Object = New-Object -TypeName PSObject
                $Object | Add-Member -MemberType NoteProperty -Name 'ComputerName' -Value $Computer
                $Object | Add-Member -MemberType NoteProperty -Name 'Name' -Value $_
                $Object
        }   
    }
}
