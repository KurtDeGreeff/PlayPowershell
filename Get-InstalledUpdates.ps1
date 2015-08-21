function Get-InstalledUpdates {
<#
    .SYNOPSIS
    Gets the NTFS rights set on a folder.
    Lists the installed hotfixes and/or updates on target systems.
    .DESCRIPTION
    Lists the installed hotfixes and/or updates on target systems by using PowerShell remoting.
    .PARAMETER ComputerName
    An array which takes the names of the target computers as input.
    .PARAMETER All
    This parameter and parameterset is used by default and lists both installed updates and hotfixes.
    .PARAMETER HotFixes
    This parameter lists all installed hotfixes.
    .PARAMETER Updates
    This parameter lists all installed updates.
    .EXAMPLE
    PS [JeffWouters.nl]\> Get-InstalledUpdates -ComputerName 'server1','server2','server3'

    KB                        Type                   ComputerName
    --                        ----                   ------------
    KB2862330                 Update                 server1
    KB2862330                 Update                 server2
    KB2862330                 Update                 server3
    KB2861698                 Update                 server1
    KB2861698                 Update                 server3
    KB2489256                 Update                 server1
    KB2489256                 Update                 server3
    KB2506014                 Update                 server2
    KB2509553                 Update                 server1
    KB2509553                 Update                 server2
    
    .EXAMPLE
    PS [JeffWouters.nl]\> Get-InstalledUpdates -ComputerName 'server1','server2','server3' -HotFixes

    KB                        Type                   ComputerName
    --                        ----                   ------------
    KB2489256                 Update                 server1
    KB2489256                 Update                 server3
    KB2506014                 Update                 server2
    KB2509553                 Update                 server1
    KB2509553                 Update                 server2
    
    .EXAMPLE
    PS [JeffWouters.nl]\> Get-InstalledUpdates -ComputerName 'server1','server2','server3' -Updates

    KB                        Type                   ComputerName
    --                        ----                   ------------
    KB2862330                 Update                 server1
    KB2862330                 Update                 server2
    KB2862330                 Update                 server3
    KB2861698                 Update                 server1
    KB2861698                 Update                 server3    
    
#>
    [cmdletbinding(DefaultParameterSetName="All")]
    param(
        [parameter(mandatory=$true,parametersetname='All')]
        [parameter(mandatory=$true,parametersetname='HotFixes')]
        [parameter(mandatory=$true,parametersetname='Updates')]
        [array]$ComputerName,
        [parameter(mandatory=$false,parametersetname='All')][switch]$All,
        [parameter(mandatory=$false,parametersetname='HotFixes')][switch]$HotFixes,
        [parameter(mandatory=$false,parametersetname='Updates')][switch]$Updates
    )
    $Session = New-PSSession -ComputerName $ComputerName
    Invoke-Command -Session $Session -ScriptBlock { $Session = New-Object -ComObject Microsoft.Update.Session }
    Invoke-Command -Session $Session -ScriptBlock { $Searcher = $Session.CreateUpdateSearcher() }
    Invoke-Command -Session $Session -ScriptBlock { $HistoryCount = $Searcher.GetTotalHistoryCount() }
    if (($PSCmdlet.ParameterSetName -eq 'All') -or ($PSCmdlet.ParameterSetName -eq 'Updates')) {
        $Output = Invoke-Command -Session $Session -ScriptBlock { 
            $Updates = $Searcher.QueryHistory(0,$HistoryCount) 
            foreach ($Update in $Updates) {
                [regex]::match($Update.Title,'(KB[0-9]{6,7})').value | Where-Object {$_ -ne ""} | foreach {
                    $Object = New-Object -TypeName PSObject
                    $Object | Add-Member -MemberType NoteProperty -Name KB -Value $_
                    $Object | Add-Member -MemberType NoteProperty -Name 'Type' -Value 'Update'
                    $Object
                }
            }
        }
        $Output | Select-Object KB,Type,@{Name="ComputerName";Expression={$_.PSComputerName}}
    }
    if (($PSCmdlet.ParameterSetName -eq 'All') -or ($PSCmdlet.ParameterSetName -eq 'HotFixes')) {
        $Output = Invoke-Command -Session $Session -ScriptBlock { 
            $HotFixes = Get-HotFix | Select-Object -ExpandProperty HotFixID 
            foreach ($HotFix in $HotFixes) {
                $Object = New-Object -TypeName PSObject
                $Object | Add-Member -MemberType NoteProperty -Name KB -Value $HotFix
                $Object | Add-Member -MemberType NoteProperty -Name 'Type' -Value 'HotFix'
                $Object          
            }
        }
        $Output | Select-Object KB,Type,@{Name="ComputerName";Expression={$_.PSComputerName}} 
    }
    Remove-PSSession $Session
}

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