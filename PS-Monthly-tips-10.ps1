function Get-WebClient 
{
 $wc = New-Object Net.WebClient
 $wc.UseDefaultCredentials = $true
 $wc.Proxy.Credentials = $wc.Credentials
 $wc
}
$url = ‘http://powershell.com/cs/media/p/26784/download.aspx’
$object = Get-WebClient
$localPath = “$home\Documents\objects_and_types.pdf”
$object.DownloadFile($url, $localPath)
explorer.exe “/SELECT,$localPath”
Invoke-Item -Path $localPath ####################################################################################DOWNLOAD WITH PROGRESS BAR (only works with a real url)Add-Type -AssemblyName Microsoft.VisualBasic
$url = ‘http://powershell.com/cs/media/p/26784/download.aspx’
$localPath = “$home\Documents\objects_and_types.pdf”
#Use low-level response to get real URL and not a redirect
$response = [System.Net.WebRequest]::Create($url).GetResponse()
$realurl = $response.ResponseUri.OriginalString
$response.Close() 
$object = New-Object Microsoft.VisualBasic.Devices.Network
$object.DownloadFile($realurl, $localPath, ‘’, ‘’, $true, 500, $true, ‘DoNothing’)
explorer.exe “/SELECT,$localPath”
Invoke-Item -Path $localPath
####################################################################################
#Unblock every downloaded file 
Get-ChildItem -Path $Home\Downloads -Recurse |
 Get-Item -Stream Zone.Identifier -ErrorAction Ignore | 
 Select-Object -ExpandProperty FileName |
 Get-Item | Unblock-File 
###################################################################################
$regex = [RegEx]’<span></span>(.*?)</a></h4>’
$url = ‘http://blogs.msdn.com/b/powershell/’
$wc = New-Object System.Net.WebClient
$content = $wc.DownloadString($url)
$regex.Matches($content) | ForEach-Object { $_.Groups[1].Value }

###################################################################################
$xml = New-Object xml
###################################################################################
#Get Exchange Rates
$xml = New-Object xml
$xml.Load(‘http://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml’)
$allrates = @{}
$xml.Envelope.Cube.Cube.Cube | ForEach-Object {
$currency = $_.currency
$rate = $_.rate
$allrates.$currency = $rate
}
“All exchange rates:” 
$allrates
“Specific exchange rate:”
$allrates[“IDR”]
##################################################################################
#Get Popular names
function Get-PopularName
{
 param
 (
 [ValidateSet('1880','1890','1900','1910','1920','1930','1940','1950','1960','1970', '1980','1990','2000')]
 $Decade = '1950'
 )
 $regex = [regex]'(?si)<td>(\d{1,3})</td>\s*?<td align=”center”>(.*?)</td>\s*?<td>((?:\d{0,3}\,)*\d{1,3})</td>\s*?<td align=”center”>(.*?)</td>\s*?<td>((?:\d{0,3}\,)*\d{1,3})</td></tr>'
 $web = Invoke-WebRequest -UseBasicParsing -Uri "http://www.ssa.gov/OACT/babynames/decades/names$($decade)s.html"
 $html = $web.Content
 $Matches = $regex.Matches($html)
 $matches | ForEach-Object {
 $rv = New-Object PSObject | Select-Object -Property Name, Rank, Number, Gender
 $rv.Rank = [int]$_.Groups[1].Value
 $rv.Gender = 'm'
 $rv.Name = $_.Groups[2].Value
 $rv.Number = [int]$_.Groups[3].Value
 $rv
 $rv = New-Object PSObject | Select-Object -Property Name, Rank, Number, Gender
 $rv.Rank = [int]$_.Groups[1].Value
 $rv.Gender = 'f'
 $rv.Name = $_.Groupss[4].Value
 $rv.Number = [int]$_.Groups[5].Value
 $rv
 } | Sort-Object Name, Rank
} ####################################################################################Search and play youtube video$keyword = “Learn PowerShell”
Invoke-RestMethod -Uri “https://gdata.youtube.com/feeds/api/videos?v=2&q=$($keyword.Replace(‘ ‘,’+’))” | 
Select-Object -Property Title, @{N=’Author’;E={$_.Author.Name}}, @{N=’Link’;E={$_.Content.src}}, @{N=’Updated’;E={[DateTime]$_.Updated}} |
Sort-Object -Property Updated -Descending |
Out-GridView -Title “Select your ‘$Keyword’ video, then click OK to view.” -PassThru |
ForEach-Object { Start-Process $_.Link } ###################################################################################function isURI($address) 
{($address -as [System.URI]).AbsoluteURI -ne $null}

function isURIWeb($address) 
{$uri = $address -as [System.URI] 
$uri.AbsoluteURI -ne $null -and $uri.Scheme -match ‘[http|https]’} #########################################################################################function Refresh-WebPages {
 param(
 $interval = 5
 )
 “Refreshing IE Windows every $interval seconds.”
 “Press any key to stop.”
 
 $shell = New-Object -ComObject Shell.Application
 do {
 ‘Refreshing ALL HTML’
 $shell.Windows() | 
 Where-Object { $_.Document.url } | 
 ForEach-Object { $_.Refresh() }
 Start-Sleep -Seconds $interval
 } until ( [System.Console]::KeyAvailable )
 
 [System.Console]::ReadKey($true) | Out-Null
}
#########################################################################################