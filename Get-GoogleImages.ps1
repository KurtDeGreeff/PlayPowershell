#Getting Pictures from Google Picture Search
$SearchItem = 'PowerShell'
$TargetFolder = 'c:\webpictures'
if ( (Test-Path -Path $TargetFolder) -eq $false) { md $TargetFolder }
explorer.exe $TargetFolder
$url = "https://www.google.com/search?q=$SearchItem&espv=210&es_sm=93&source=lnms&tbm=isch&sa=X&tbm=isch&tbs=isz:lt%2Cislt:2mp"
$browserAgent = 'Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/33.0.1750.146 Safari/537.36'
$page = Invoke-WebRequest -Uri $url -UserAgent $browserAgent
$page.Links | 
  Where-Object { $_.href -like '*imgres*' } | 
  ForEach-Object { ($_.href -split 'imgurl=')[-1].Split('&')[0]} |
  ForEach-Object {
    $file = Split-Path -Path $_ -Leaf
    $path = Join-Path -Path $TargetFolder -ChildPath $file
    Invoke-WebRequest -Uri $_ -OutFile $path
  }
