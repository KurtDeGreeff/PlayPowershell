param(
    [string] $Filter = "IsInstalled = 1 and Type = 'Software'"
)

$objSession = New-Object -ComObject "Microsoft.Update.Session"

foreach($update in $objSession.CreateUpdateSearcher().Search($Filter).Updates)
{
    foreach($bundledUpdate in $update.BundledUpdates)
    {
        foreach($content in $bundledUpdate.DownloadContents)
        {
            if ($content.IsDeltaCompressedContent)
            {
                write-verbose "Ignore Delta Compressed Content: $($Update.Title)"
                continue
            }
            
            if ( $content.DownloadURL.toLower().EndsWith(".exe") )
            {
                write-verbose "Ignore Exe Content: $($Update.Title)"
                #continue
            }

            [pscustomobject] @{
                ID = $update.Identity.UpdateID
                KB = $update.KBARticleIDs| %{ $_ } 
                URL = $update.MoreInfoUrls| %{ $_ } 
                Type = $Update.Categories | ?{ $_.Parent.CategoryID -ne "6964aab4-c5b5-43bd-a17d-ffb4346a8e1d" } | %{ $_.Name }
                Title = $update.Title
                Size = $bundledUpdate.MaxDownloadSize
                DownloadURL = $content.DownloadURL
                Auto = $update.autoSelectOnWebSites
            }
        }
    }
}
