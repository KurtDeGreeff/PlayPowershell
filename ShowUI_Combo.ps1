ipmo showui
       $job = New-StackPanel -ControlName 'Get-PersonalInformation' -Columns auto -Children {
       New-Label "What is your first name?"
       New-TextBox -Name Firstname
       New-Label "What is your last name?"
       New-TextBox -Name Lastname
       New-Label "When were you born?"
       Select-Date -Name Birthdate
       } -Show
$job | Update-WPFJob {  $Window.Content.Children | Where {$_.Name -eq "Firstname"} | % { $_.Text = "Russell" } }
    
<#    New-Grid -Name TestGrid {
    New-ComboBox -Name TestCombo {            
        $b = Get-Content "C:\Users\Kurt\Documents\beatit.txt"
        foreach ($item in $b)
        {
        New-ComboBoxItem -Content $item    
        }
        }            
} -show
#>