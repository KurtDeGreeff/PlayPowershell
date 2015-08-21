[CmdletBinding()]
param()

[string[]]$commands = 'Get-JHSystemInfo',
            'Get-JHDiskInfo',
            'Get-JHVolumeInfo',
            'Get-JHNetAdapterInfo'

$options = [ordered]@{}            
for ($i = 0; $i -lt $commands.count; $i++)
{
    Write-Debug "adding $($commands[$i]) to hash table"
    $sblock = [System.Management.Automation.ScriptBlock]::Create($commands[$i])
    $options["$i"] = $sblock
}             
$options["X"] = { Clear-Host }        

Write-Debug "Fred" 

do 
{
 
 
    #Clear-Host
    Write-Host "--------------------------------------------"
    Write-Host '               SUPPORT MENU '
    Write-Host "--------------------------------------------"
    Write-Host ''
    foreach ($key in $options.keys)
    {   
        if ($key -eq 'X') {continue}
        
        write-debug "bob"
        $desc = get-help $commands[[int]$key] | Select-Object SYNOPSIS
        
        Write-Host "  $key. $($desc.synopsis)"
    }
    Write-Host ''
    $choice = Read-Host 'Enter selection'
 
    Write-Host ''
    Write-Host 'Enter computer names one at a time. Press'
    Write-Host 'enter on a blank prompt to begin.'
 
    if ($choice -in $options.keys)
    {
        &$options.$choice
    }
    else
    {
        Write-Host 'Invalid Command, please try again'
    }
 
} 
while ($choice -ne 'x')