function Search-TechEdNA2014ContentCatalog {
 
param
(
# by default you'll get all sessions from a content catalog
[string]$Keyword = ''
)
 
$Uri = 'http://tena2014.eventpoint.com/Topic/List?format=html&take=1000&keyword=' + $Keyword
$Results = Invoke-WebRequest -Uri $Uri
 
$Results.RawContent -replace "\n"," " -replace "\s+"," " -replace "(?<=\>)\s+" -replace "\s+(?=\<)" -split 'class="topic"' |
 select -skip 1 |
 foreach {
     
 
        $Speaker     = if ( $_ -match 'Speaker\(s\):.*?</div>' ) { $matches[0] -split "," -replace ".*a href[^>].*?>" -replace "</a.*"  | foreach { $_.Trim() } }
        $Title       = if ( $_ -match 'Class="title".*?href.*?>(.*?)<' ) { $Matches[1].Trim() }
        $Track       = if ( $_ -match "Track:.*?>(.*?)<" ) { $Matches[1].Trim() }
        $SessionType = if ( $_ -match "Session Type:.*?>(.*?)<" ) { $Matches[1].Trim() }
        $Date        = if ( $_ -match 'class="session">(.*?)<' ) { $Matches[1].Trim() }
        $Description = if ( $_ -match 'class="description">(.*?)<' ) { $Matches[1].Trim() }
         
        [pscustomobject]@{
            Date = $Date
            Track = $Track
            SessionType = $SessionType
            Speaker = $speaker
            Title = $Title
            Description = $Description
        }
    }
}
