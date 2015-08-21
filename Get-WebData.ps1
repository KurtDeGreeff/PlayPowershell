function Get-WebData {

    param([string]$Url, [Switch]$Raw)

    $wc = New-Object Net.WebClient
    $feed = $wc.DownloadString($Url)

    if($Raw) { return $feed }

    [xml]$feed
}
