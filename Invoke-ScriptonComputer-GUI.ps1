Invoke-Command -ComputerName (
    Get-ADComputer -Filter {OperatingSystem -like 'Windows Server*' -and enabled -eq $true} |
    Out-GridView -OutputMode Multiple -Title 'Select Servers to Query:' |
    Select-Object -ExpandProperty DNSHostName
) -FilePath (
    Get-ChildItem -Path C:\Scripts\*.ps1 |
    Out-GridView -OutputMode Single -Title 'Select PowerShell Script to Run:' |
    Select-Object -ExpandProperty FullName
) | Out-GridView -Title 'Results'