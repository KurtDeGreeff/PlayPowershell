function Get-SpecialFolder {
    param ([string]$Name)
    foreach ($folder in (([Enum]::GetValues([System.Environment+SpecialFolder])) | Where-Object {$_ -like $Name})) {
        Write-Output (,([PSCustomObject] @{
            Name = $folder.ToString()
            Path = [System.Environment]::GetFolderPath($folder)
        }))
    }
}