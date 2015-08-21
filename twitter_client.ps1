Import-Module ShowUI            

function Search-Twitter ($q = "PowerShell") {
    $wc = New-Object Net.Webclient
    $url = "http://search.twitter.com/search.rss?q=$q"
    ([xml]$wc.downloadstring($url)).rss.channel.item | select *
}            

$ws = @{
    WindowStartupLocation = "CenterScreen"
    SizeToContent = "Width"
    Height = 550
    Title = "PowerShell, ShowUI and the Twitter API"
}            

New-Window @ws -Show {
    ListBox -Background Black -ItemTemplate {
        Grid -Columns 55, 300 {
            Image -Name Image -Margin 5 -Column 0
            TextBlock -Name Title -Margin 5 `
            -Column 1 -TextWrapping Wrap -Foreground White
        } |
            ConvertTo-DataTemplate -binding @{
                "Image.Source" = "image_link"
                "Title.Text" = "title"
            }
    } -DataContext {Search-Twitter PowerShell} `
      -DataBinding @{ItemsSource="."}
}