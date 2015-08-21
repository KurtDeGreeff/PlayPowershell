#Build the GUI
[xml]$xaml = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    x:Name="Window" Title="Initial Window" WindowStartupLocation = "CenterScreen" 
    Width = "800" Height = "600" ShowInTaskbar = "True">
</Window>
"@ 

$reader=(New-Object System.Xml.XmlNodeReader $xaml)
$Window=[Windows.Markup.XamlReader]::Load( $reader )
# $Window.AllowsTransparency = $True
$Window.Opacity = .5
$window.WindowStyle = 'None'
$Window.Background = 'Blue'
$Window.FontSize = 24
$Window.FontStyle = 'Italic' #"Normal", "Italic", or "Oblique
$Window.FontWeight = 'Bold' #http://msdn.microsoft.com/en-us/library/system.windows.fontweights
$Window.Foreground = 'White'
$Window.Content = "This is a test!"
$Window.Add_MouseRightButtonUp({
    $Window.close()
})
$Window.Add_MouseLeftButtonDown({
    $Window.DragMove()
})
$Window.ShowDialog()




