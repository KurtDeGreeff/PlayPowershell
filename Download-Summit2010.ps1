$webclient = New-Object system.net.webclient

$A="http://www.softconference.com/media/wmp/301110/301110-"
$C="Find your email from PASS telling you the password to the site, then go ahead
    and righ-click > copy hyperlink, paste the hyperlink into notepad and then add 
    the missing .asp? portion here.  "
$D=".wmv"
foreach($B in Get-Content SummitVideoNumbers.txt)
{
$url=$A+$B+$C
$file="C:\temp\$B$D"
"Picking $file";
if ((Test-Path $file) -eq "true") {"$file is already there mate"}
else { "Downloading $file"
$webclient.DownloadFile($url,$file) }
}