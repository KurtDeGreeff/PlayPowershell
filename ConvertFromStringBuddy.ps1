#Requires -Version 5.0.9814.0

if(!($PSVersionTable.PSVersion.Major -ge 5 -and $PSVersionTable.PSVersion.Build -ge 9814)) {

    "Sorry you need PSVersion 5.0.9814.0 or newer"
    $psversiontable
    return
}

Add-Type -AssemblyName presentationframework

$XAML=@'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        WindowStartupLocation="CenterScreen"
        Title="ConvertFrom-String Buddy" Height="650" Width="850">

    <Grid >
        <Grid.ColumnDefinitions>
            <ColumnDefinition/>
            <ColumnDefinition/>
        </Grid.ColumnDefinitions>

        <Grid.RowDefinitions>
            <RowDefinition Height="42"/>
            <RowDefinition/>
            <RowDefinition/>
            <RowDefinition Height="150"/>
        </Grid.RowDefinitions>

        <StackPanel Orientation="Horizontal" Grid.Column="0" Margin="3">
            <Button x:Name="btnClear" Content=" C_lear All " Grid.Row="0" Margin="3" Width="Auto" HorizontalAlignment="Left"/>
            <Button x:Name="btnCopy" Content=" _Copy PowerShell Code " Margin="3" Width="Auto" HorizontalAlignment="Left"/>
        </StackPanel>

        <GroupBox Header=" _Data " Grid.Row="1" Grid.Column="0" Margin="3">
            <TextBox x:Name="Data" Margin="3"
                FontFamily="Consolas"
                FontSize="14"
                AcceptsReturn="True"
                AcceptsTab="True"
                VerticalScrollBarVisibility="Visible"
                HorizontalScrollBarVisibility="Visible"/>
        </GroupBox>

        <GroupBox Header=" _Template " Grid.Row="1" Grid.Column="1" Margin="3">
            <TextBox x:Name="Template" Margin="3"
                FontFamily="Consolas"
                FontSize="14"
                AcceptsReturn="True"
                AcceptsTab="True"
                VerticalScrollBarVisibility="Visible"
                HorizontalScrollBarVisibility="Visible"/>
        </GroupBox>

        <GroupBox Header=" _Result " Grid.Row="2" Grid.Column="0" Grid.ColumnSpan="2" Margin="3">
            <TextBox x:Name="Result" Margin="3" IsReadOnly="True"
                FontFamily="Consolas"
                FontSize="14"
                TextWrapping="Wrap"
                VerticalScrollBarVisibility="Visible"
                HorizontalScrollBarVisibility="Visible"/>
        </GroupBox>

        <GroupBox Header=" C_ode " Grid.Row="3" Grid.Column="0" Grid.ColumnSpan="2" Margin="3">
            <TextBox x:Name="Code" Margin="3" IsReadOnly="True"
                FontFamily="Consolas"
                FontSize="14"
                TextWrapping="Wrap"
                VerticalScrollBarVisibility="Visible"
                HorizontalScrollBarVisibility="Visible"/>
        </GroupBox>

    </Grid>
</Window>
'@

$Window = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader ([xml]$XAML)))

$DataPane=$Window.FindName("Data")
$TemplatePane=$Window.FindName("Template")
$ResultPane=$Window.FindName("Result")
$CodePane=$Window.FindName("Code")

$ButtonCopy=$Window.FindName("btnCopy")
$ButtonClear=$Window.FindName("btnClear")

$DataPane.Text=@"
Aaron Crow,java clojure gcal
BAD ENTRY
Alvin Chyan,java ruby clojure
Artem Boytsov,flying southwest
REAL BAD ENTRY
Maverick Lou,java clojure jenkins
Vinnie Pepi,javascript ruby clojure
Will Lao,java ruby javascript clojure
"@

$TemplatePane.Text = @"
{First*:Aaron} {Last:Crow},{Skills:java cloj}
{First*:Alvin}
"@

function Export-Code {
    if($ResultPane.Text.Trim().Length -eq 0) {return}
    $CodePane.Text = @"

`$targetData = @'
$($DataPane.Text)
'@

`$TemplateContent = @'
$($TemplatePane.Text)
'@

`$targetData | ConvertFrom-String -TemplateContent `$TemplateContent
"@
}

function Invoke-CFS {

    $ResultPane.Foreground="Black"
    $ResultPane.Background="White"
    $ResultPane.FontWeight="Normal"

    $Error.Clear()
    try {
        $r=$DataPane.Text |
            ConvertFrom-String -TemplateContent $TemplatePane.Text |
            Select * -ExcludeProperty ExtentText |
            Ft -A |
            Out-String
    } catch {
        $ResultPane.Foreground="Red"
        $ResultPane.Background="Blue"
        $ResultPane.FontWeight="Bold"
        $r=$Error[0]
    }

    $ResultPane.Text = $r #.Trim()
}

function Invoke-CFSGen {
    Invoke-CFS
    Export-Code
}

$ButtonCopy.Add_Click({$CodePane.Text|Clip})

$ButtonClear.Add_Click({
    $CodePane.Text=$null
    $TemplatePane.Text=$null
    $ResultPane.Text=$null
    $DataPane.Text=$null
})

$timer = New-Object System.Windows.Threading.DispatcherTimer
$timer.Interval = [timespan]"0:0:0.500"

$timer.Add_Tick({
    Invoke-CFSGen
    $timer.Stop()
})

$DataPane.Add_TextChanged({
    $timer.Stop()
    $timer.Start()
})

$TemplatePane.Add_TextChanged({
    $timer.Stop()
    $timer.Start()
})

Invoke-CFSGen

[void]$DataPane.Focus()
[void]$Window.ShowDialog()