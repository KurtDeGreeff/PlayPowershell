Import-Module ShowUI

function Global:Get-SpeakerDetails ($SessionID) {

    if(!$SessionID) {return}

    Global:Invoke-ODataTransform (Invoke-RestMethod ($SessionID + "/Speakers")) 
}

New-Window -Title "TechEd NA 2012 - PowerShell v3 OData ShowUI Viewer" -Show -Width 850 -Height 850 -WindowStartupLocation CenterScreen -On_Loaded {
    $TitleSearch.Focus()
} {
    
    New-Grid -Rows 95, 150*, 150*, 150*, 125*, 35  {

        New-GroupBox -Header (New-TextBlock -Foreground Blue -FontStyle Italic -Text " Search " ) -Row 0 -Margin 10 -Content {
            New-StackPanel -Orientation Horizontal {
                New-TextBox -Name TitleSearch -Margin 10 -MinWidth 600 -Height 32
                New-Button _Search -Height 32 -IsDefault -On_Click {
                    if($TitleSearch.Text.Length -eq 0) {return}
                    
                    $Speakers.DataContext = $null                    
                    $search = $url + "?`$filter=substringof('$($TitleSearch.Text)', Title)"
                    $search | Out-Host                     
                    #$Titles.DataContext = @(Invoke-ODataTransform (Invoke-RestMethod $search))
                    $Titles.DataContext = .\Get-TechEdTitle $TitleSearch.Text
                }
            }
        }

        New-GroupBox -Header (New-TextBlock -Foreground Blue -FontStyle Italic -Text " Titles " ) -Row 1 -Margin 10 -Content {
            New-ListBox -Name Titles -Margin 10 `
                -DataContext $d `
                -DataBinding @{ItemsSource = "."} `
                -DisplayMemberPath Title `
                -On_SelectionChanged {

                    $Abstract.Text = $this.SelectedItem.Abstract
                    $Details.DataContext = @($this.SelectedItem)                    
                    $Speakers.DataContext = @(Global:Get-SpeakerDetails $this.SelectedItem.ID)                    
            }
        }

        New-GroupBox -Header (New-TextBlock -Foreground Blue -FontStyle Italic -Text " Speakers " ) -Row 2 -Margin 10 -Content {
            New-ListView -Name Speakers -DataBinding @{ ItemsSource = "." } -Margin 10 -View {
                New-GridView -AllowsColumnReorder -Columns {
                    New-GridViewColumn "SpeakerFirstName"
                    New-GridViewColumn "SpeakerLastName"
                }
            }
        }

        New-GroupBox -Header (New-TextBlock -Foreground Blue -FontStyle Italic -Text " Abstract " ) -Row 3 -Margin 10 -Content {
            New-TextBox -Name Abstract -TextWrapping Wrap -Margin 10 -IsReadOnly -VerticalScrollBarVisibility Auto
        }
        
        New-GroupBox -Header (New-TextBlock -Foreground Blue -FontStyle Italic -Text " Details " ) -Row 4 -Margin 10 -Content {

            New-ListView -Name Details -Margin 10 -DataBinding @{ ItemsSource = "." } -View {
                New-GridView -AllowsColumnReorder -Columns {
                    New-GridViewColumn "Room"
                    New-GridViewColumn "Date"
                    New-GridViewColumn "StartTime"
                    New-GridViewColumn "EndTime"
                    New-GridViewColumn "TID" 
                    New-GridViewColumn "Code"
                    New-GridViewColumn "SessionID"
                }
            }
        }

        New-StackPanel -Row 5 -HorizontalAlignment Center -Margin 10 -Orientation Horizontal {
            TextBlock "Created by " 

            TextBlock {
                Hyperlink -NavigateUri "http://dougfinke.com/blog" "Doug Finke" -On_RequestNavigate { 
                    [Diagnostics.Process]::Start("http://dougfinke.com/blog") 
                }
            }
            
            TextBlock ", Author of: " -FontWeight Bold

            TextBlock {
                Hyperlink -NavigateUri "http://shop.oreilly.com/product/0636920024491.do" '"PowerShell for Developers"' -On_RequestNavigate { 
                    [Diagnostics.Process]::Start("http://shop.oreilly.com/product/0636920024491.do") 
                }
            }

            TextBlock " for "

            TextBlock {
                Hyperlink -NavigateUri "http://PowerShellMagazine.com" "PowerShell Magazine" -On_RequestNavigate { 
                    [Diagnostics.Process]::Start("http://PowerShellMagazine.com") 
                }
            }
        }
    }
}