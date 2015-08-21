function Find-Script
{
    param
    (
        [Parameter(Mandatory=$true)]
        $Keyword, 
        $Maximum = 20,
        $StartPath = $env:USERPROFILE
    ) 
    Get-ChildItem -Path $StartPath -Filter *.ps1 -Recurse -ErrorAction SilentlyContinue |
      Select-String -SimpleMatch -Pattern $Keyword -List |
      Select-Object -Property FileName, Path, Line -First $Maximum |
      Out-GridView -Title 'Select Script File' -PassThru |
      ForEach-Object { ise $_.Path }
}