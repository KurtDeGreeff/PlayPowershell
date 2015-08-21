Add-Type -AssemblyName PresentationFrameWork

$MainWindow=@'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Topmost="True"
        WindowStartupLocation="CenterScreen"
        Title="PowerSHell Summit Videos" Height="850" Width="1200">
    <Grid>
        <Grid.RowDefinitions>
            <RowDefinition Height="200"/>
            <RowDefinition/>
        </Grid.RowDefinitions>
        
        <ListBox x:Name="lstTitles" Grid.Row="0" Margin="3"/>
        <WebBrowser x:Name="Viewer" Grid.Row="1" Margin="3"/>
    </Grid>
</Window>
'@

$Window = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader ([xml]$MainWindow)))


$lstTitles=$Window.FindName("lstTitles")
$Viewer=$Window.FindName("Viewer")

$lstTitles.ItemsSource = Invoke-RestMethod https://gdata.youtube.com/feeds/users/UCqIw7UUwC5fUBFXYX68aMrQ/uploads | 
    ForEach {
        $date=(Get-Date($_.published))
        if($date.year -eq 2015 -and $date.Month -eq 4) {$_}
    } | 
        ForEach {
        [PSCustomObject][ordered]@{        
            title=$_.title.'#text'
            href=$_.link.href[0]
        }
    }

$lstTitles.DisplayMemberPath="title"
[void]$lstTitles.Focus()

$lstTitles.add_SelectionChanged({$Viewer.Navigate($lstTitles.SelectedItem.href)})

[void]$Window.ShowDialog()