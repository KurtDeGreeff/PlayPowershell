 # Read RSS feeds in Parallel using a Workflow
$feeds =
    @{Name="DevelopmentInABlink";Url ="http://feeds.feedburner.com/DevelopmentInABlink"},
    @{Name="PowershellMagazine";Url ="http://feeds.feedburner.com/PowershellMagazine"},
    @{Name="Microsoft";Url ="http://blogs.msdn.com/b/mainfeed.aspx?Type=BlogsOnly"},
    @{Name ="Daily SHow";Url ="http://www.indecisionforever.com/feed/"}

Workflow Get-Feeds ([Hashtable[]]$feeds ) {   
    ForEach -Parallel ($feed in $feeds ) {
        Invoke-RestMethod -Uri $feed.url |
        Select -Property Title, pubdate  |
        Add-Member -PassThru -MemberType NoteProperty -Name Source -Value $feed.Name
    }
}

Get-Feeds $feeds | Select-Object * | Out-GridView 
