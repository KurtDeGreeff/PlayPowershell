<#
.SYNOPSIS
    Download all images from privately shared Google Picasa web album in full resolution
.DESCRIPTION
    When someone shares a link to a privately shared album on Picasa, it is painful to download each picture if you do not have
    the desktop version of Picasa installed. This script will take the link to the album, ususally shared on email, and will
    download the full resolution version of all pictures automatically
.NOTES
    Author: Parul Jain paruljain@hotmai.com
    Version: 1.0 Jan 30, 2014
    Requires: PowerShell v3 or better
.PARAMETER albumUrl
    Mandatory. String URL of the privately shared Google Picasa web album, usually distributed on email
.EXAMPLE
    picasa.ps1 https://picasaweb.google.com/1234567890/someAlbum?authkey=xy12DFghj9Ipw
#>

param([Parameter(Mandatory=$True)][string]$albumUrl)

$page = Invoke-WebRequest $albumUrl
if ($page.RawContent -match 'https://picasaweb.google.com/data/feed/base/user/(\d+)/albumid/(\d+)') {
    $userId = $matches[1]
    $albumId = $matches[2]
}
else { throw 'User ID and Album ID cannot be found on the picasa page' }

if ($page.RawContent -match 'authkey=(\w+)') { $authKey = $matches[1] }
else { throw 'Authentication key cannot be found the picasa page'}

$photos = Invoke-RestMethod -Uri "https://picasaweb.google.com/data/feed/api/user/$userId/albumid/${albumId}?authkey=$authKey"
foreach ($photo in $photos) {
    $photoDetail = Invoke-RestMethod -Uri ($photo.id[0] + "?authkey=$authKey&imgmax=d")
    $filename = ($photoDetail.entry.content.src).Split('/')[-1]
    Invoke-RestMethod -Uri $photoDetail.entry.content.src -OutFile (".\$filename")
}